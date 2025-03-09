#!/bin/bash
set -e

# Create extension directory structure
mkdir -p extension/images

# Copy extension files
cp manifest.json extension/
cp popup.html extension/
cp popup.js extension/
cp background.js extension/
cp content.js extension/
cp styles.css extension/browser-extension-styles.css extension/

# Download GitHub icons
echo "Downloading GitHub icons..."
curl -s -o extension/images/icon16.png https://raw.githubusercontent.com/JJP123/simpleicons/master/icons/github/github-16.png
curl -s -o extension/images/icon48.png https://raw.githubusercontent.com/JJP123/simpleicons/master/icons/github/github-48.png
curl -s -o extension/images/icon128.png https://raw.githubusercontent.com/JJP123/simpleicons/master/icons/github/github-128.png

echo "Extension files prepared in the 'extension' directory"
echo "You can now load this as an unpacked extension in your browser"
