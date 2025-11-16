# Publishing to Homebrew Tap

This guide explains how to publish the Git Account Manager as a Homebrew package.

## Prerequisites

1. A GitHub account
2. Homebrew installed on macOS
3. Git configured on your machine

## Step 1: Create a GitHub Repository

If not already done, create a GitHub repository for this project:

```bash
cd /Users/amolchavan/git-account-manager
git init
git add .
git commit -m "Initial commit: Git Account Manager v1.0.0"
git branch -M main
git remote add origin git@github.com-yuyutsu:Yuyutsu/git-account-manager.git
git push -u origin main
```

## Step 2: Create a Release

1. Go to your GitHub repository: `https://github.com/Yuyutsu/git-account-manager`
2. Click on "Releases" → "Create a new release"
3. Create a new tag: `v1.0.0`
4. Release title: `Git Account Manager v1.0.0`
5. Description:
   ```
   Initial release of Git Account Manager
   
   Features:
   - Add/delete multiple Git accounts
   - Manage SSH keys for GitHub/GitLab
   - Fix HTTPS to SSH remote URLs
   - Test SSH connections
   - Configure Git settings
   - Automatic backup and restore
   ```
6. Click "Publish release"

## Step 3: Calculate SHA256 Hash

After creating the release, download the tarball and calculate its SHA256:

```bash
# Download the release tarball
curl -L -o git-account-manager-1.0.0.tar.gz \
  https://github.com/Yuyutsu/git-account-manager/archive/refs/tags/v1.0.0.tar.gz

# Calculate SHA256
shasum -a 256 git-account-manager-1.0.0.tar.gz
```

Copy the SHA256 hash and update it in `git-account-manager.rb` formula.

## Step 4: Create Homebrew Tap Repository

Create a new repository named `homebrew-tap`:

```bash
# Create the tap repository locally
cd ~/
mkdir -p homebrew-tap/Formula
cd homebrew-tap

# Copy the formula
cp /Users/amolchavan/git-account-manager/git-account-manager.rb Formula/

# Initialize git
git init
git add .
git commit -m "Add git-account-manager formula"
git branch -M main

# Create repository on GitHub named 'homebrew-tap'
# Then push:
git remote add origin git@github.com-yuyutsu:Yuyutsu/homebrew-tap.git
git push -u origin main
```

## Step 5: Update the Formula with SHA256

Edit `Formula/git-account-manager.rb` and add the SHA256 hash:

```ruby
sha256 "paste_your_calculated_sha256_here"
```

Commit and push:

```bash
git add Formula/git-account-manager.rb
git commit -m "Update SHA256 hash"
git push
```

## Step 6: Test Installation Locally

Test the formula before publishing:

```bash
# Install from local formula
brew install --build-from-source ./Formula/git-account-manager.rb

# Or test from your tap
brew tap amolchavan/tap https://github.com/Yuyutsu/homebrew-tap
brew install amolchavan/tap/git-account-manager

# Test it works
git-account-manager
```

## Step 7: Publish Instructions for Users

Users can now install your tool with:

```bash
# Tap your repository
brew tap Yuyutsu/tap

# Install the package
brew install git-account-manager

# Run the tool
git-account-manager
```

## Updating the Formula

When you release a new version:

1. Create a new release on GitHub (e.g., v1.1.0)
2. Download the new tarball and calculate SHA256
3. Update `Formula/git-account-manager.rb`:
   - Update `version`
   - Update `url` with new tag
   - Update `sha256` with new hash
4. Commit and push changes
5. Users can upgrade with: `brew upgrade git-account-manager`

## Alternative: Submit to Homebrew Core

To submit to the official Homebrew repository:

1. Your tool must be notable (popular/widely used)
2. Follow Homebrew's [Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae) guidelines
3. Submit a PR to [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core)

For most personal/smaller tools, using a tap (as described above) is the recommended approach.

## Directory Structure

Your tap repository should look like:

```
homebrew-tap/
├── Formula/
│   └── git-account-manager.rb
└── README.md (optional)
```

## Useful Commands

```bash
# Audit formula for issues
brew audit --strict git-account-manager

# Test formula
brew test git-account-manager

# Uninstall
brew uninstall git-account-manager

# Untap
brew untap amolchavan/tap
```

## Troubleshooting

### Formula not found
- Ensure repository is named `homebrew-tap` (or `homebrew-something`)
- Check the tap is added: `brew tap`

### SHA256 mismatch
- Recalculate SHA256 from the exact release tarball
- Ensure URL points to the correct release tag

### Installation fails
- Run `brew audit --strict git-account-manager.rb` to check for issues
- Check formula syntax: `brew install --verbose --debug git-account-manager`

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [How to Create Homebrew Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Homebrew Formula Reference](https://rubydoc.brew.sh/Formula)
