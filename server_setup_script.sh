#!/bin/bash

# Exit on error
set -e

echo "Starting ChatGPT-GitHub Integration Server Setup"

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y git nodejs npm python3 python3-pip nginx certbot python3-certbot-nginx redis-server curl

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Create application user
useradd -m -s /bin/bash chatgptgit || echo "User already exists"
usermod -aG sudo chatgptgit

# Create application directories
mkdir -p /opt/chatgpt-github-integration
chown chatgptgit:chatgptgit /opt/chatgpt-github-integration

# Switch to application user
su - chatgptgit << 'EOF'
# Create application structure
mkdir -p /opt/chatgpt-github-integration/{server,config,logs,cache}

# Initialize Node project
cd /opt/chatgpt-github-integration/server
npm init -y
npm install express express-session passport passport-github2 morgan winston cors dotenv axios body-parser cookie-parser redis connect-redis simple-git jsonwebtoken

# Create main server file
cat > /opt/chatgpt-github-integration/server/server.js << 'EOSERVER'
const express = require('express');
const session = require('express-session');
const passport = require('passport');
const GitHubStrategy = require('passport-github2').Strategy;
const cors = require('cors');
const morgan = require('morgan');
const winston = require('winston');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const Redis = require('redis');
const RedisStore = require('connect-redis').default;
const simpleGit = require('simple-git');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// Initialize logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '../logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: '../logs/combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Redis client setup
const redisClient = Redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

redisClient.connect().catch(console.error);

// Initialize express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: process.env.CLIENT_ORIGIN || 'https://chat.openai.com',
  credentials: true
}));
app.use(morgan('combined'));
app.use(cookieParser());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Session configuration
app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Initialize Passport
app.use(passport.initialize());
app.use(passport.session());

// GitHub OAuth Strategy
passport.use(new GitHubStrategy({
    clientID: process.env.GITHUB_CLIENT_ID,
    clientSecret: process.env.GITHUB_CLIENT_SECRET,
    callbackURL: process.env.GITHUB_CALLBACK_URL,
    scope: ['repo', 'user', 'workflow']
  },
  function(accessToken, refreshToken, profile, done) {
    const user = {
      id: profile.id,
      username: profile.username,
      displayName: profile.displayName || profile.username,
      accessToken,
      emails: profile.emails
    };
    return done(null, user);
  }
));

passport.serializeUser(function(user, done) {
  done(null, user);
});

passport.deserializeUser(function(obj, done) {
  done(null, obj);
});

// Basic routes
app.get('/', (req, res) => {
  res.send('ChatGPT GitHub Integration API is running');
});

// Auth routes
app.get('/auth/github', passport.authenticate('github'));

app.get('/auth/github/callback', 
  passport.authenticate('github', { failureRedirect: '/login' }),
  function(req, res) {
    res.redirect('/success');
  }
);

app.get('/success', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Authentication Successful</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f6f8fa;
            color: #24292e;
          }
          .card {
            background-color: white;
            border-radius: 6px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            padding: 32px;
            text-align: center;
            max-width: 400px;
          }
          svg {
            fill: #2da44e;
            width: 64px;
            height: 64px;
            margin-bottom: 16px;
          }
          h1 {
            margin: 0 0 16px 0;
          }
          p {
            margin: 0 0 24px 0;
            color: #57606a;
            line-height: 1.5;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
          </svg>
          <h1>Successfully Connected</h1>
          <p>You've authenticated with GitHub. You can close this window and return to ChatGPT.</p>
        </div>
      </body>
    </html>
  `);
});

app.get('/login', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>GitHub Authentication</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f6f8fa;
            color: #24292e;
          }
          .card {
            background-color: white;
            border-radius: 6px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            padding: 32px;
            text-align: center;
            max-width: 400px;
          }
          .button {
            background-color: #2da44e;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 12px 20px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
          }
          .button:hover {
            background-color: #2c974b;
          }
          h1 {
            margin: 0 0 16px 0;
          }
          p {
            margin: 0 0 24px 0;
            color: #57606a;
            line-height: 1.5;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>GitHub Authentication</h1>
          <p>Connect your GitHub account to use with ChatGPT</p>
          <a href="/auth/github" class="button">Login with GitHub</a>
        </div>
      </body>
    </html>
  `);
});

// GitHub API routes
app.get('/api/user', ensureAuthenticated, (req, res) => {
  res.json(req.user);
});

// Get repositories list
app.get('/api/repos', ensureAuthenticated, async (req, res) => {
  try {
    const response = await axios.get('https://api.github.com/user/repos?per_page=100', {
      headers: {
        Authorization: `token ${req.user.accessToken}`
      }
    });
    res.json(response.data);
  } catch (error) {
    logger.error('Error fetching repos:', error);
    res.status(500).json({ error: 'Failed to fetch repositories' });
  }
});

// Get file or directory contents
app.get('/api/repos/:owner/:repo/contents/:path(*)', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo, path } = req.params;
    const branch = req.query.branch || 'main';
    
    const response = await axios.get(`https://api.github.com/repos/${owner}/${repo}/contents/${path}`, {
      headers: {
        Authorization: `token ${req.user.accessToken}`
      },
      params: {
        ref: branch
      }
    });
    res.json(response.data);
  } catch (error) {
    logger.error('Error fetching file contents:', error);
    res.status(500).json({ error: 'Failed to fetch file contents' });
  }
});

// Update file contents
app.post('/api/repos/:owner/:repo/contents/:path(*)', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo, path } = req.params;
    const { content, message, sha, branch } = req.body;
    
    const response = await axios.put(
      `https://api.github.com/repos/${owner}/${repo}/contents/${path}`,
      {
        message,
        content: Buffer.from(content).toString('base64'),
        sha,
        branch
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    logger.error('Error updating file:', error);
    res.status(500).json({ error: 'Failed to update file' });
  }
});

// Create a new repository
app.post('/api/repos', ensureAuthenticated, async (req, res) => {
  try {
    const { name, description, private: isPrivate, auto_init } = req.body;
    
    const response = await axios.post(
      'https://api.github.com/user/repos',
      {
        name,
        description,
        private: isPrivate,
        auto_init
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    logger.error('Error creating repository:', error);
    res.status(500).json({ error: 'Failed to create repository' });
  }
});

// Create a new file
app.post('/api/repos/:owner/:repo/create/:path(*)', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo, path } = req.params;
    const { content, message, branch } = req.body;
    
    const response = await axios.put(
      `https://api.github.com/repos/${owner}/${repo}/contents/${path}`,
      {
        message,
        content: Buffer.from(content).toString('base64'),
        branch
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    logger.error('Error creating file:', error);
    res.status(500).json({ error: 'Failed to create file' });
  }
});

// Create multiple files (for conversation export)
app.post('/api/repos/:owner/:repo/batch-create', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo } = req.params;
    const { files, message, branch } = req.body;
    
    // For multiple files, we need to use Git references and blobs
    const results = [];
    
    // Get the latest commit SHA
    const refResponse = await axios.get(
      `https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${branch}`,
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    const latestCommitSha = refResponse.data.object.sha;
    
    // Get the tree of the latest commit
    const commitResponse = await axios.get(
      `https://api.github.com/repos/${owner}/${repo}/git/commits/${latestCommitSha}`,
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    const baseTreeSha = commitResponse.data.tree.sha;
    
    // Create blobs for each file
    const newTreeItems = [];
    
    for (const file of files) {
      // Create blob
      const blobResponse = await axios.post(
        `https://api.github.com/repos/${owner}/${repo}/git/blobs`,
        {
          content: file.content,
          encoding: "utf-8"
        },
        {
          headers: {
            Authorization: `token ${req.user.accessToken}`
          }
        }
      );
      
      newTreeItems.push({
        path: file.path,
        mode: "100644",
        type: "blob",
        sha: blobResponse.data.sha
      });
      
      results.push({
        path: file.path,
        sha: blobResponse.data.sha
      });
    }
    
    // Create new tree
    const newTreeResponse = await axios.post(
      `https://api.github.com/repos/${owner}/${repo}/git/trees`,
      {
        base_tree: baseTreeSha,
        tree: newTreeItems
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    const newTreeSha = newTreeResponse.data.sha;
    
    // Create commit
    const commitMessageResponse = await axios.post(
      `https://api.github.com/repos/${owner}/${repo}/git/commits`,
      {
        message,
        tree: newTreeSha,
        parents: [latestCommitSha]
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    const newCommitSha = commitMessageResponse.data.sha;
    
    // Update reference
    await axios.patch(
      `https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${branch}`,
      {
        sha: newCommitSha,
        force: false
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    res.json({
      message: "Files created successfully",
      commit: newCommitSha,
      files: results
    });
  } catch (error) {
    logger.error('Error creating multiple files:', error);
    res.status(500).json({ error: 'Failed to create files' });
  }
});

// Create a new branch
app.post('/api/repos/:owner/:repo/branches', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo } = req.params;
    const { baseBranch, newBranch } = req.body;
    
    // Get the SHA of the latest commit on the base branch
    const branchResponse = await axios.get(
      `https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${baseBranch}`,
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    const sha = branchResponse.data.object.sha;
    
    // Create the new branch
    const response = await axios.post(
      `https://api.github.com/repos/${owner}/${repo}/git/refs`,
      {
        ref: `refs/heads/${newBranch}`,
        sha
      },
      {
        headers: {
          Authorization: `token ${req.user.accessToken}`
        }
      }
    );
    
    res.json(response.data);
  } catch (error) {
    logger.error('Error creating branch:', error);
    res.status(500).json({ error: 'Failed to create branch' });
  }
});

// Get repository branches
app.get('/api/repos/:owner/:repo/branches', ensureAuthenticated, async (req, res) => {
  try {
    const { owner, repo } = req.params;
    
    const response = await axios.get(`https://api.github.com/repos/${owner}/${repo}/branches`, {
      headers: {
        Authorization: `token ${req.user.accessToken}`
      }
    });
    
    res.json(response.data);
  } catch (error) {
    logger.error('Error fetching branches:', error);
    res.status(500).json({ error: 'Failed to fetch branches' });
  }
});

// Logout endpoint
app.get('/auth/logout', (req, res) => {
  req.logout(function(err) {
    if (err) { return next(err); }
    res.redirect('/');
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Helper functions
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  }
  res.status(401).json({ error: 'Not authenticated' });
}

// Start server
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
  console.log(`Server running on port ${PORT}`);
});
EOSERVER

# Create environment configuration file
cat > /opt/chatgpt-github-integration/server/.env << 'EOENV'
PORT=3000
NODE_ENV=development
SESSION_SECRET=replace_with_a_secure_random_string
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
GITHUB_CALLBACK_URL=https://your-server-domain.com/auth/github/callback
CLIENT_ORIGIN=https://chat.openai.com
REDIS_URL=redis://localhost:6379
EOENV
EOF

# Create a systemd service file for the application
cat > /etc/systemd/system/chatgpt-github-integration.service << 'EOSERVICE'
[Unit]
Description=ChatGPT GitHub Integration Server
After=network.target redis.service

[Service]
Type=simple
User=chatgptgit
WorkingDirectory=/opt/chatgpt-github-integration/server
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOSERVICE

# Configure Nginx as reverse proxy
cat > /etc/nginx/sites-available/chatgpt-github-integration << 'EONGINX'
server {
    listen 80;
    server_name your-server-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Support larger file uploads
        client_max_body_size 10M;
    }
}
EONGINX

# Enable the site
ln -s /etc/nginx/sites-available/chatgpt-github-integration /etc/nginx/sites-enabled/

# Remove default Nginx site if it exists
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
nginx -t

# Generate a strong random session secret
RANDOM_SECRET=$(openssl rand -base64 32)
# Update the .env file with the random secret
sed -i "s/replace_with_a_secure_random_string/$RANDOM_SECRET/" /opt/chatgpt-github-integration/server/.env

# Start and enable services
systemctl daemon-reload
systemctl enable chatgpt-github-integration
systemctl enable redis-server
systemctl start redis-server
systemctl start chatgpt-github-integration
systemctl restart nginx

echo "=========================================================="
echo "ChatGPT GitHub Integration Server Setup Complete!"
echo "=========================================================="
echo ""
echo "Next steps:"
echo "1. Register a GitHub OAuth application at https://github.com/settings/applications/new"
echo "2. Set Homepage URL to: https://your-server-domain.com"
echo "3. Set Authorization callback URL to: https://your-server-domain.com/auth/github/callback"
echo "4. Update the GitHub OAuth credentials in /opt/chatgpt-github-integration/server/.env"
echo "5. Set up SSL with Let's Encrypt: certbot --nginx -d your-server-domain.com"
echo "6. Restart the service: systemctl restart chatgpt-github-integration"
echo ""
echo "After completing these steps, your server will be ready to use with the browser extension."
