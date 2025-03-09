# Docker Setup for ChatGPT-GitHub Integration

This repository contains Docker configurations for running the ChatGPT-GitHub Integration server component. This integration allows you to save ChatGPT conversations directly to GitHub repositories.

## Project Structure

```
.
├── Dockerfile                 # Docker image definition for the server
├── docker-compose.yml         # Docker Compose configuration
├── docker-entrypoint.sh       # Startup script for the container
├── nginx/                     # Nginx configuration files
├── server/                    # Server component files
│   ├── package.json           # Node.js dependencies
│   ├── server.js              # Main server code
│   └── .env.example           # Environment variables template
├── build-extension.sh         # Script to prepare extension files
└── README.md                  # This file
```

## Getting Started

### Prerequisites

- Docker
- Docker Compose
- GitHub OAuth Application credentials

### Setting Up GitHub OAuth

Before starting the server, you need to create a GitHub OAuth application:

1. Go to GitHub and register a new OAuth application:
   - Navigate to GitHub → Settings → Developer Settings → OAuth Apps → New OAuth App
   - Fill in the application details:
     - Application name: `ChatGPT GitHub Integration`
     - Homepage URL: `https://your-server-domain.com`
     - Authorization callback URL: `https://your-server-domain.com/auth/github/callback`
   - Click "Register application"

2. After registration, you'll get a Client ID and you can generate a Client Secret.

### Environment Setup

Create a `.env` file in the root directory with the following content:

```
SERVER_DOMAIN=your-server-domain.com
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
ENABLE_SSL=false
EMAIL_ADDRESS=your-email@example.com
```

- Replace `your-server-domain.com` with your actual domain
- Replace `your_github_client_id` and `your_github_client_secret` with your GitHub OAuth credentials
- Set `ENABLE_SSL` to `true` if you want to enable HTTPS with Let's Encrypt
- Provide your email address for Let's Encrypt notifications

### Running the Server

```bash
# Start the server
docker-compose up -d

# View logs
docker-compose logs -f
```

### Building the Browser Extension

The server component doesn't include the browser extension. To prepare the extension files:

1. Make sure you have all extension files in the root directory
2. Run the extension build script:

```bash
chmod +x build-extension.sh
./build-extension.sh
```

3. Load the extension from the `extension` directory in Chrome, Edge, or Brave:
   - Open your browser's extensions page
   - Enable Developer mode
   - Click "Load unpacked" and select the extension directory

4. Configure the extension with your server URL.

## Configuration Options

### Environment Variables

- `SERVER_DOMAIN`: Your server's domain name
- `GITHUB_CLIENT_ID`: GitHub OAuth application client ID
- `GITHUB_CLIENT_SECRET`: GitHub OAuth application client secret
- `CLIENT_ORIGIN`: Origin for CORS (default: https://chat.openai.com)
- `ENABLE_SSL`: Whether to enable HTTPS with Let's Encrypt
- `EMAIL_ADDRESS`: Email for Let's Encrypt notifications

## Secure Production Deployment

For production deployments, consider:

1. Always enable SSL (`ENABLE_SSL=true`)
2. Use a strong, random session secret
3. Set up proper firewalls to only expose necessary ports
4. Use Docker secrets for sensitive information

## Troubleshooting

### Server Issues

If the server isn't working correctly:

1. Check container logs:
   ```bash
   docker-compose logs server
   ```

2. Make sure GitHub OAuth credentials are correctly set up
3. Ensure your domain is properly pointing to your server's IP address
4. Check if ports 80, 443, and 3000 are open

### Extension Issues

If the extension isn't connecting to the server:

1. Make sure the server URL is correctly set in the extension
2. Check browser console for any JavaScript errors
3. Ensure the extension has proper permissions
