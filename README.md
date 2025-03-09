# ChatGPT-GitHub Integration

This project enables seamless integration between ChatGPT and GitHub, allowing you to create repositories directly from your conversations and automatically organize content.

## Features

- Create public or private GitHub repositories from ChatGPT conversations
- Automatically save the final ChatGPT response as README.md
- Store previous conversation history in an organized working directory
- Extract and save code snippets from conversations into separate files
- Browse, navigate, and manage your GitHub repositories
- Insert file contents from GitHub into ChatGPT

## Quick Setup

### Server Setup using Curl

For faster deployment, you can use curl to fetch and run the setup script directly:

```bash
# SSH into your Debian VM/LXC container
ssh root@your-server-ip

# Download and execute the setup script
curl -fsSL https://raw.githubusercontent.com/b0bfranklin/chatgpt-github-integration/main/setup.sh | bash
```

Alternatively, if you prefer to review the script before execution:
```bash
curl -fsSL https://raw.githubusercontent.com/b0bfranklin/chatgpt-github-integration/main/setup.sh -o setup.sh
less setup.sh  # Review the script
chmod +x setup.sh
./setup.sh
```

After running the script, you'll need to:
1. Register a GitHub OAuth application
2. Update the .env file with your OAuth credentials
3. Set up SSL with Let's Encrypt

### Browser Extension Setup

1. Clone or download this repository
2. Load the extension from the `/extension` directory in Chrome, Edge, or Brave:
   - Open your browser and go to the extensions page
   - Enable Developer mode
   - Click "Load unpacked" and select the extension directory
3. Configure the extension with your server URL
4. Authenticate with GitHub

## Architecture

The integration consists of two main components:

### 1. Server Component
A Debian-based server (VM or LXC container) that handles:
- GitHub API communication
- OAuth authentication
- File and repository operations

### 2. Browser Extension
A browser extension for Chrome, Edge, and Brave that:
- Integrates with ChatGPT's UI
- Captures conversation content
- Communicates with the server component

## Detailed Documentation

- [Installation Guide](./docs/installation.md): Detailed instructions for setting up both components
- [Usage Guide](./docs/usage.md): Documentation on how to use the integration

## Requirements

### Server
- Debian 11/12 VM or LXC container
- 2GB RAM, 2 CPU cores
- 10GB storage
- Domain name pointing to server IP

### Client
- Windows 11
- Chrome, Edge, or Brave browser

## Security

This solution implements several security measures:
- HTTPS encryption for all communication
- Secure cookie handling
- GitHub OAuth for authentication
- Proper token scoping

## License

[MIT License](./LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
