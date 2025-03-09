## Updating Your Installation

You can easily update your ChatGPT GitHub Integration to the latest version using the provided update script.

### Automatic Update

1. Make sure you're in the project directory:
   ```bash
   cd chatgpt-github-integration
   ```

2. Make the update script executable:
   ```bash
   chmod +x update.sh
   ```

3. Run the update script:
   ```bash
   ./update.sh
   ```

The script performs the following actions:
- Creates a backup of your current configuration
- Pulls the latest changes from the repository
- Rebuilds the Docker container with the updated code
- Updates the browser extension files
- Verifies configuration changes

### Manual Update

If you prefer to update manually, follow these steps:

1. Back up your configuration:
   ```bash
   mkdir backup
   cp .env docker-compose.yml backup/
   cp -r nginx backup/
   ```

2. Pull the latest changes:
   ```bash
   git pull
   ```

3. Rebuild and restart the Docker containers:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

4. Update the browser extension:
   ```bash
   ./build-extension.sh
   ```

5. Reload the extension in your browser

### Post-Update Steps

After updating, you should:

1. Check the logs to verify everything is working:
   ```bash
   docker-compose logs -f
   ```

2. Reload the browser extension in your browser's extension management page

3. Test the functionality by connecting to GitHub and creating a test repository
