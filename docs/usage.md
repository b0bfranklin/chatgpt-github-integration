# ChatGPT-GitHub Integration: Usage Guide

This guide explains how to use the ChatGPT-GitHub Integration to save your conversations as GitHub repositories.

## Overview

The ChatGPT-GitHub Integration adds a GitHub button to the ChatGPT interface, allowing you to:

1. Create new repositories from your conversations
2. Save the last ChatGPT response as the README.md file
3. Optionally save your entire conversation history in a structured format
4. Browse and manage your GitHub repositories directly from ChatGPT
5. Insert content from GitHub files into your conversations

## Getting Started

### Prerequisites

Before using the integration, make sure you have:

1. Installed the extension in your browser (Chrome, Edge, or Brave)
2. Set up the server component on your Proxmox VM/LXC container
3. Configured the extension with your server URL
4. Authenticated with GitHub through the extension

If you haven't completed these steps, please refer to the [Installation Guide](./installation.md).

### Accessing the GitHub Integration in ChatGPT

1. Navigate to [ChatGPT](https://chat.openai.com/)
2. Look for the GitHub icon below the message input area
3. Click the icon to open the GitHub integration panel

## Creating Repositories from Conversations

### Creating a New Repository

1. Click the GitHub icon in ChatGPT
2. Click "New Repository" in the panel
3. Fill in the repository details:
   - Repository Name: Enter a name for your repository (required)
   - Description: Add an optional description
   - Visibility: Choose Public or Private
   - Save current conversation: Check to save the conversation (checked by default)
   - Include working directory with previous messages: Check to save all messages, not just the final one (checked by default)
4. Click "Create Repository"

### What Gets Saved

When you create a repository with the conversation saved:

1. The most recent ChatGPT response is saved as the repository's README.md
2. If "Include working directory" is checked:
   - All previous messages are saved in `working/conversation.md`
   - Code snippets from the conversation are extracted and saved in `working/code/`

For example, if your conversation included Python code, the repository structure might look like:

```
my-chatgpt-repo/
├── README.md                      # Contains the final response from ChatGPT
└── working/
    ├── conversation.md            # Full conversation history
    └── code/
        ├── python_1.py            # First Python snippet from the conversation
        └── javascript_1.js        # JavaScript snippet from the conversation
```

## Browsing and Managing Repositories

### Viewing Your Repositories

1. Click the GitHub icon in ChatGPT
2. The panel will display a list of your GitHub repositories
3. Use the search box to filter repositories by name or description
4. Click on a repository to view its contents

### Navigating Repository Contents

1. After clicking on a repository, you'll see its file structure
2. Click on folders to navigate into them
3. Click on files to view their contents
4. Use the "Back" links to navigate up the file hierarchy
5. Use the branch selector dropdown to switch between branches

### Working with Files

#### Viewing Files

1. Click on a file in the repository browser to view its content
2. The file content will be displayed in a preview pane

#### Inserting Files into ChatGPT

1. Navigate to a file you want to reference in your conversation
2. Click "Insert into prompt"
3. The file content will be automatically inserted into the message input with proper formatting (code blocks with language highlighting where appropriate)

#### Editing Files

1. Navigate to a file you want to modify
2. Click "Edit file"
3. Make your changes in the editor
4. Enter a commit message
5. Click "Commit changes" to save your changes to GitHub

## Best Practices

### Organizing Conversations

- **Use Descriptive Repository Names**: Choose repository names that describe the conversation's purpose or content
- **Add Detailed Descriptions**: Include a description that summarizes what the conversation is about
- **Consider Visibility Carefully**: Set repositories to private if they contain sensitive information

### Working with Code Snippets

- For code that you want to save separately, use proper markdown code blocks with language specification:

  <pre>```python
  def hello_world():
      print("Hello, world!")
  ```</pre>

  This ensures the code is properly extracted and saved in the working directory.

### Repository Management

- **Regular Cleanup**: Periodically review and delete repositories that are no longer needed
- **Consistent Naming**: Adopt a consistent naming convention for your ChatGPT repositories (e.g., `chatgpt-python-sorting-algorithms`)

## Troubleshooting

### Authentication Issues

If you get disconnected from GitHub:

1. Click the extension icon in your browser toolbar
2. Check if you're still connected in the popup
3. If not, click "Connect to GitHub" to reauthenticate

### Integration Button Not Appearing

If the GitHub integration button doesn't appear in ChatGPT:

1. Refresh the page
2. Check if the extension is enabled in your browser
3. Examine the browser console for any JavaScript errors
4. Verify that the content script matches work for the current ChatGPT URL structure

### Failed Repository Creation

If repository creation fails:

1. Check if the repository name is already in use
2. Verify you have sufficient GitHub permissions
3. Ensure your GitHub account has available private repositories (if creating a private repo)
4. Check for connectivity issues between your browser and the integration server

## Conclusion

The ChatGPT-GitHub Integration streamlines the process of preserving valuable conversations and code snippets directly from your ChatGPT sessions. By automatically organizing the content into well-structured repositories, it makes it easy to reference, share, and build upon your AI-assisted work.
