# Git Account Manager

A bash script to easily manage multiple Git accounts (GitHub/GitLab) on a single machine using SSH keys and SSH config.

## Features

- **Add Multiple Accounts**: Set up separate SSH keys for personal, work, or client accounts
- **Easy Account Management**: List, add, and delete Git accounts with an interactive menu
- **Get SSH Keys**: Retrieve and copy public SSH keys for existing accounts
- **Fix Remote URLs**: Convert HTTPS repository URLs to SSH format
- **Test Connections**: Verify SSH connectivity with GitHub/GitLab
- **Git Configuration**: Set default branch name, user info, and other Git settings
- **Automatic SSH Configuration**: Manages your `~/.ssh/config` file automatically
- **Backup & Restore**: Automatically backs up your SSH config before changes
- **Provider Support**: Works with GitHub and GitLab
- **Color-Coded Interface**: Easy-to-read terminal output with color indicators

## Prerequisites

- macOS or Linux operating system
- `ssh-keygen` installed (usually pre-installed)
- `ssh-agent` available
- Bash shell

## Installation

### Option 1: Homebrew (Recommended for macOS)

```bash
# Add the tap
brew tap Yuyutsu/tap

# Install
brew install git-account-manager

# Run
git-account-manager
```

> **Note**: The Homebrew tap is currently being set up. For now, please use the manual installation method below.

### Option 2: Manual Installation

1. Clone or download this repository:
   ```bash
   git clone git@github.com-yuyutsu:Yuyutsu/git-account-manager.git
   cd git-account-manager
   ```
   
   Or using HTTPS:
   ```bash
   git clone https://github.com/Yuyutsu/git-account-manager.git
   cd git-account-manager
   ```

2. Make the script executable:
   ```bash
   chmod +x git-account-manager.sh
   ```

3. Run the script:
   ```bash
   ./git-account-manager.sh
   ```

4. (Optional) Add to PATH for system-wide access:
   ```bash
   sudo cp git-account-manager.sh /usr/local/bin/git-account-manager
   sudo chmod +x /usr/local/bin/git-account-manager
   ```

### Updating

**Homebrew:**
```bash
brew upgrade git-account-manager
```

**Manual:**
```bash
cd git-account-manager
git pull origin main
```

## Usage

### Main Menu

When you run the script, you'll see an interactive menu with the following options:

```
1. Add new Git account
2. Delete existing Git account
3. List accounts
4. Get SSH public key
5. Fix repository remote URL
6. Test SSH connection
7. Configure Git settings
8. Diagnose SSH issues
9. Restore config backup
10. Exit
```

### Adding a New Account

1. Select option `1` from the main menu
2. Provide the following information:
   - **Account name**: A unique identifier (e.g., `personal`, `work`, `client1`)
   - **Provider**: Choose `github` or `gitlab`
   - **Email**: The email associated with this Git account

3. The script will:
   - Generate an SSH key pair (`id_ed25519_<account-name>`)
   - Add the key to your SSH agent
   - Update your SSH config with a new Host entry
   - Display the public key to copy to your Git provider

4. Copy the displayed public key and add it to your GitHub/GitLab account:
   - **GitHub**: Settings → SSH and GPG keys → New SSH key
   - **GitLab**: Preferences → SSH Keys → Add new key

### Cloning Repositories

After adding an account, use the custom host alias to clone repositories:

```bash
# Format: git clone git@<provider>.com-<account-name>:username/repo.git

# Examples:
git clone git@github.com-personal:myusername/my-repo.git
git clone git@github.com-work:company/project.git
git clone git@gitlab.com-client1:client/app.git
```

### Configuring Existing Repositories

For repositories already cloned, update the remote URL:

```bash
cd /path/to/your/repo
git remote set-url origin git@github.com-personal:username/repo.git
```

### Listing Accounts

Select option `3` to view all configured Git accounts.

### Getting SSH Public Key

If you need to retrieve your SSH public key (e.g., to add to another Git provider or verify it):

1. Select option `4` from the main menu
2. Choose the account name
3. The public key will be displayed and automatically copied to your clipboard (on macOS/Linux)

### Fixing Repository Remote URL

If you have an existing repository using HTTPS, convert it to SSH:

1. Select option `5` from the main menu
2. Enter the repository path
3. Select the account to use
4. Provide repository details (provider, owner, repo name)
5. The script will update the remote URL and test the connection

### Testing SSH Connection

Verify that your SSH key is properly configured:

1. Select option `6` from the main menu
2. Choose the account and provider
3. The script will test the SSH connection and show the authentication result

### Configuring Git Settings

Set up Git global configuration options:

1. Select option `7` from the main menu
2. Choose from available options:
   - Set default branch name (main/master/trunk)
   - Set global user name and email
   - Disable default branch warning
   - View all git config

### Diagnosing SSH Issues

If you encounter SSH connection problems:

1. Select option `8` from the main menu
2. Enter the account name to diagnose
3. The tool will check:
   - SSH key files existence and permissions
   - SSH config entries
   - SSH agent status
   - Current Git remote configuration
   - Provide specific suggestions to fix issues

### Listing Accounts

Select option `3` to view all configured Git accounts.

### Deleting an Account

1. Select option `2` from the main menu
2. Enter the account name to delete
3. Confirm the deletion (this will remove SSH keys and config entry)

### Restoring a Backup

If you need to restore a previous SSH config:

1. Select option `9` from the main menu
2. Choose from available backup files
3. The script will restore the selected backup

## File Structure

```
~/.ssh/
├── config                          # SSH configuration file
├── id_ed25519_<account-name>       # Private SSH keys
├── id_ed25519_<account-name>.pub   # Public SSH keys
└── backup_git_accounts/            # Backup directory
    └── config-YYYYMMDD-HHMMSS.bak  # Timestamped backups
```

## SSH Config Example

After adding accounts, your `~/.ssh/config` will look like:

```
# ACCOUNT: personal (github)
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal

# ACCOUNT: work (github)
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
```

## Troubleshooting

### "Invalid username or token" or "Password authentication is not supported"

This error means your repository is using HTTPS instead of SSH. You have two options:

**Option 1: Use the built-in fix tool**
1. Run the script: `./git-account-manager.sh`
2. Select option `5` (Fix repository remote URL)
3. Follow the prompts to convert your remote to SSH

**Option 2: Manual fix**
```bash
cd /path/to/your/repo

# Check current remote (will show HTTPS URL)
git remote -v

# Update to SSH format
git remote set-url origin git@github.com-personal:username/repo.git

# Verify the change
git remote -v
```

### Testing SSH Connection

Use option `6` in the menu to test if your SSH key is properly configured with GitHub/GitLab. You should see a success message like:
- GitHub: "Hi username! You've successfully authenticated..."
- GitLab: "Welcome to GitLab, @username!"

### "Using 'master' as the name for the initial branch" Warning

To fix this warning and set your preferred default branch:

1. Run the script: `./git-account-manager.sh`
2. Select option `7` (Configure Git settings)
3. Select option `1` (Set default branch name)
4. Enter your preferred branch name (e.g., `main`)

Or manually run:
```bash
git config --global init.defaultBranch main
```

### Permission Denied Errors

Ensure correct permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_*
```

### SSH Key Not Working

1. Verify the key is added to ssh-agent:
   ```bash
   ssh-add -l
   ```

2. Test the connection:
   ```bash
   ssh -T git@github.com-personal
   ```

3. Add the key manually if needed:
   ```bash
   ssh-add ~/.ssh/id_ed25519_<account-name>
   ```

### Wrong Account Being Used

Make sure you're using the correct host alias when cloning or setting remotes. Check your repository's remote URL:
```bash
git remote -v
```

## Security Notes

- SSH keys are generated with `ed25519` encryption (secure and modern)
- No passphrase is set by default (you can modify the script to add one)
- Backups are created before any config modifications
- Private keys should never be shared or committed to repositories

## Contributing

Feel free to submit issues or pull requests to improve this tool!

## License

MIT License - feel free to use and modify as needed.

## Author

Created to simplify managing multiple Git accounts on a single machine.
