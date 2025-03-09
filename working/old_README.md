# ChatGPT-GitHub Integration: Complete Installation Guide

This guide provides comprehensive instructions for setting up both the server and browser extension components of the ChatGPT-GitHub integration.

## Server Installation

### Prerequisites
- Proxmox VE installed and running
- A Debian 11/12 LXC container or VM with:
  - At least 2GB RAM
  - 2 CPU cores
  - 10GB storage
  - Network connection with a static IP
- A domain or subdomain pointing to your server's IP address

### Option 1: Quick Install with Curl

For a faster setup process, you can use curl to download and run the setup script directly:

```bash
# SSH into your Debian VM/LXC container
ssh root@your-container-ip

# Download and execute the setup script
curl -fsSL https://raw.githubusercontent.com/yourusername/chatgpt-github-integration/main/setup.sh | bash
```

If you prefer to review the script before running it:
```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/yourusername/chatgpt-github-integration/main/setup.sh -o setup.sh

# Review the script contents
less setup.sh

# Make it executable and run
chmod +x setup.sh
./setup.sh
```

After the script completes, proceed to Step 3: Configure GitHub OAuth.

### Option 2: Manual Setup

#### Step a: Create a Debian Container in Proxmox

1. Log in to your Proxmox web interface
2. Click on "Create CT" to create a new container
3. Configure the container:
   - General: Give it a name (e.g., `chatgpt-github`)
   - Template: Choose the latest Debian template (11 or 12)
   - Disk: Allocate at least 8GB
   - CPU: Assign at least 2 cores
   - Memory: Allocate at least 2GB RAM
   - Network: Configure with a static IP address
4. Start the container after creation

#### Step b: Set Up the Server

1. SSH into your container/VM:
   ```bash
   ssh root@your-container-ip
   ```

2. Create a file for the setup script:
   ```bash
   nano setup.sh
   ```

3. Copy and paste the entire server setup script into this file, then save (Ctrl+O, Enter) and exit (Ctrl+X).

4. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```

5. Run the setup script:
   ```bash
   ./setup.sh
   ```

6. The script will install all necessary dependencies and create the required files.

### Step 3: Configure GitHub OAuth

1. Go to GitHub and register a new OAuth application:
   - Navigate to GitHub → Settings → Developer Settings → OAuth Apps → New OAuth App
   - Fill in the application details:
     - Application name: `ChatGPT GitHub Integration`
     - Homepage URL: `https://your-server-domain.com`
     - Authorization callback URL: `https://your-server-domain.com/auth/github/callback`
   - Click "Register application"

2. After registration, you'll get a Client ID. Generate a new client secret by clicking "Generate a new client secret".

3. Update the configuration file on your server:
   ```bash
   nano /opt/chatgpt-github-integration/server/.env
   ```

4. Replace the placeholder values with your actual GitHub OAuth credentials:
   ```
   GITHUB_CLIENT_ID=your_actual_client_id
   GITHUB_CLIENT_SECRET=your_actual_client_secret
   GITHUB_CALLBACK_URL=https://your-server-domain.com/auth/github/callback
   ```

5. Save the file and exit.

### Step 4: Set Up SSL with Let's Encrypt

1. Install Let's Encrypt SSL certificate:
   ```bash
   certbot --nginx -d your-server-domain.com
   ```

2. Follow the prompts to complete the setup.

3. This will automatically update your Nginx configuration to use HTTPS.

### Step 5: Restart the Service

```bash
systemctl restart chatgpt-github-integration
```

### Step 6: Verify Server Installation

Open a web browser and navigate to `https://your-server-domain.com`. You should see a message: "ChatGPT GitHub Integration API is running"

## Browser Extension Installation

### Prerequisites
- Windows 11 computer
- Chrome, Edge, or Brave browser

### Step 1: Create Extension Directory Structure

1. Create the main extension directory:
   ```
   C:\Users\YourUsername\Documents\ChatGPT-GitHub-Extension
   ```

2. Create an `images` folder inside this directory:
   ```
   C:\Users\YourUsername\Documents\ChatGPT-GitHub-Extension\images
   ```

### Step 2: Create Extension Files

1. In the main extension directory, create the following files:
   - manifest.json
   - content.js
   - background.js
   - popup.html
   - popup.js
   - styles.css

2. Copy the provided code into each of these files.

3. Create/obtain three icon files and place them in the images folder:
   - icon16.png (16x16 pixels)
   - icon48.png (48x48 pixels)
   - icon128.png (128x128 pixels)

   You can create your own GitHub-themed icons or use placeholder icons.

### Step 3: Install the Extension in Your Browser

#### For Chrome

1. Open Chrome
2. Type `chrome://extensions/` in the address bar and press Enter
3. Enable "Developer mode" by toggling the switch in the top-right corner
4. Click "Load unpacked"
5. Browse to and select your extension folder (`C:\Users\YourUsername\Documents\ChatGPT-GitHub-Extension`)
6. The extension should now appear in your extensions list
7. Click the puzzle piece icon in the Chrome toolbar to see all extensions
8. Find the ChatGPT GitHub Integration extension and click the pin icon to keep it visible in the toolbar

#### For Edge

1. Open Edge
2. Type `edge://extensions/` in the address bar and press Enter
3. Enable "Developer mode" by toggling the switch in the bottom-left corner
4. Click "Load unpacked"
5. Browse to and select your extension folder
6. The extension should now appear in your extensions list
7. Click the puzzle piece icon in the Edge toolbar
8. Find the ChatGPT GitHub Integration extension and click the eye icon to pin it to the toolbar

#### For Brave

1. Open Brave
2. Type `brave://extensions/` in the address bar and press Enter
3. Enable "Developer mode" by toggling the switch in the top-right corner
4. Click "Load unpacked"
5. Browse to and select your extension folder
6. The extension should now appear in your extensions list
7. Click the puzzle piece icon in the Brave toolbar
8. Find the ChatGPT GitHub Integration extension and click the pin icon to keep it visible in the toolbar

### Step 4: Configure the Extension

1. Click on the ChatGPT GitHub Integration extension icon in your browser toolbar
2. In the popup, enter your server URL in the "Integration Server URL" field (e.g., `https://your-server-domain.com`)
3. Click "Save URL"
4. Click "Connect to GitHub" to authenticate with your GitHub account
5. Follow the authentication process in the new window that opens
6. After successful authentication, you'll see your GitHub username in the popup, indicating that you're connected

## Using the Integration

1. Navigate to ChatGPT at https://chat.openai.com/
2. You should see a GitHub icon in the input area
3. Click this icon to access the GitHub integration interface
4. Use the interface to:
   - Create new repositories from your conversations
   - Browse your existing repositories
   - View and edit files
   - Insert file contents into ChatGPT

For detailed usage instructions, refer to the usage guide.

## Troubleshooting

### Server Issues

If the server isn't working correctly:

1. Check server logs:
   ```bash
   journalctl -u chatgpt-github-integration
   ```

2. Verify that Redis is running:
   ```bash
   systemctl status redis-server
   ```

3. Check Nginx configuration:
   ```bash
   nginx -t
   ```

4. Ensure ports 80 and 443 are open.

### Extension Issues

If the extension isn't working correctly:

1. Verify that the server URL is correctly set in the extension
2. Check the browser console for any JavaScript errors
3. Make sure the extension is enabled
4. Try reloading the extension from the extensions page

## Maintenance

### Updating the Server

To update the server in the future:

1. SSH into your server
2. Pull the latest changes (if using git) or update the files manually
3. Restart the service:
   ```bash
   systemctl restart chatgpt-github-integration
   ```

### Updating the Extension

When you make changes to the extension files:

1. Go to the extensions page in your browser
2. Find the ChatGPT GitHub Integration extension
3. Click the reload icon (⟳)
4. Refresh any open ChatGPT tabs

## Conclusion

You now have a fully functional ChatGPT-GitHub integration system! This allows you to create repositories directly from your ChatGPT conversations and automatically organize the content for future reference and sharing.
