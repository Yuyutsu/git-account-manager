# Prerequisites

Before using the Git Account Manager, ensure your system meets the following requirements:

## Operating System

- **macOS** (tested on macOS 10.12+)
- **Linux** (Ubuntu, Debian, Fedora, CentOS, etc.)
- **Windows** (via WSL - Windows Subsystem for Linux)

## Required Software

### 1. Bash Shell
- **Version**: 4.0 or higher recommended
- **Check version**:
  ```bash
  bash --version
  ```
- **Installation**: Usually pre-installed on macOS and Linux

### 2. Git
- **Version**: 2.0 or higher
- **Check version**:
  ```bash
  git --version
  ```
- **Installation**:
  ```bash
  # macOS (using Homebrew)
  brew install git
  
  # Ubuntu/Debian
  sudo apt-get update
  sudo apt-get install git
  
  # Fedora
  sudo dnf install git
  
  # CentOS/RHEL
  sudo yum install git
  ```

### 3. SSH Tools
The following tools should be pre-installed on most systems:

#### ssh-keygen
- Used to generate SSH key pairs
- **Check availability**:
  ```bash
  which ssh-keygen
  ```
- Usually comes with OpenSSH

#### ssh-agent
- Manages SSH keys in memory
- **Check availability**:
  ```bash
  which ssh-agent
  ```
- Usually comes with OpenSSH

#### ssh-add
- Adds private keys to ssh-agent
- **Check availability**:
  ```bash
  which ssh-add
  ```
- Usually comes with OpenSSH

### 4. OpenSSH
- **Minimum version**: OpenSSH 6.5+ (for ed25519 support)
- **Check version**:
  ```bash
  ssh -V
  ```
- **Installation** (if needed):
  ```bash
  # macOS (using Homebrew)
  brew install openssh
  
  # Ubuntu/Debian
  sudo apt-get install openssh-client
  
  # Fedora
  sudo dnf install openssh
  ```

## Optional Tools

### 1. Clipboard Utilities (for auto-copying SSH keys)

#### macOS
- **pbcopy** - Pre-installed on macOS
- **Check availability**:
  ```bash
  which pbcopy
  ```

#### Linux
- **xclip** - For X11-based systems
- **Installation**:
  ```bash
  # Ubuntu/Debian
  sudo apt-get install xclip
  
  # Fedora
  sudo dnf install xclip
  
  # Arch Linux
  sudo pacman -S xclip
  ```

- **wl-clipboard** - For Wayland-based systems (alternative)
- **Installation**:
  ```bash
  # Ubuntu/Debian
  sudo apt-get install wl-clipboard
  
  # Fedora
  sudo dnf install wl-clipboard
  ```

## Permissions

Ensure you have the following permissions:

1. **Read/Write access** to `~/.ssh/` directory
2. **Ability to execute** bash scripts
3. **Network access** to GitHub/GitLab (for SSH connection tests)

## GitHub/GitLab Account

You'll need:
- An active GitHub and/or GitLab account
- Permission to add SSH keys to your account
- Access to account settings

### GitHub
- Navigate to: **Settings → SSH and GPG keys**
- Requires: GitHub account (free or paid)

### GitLab
- Navigate to: **Preferences → SSH Keys**
- Requires: GitLab account (free or paid)

## Verification Script

Run this script to verify all prerequisites:

```bash
#!/bin/bash

echo "Checking prerequisites for Git Account Manager..."
echo ""

# Check Bash
if command -v bash &> /dev/null; then
    echo "✓ Bash: $(bash --version | head -n1)"
else
    echo "✗ Bash: NOT FOUND"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✓ Git: $(git --version)"
else
    echo "✗ Git: NOT FOUND"
fi

# Check SSH tools
if command -v ssh-keygen &> /dev/null; then
    echo "✓ ssh-keygen: FOUND"
else
    echo "✗ ssh-keygen: NOT FOUND"
fi

if command -v ssh-agent &> /dev/null; then
    echo "✓ ssh-agent: FOUND"
else
    echo "✗ ssh-agent: NOT FOUND"
fi

if command -v ssh-add &> /dev/null; then
    echo "✓ ssh-add: FOUND"
else
    echo "✗ ssh-add: NOT FOUND"
fi

# Check OpenSSH
if command -v ssh &> /dev/null; then
    echo "✓ OpenSSH: $(ssh -V 2>&1)"
else
    echo "✗ OpenSSH: NOT FOUND"
fi

# Check clipboard tools (optional)
echo ""
echo "Optional tools:"
if command -v pbcopy &> /dev/null; then
    echo "✓ pbcopy: FOUND (macOS clipboard)"
elif command -v xclip &> /dev/null; then
    echo "✓ xclip: FOUND (Linux clipboard)"
else
    echo "○ Clipboard tool: NOT FOUND (SSH keys will be displayed but not auto-copied)"
fi

# Check .ssh directory
echo ""
if [ -d "$HOME/.ssh" ]; then
    echo "✓ ~/.ssh directory exists"
    ls -ld "$HOME/.ssh" | awk '{print "  Permissions: " $1}'
else
    echo "○ ~/.ssh directory will be created automatically"
fi

echo ""
echo "Prerequisite check complete!"
```

Save this as `check-prerequisites.sh`, make it executable with `chmod +x check-prerequisites.sh`, and run it with `./check-prerequisites.sh`.

## Common Issues

### Issue: "bash: command not found"
- **Solution**: Install bash or check your PATH variable

### Issue: "Permission denied" when accessing ~/.ssh
- **Solution**: 
  ```bash
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/*
  ```

### Issue: ssh-keygen doesn't support ed25519
- **Solution**: Update OpenSSH to version 6.5 or higher

## Next Steps

Once all prerequisites are met:
1. Download or clone the Git Account Manager
2. Make the script executable: `chmod +x git-account-manager.sh`
3. Run the script: `./git-account-manager.sh`

For detailed usage instructions, see [README.md](README.md).
