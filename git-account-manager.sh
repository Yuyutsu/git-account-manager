#!/bin/bash

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
BACKUP_DIR="$SSH_DIR/backup_git_accounts"

mkdir -p "$SSH_DIR"
touch "$SSH_CONFIG"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_CONFIG"

GREEN=$'\e[32m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
NC=$'\e[0m'

function backup_config() {
    mkdir -p "$BACKUP_DIR"
    cp "$SSH_CONFIG" "$BACKUP_DIR/config-$(date +%Y%m%d-%H%M%S).bak"
}

function list_accounts() {
    echo -e "\n${BLUE}========= CONFIGURED GIT ACCOUNTS =========${NC}"
    grep "# ACCOUNT:" "$SSH_CONFIG" | sed 's/# ACCOUNT: //g'
    echo -e "${BLUE}===========================================${NC}\n"
}

function add_account() {
    echo -e "\n${GREEN}----- ADD NEW GIT ACCOUNT -----${NC}"

    read -p "Account name (ex: personal, work, client1): " ACC_NAME
    read -p "Provider (github/gitlab): " PROVIDER
    read -p "Email for this account: " EMAIL

    KEY_FILE="$SSH_DIR/id_ed25519_$ACC_NAME"
    HOST_ALIAS="${PROVIDER}.com-$ACC_NAME"

    if [[ -f "$KEY_FILE" ]]; then
        echo -e "${RED}Account with this name already exists! Choose another.${NC}"
        return
    fi

    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""

    echo "Adding key to ssh-agent..."
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$KEY_FILE"

    echo "Updating SSH config..."
    backup_config

cat <<EOT >> $SSH_CONFIG

# ACCOUNT: $ACC_NAME ($PROVIDER)
Host $HOST_ALIAS
    HostName ${PROVIDER}.com
    User git
    IdentityFile $KEY_FILE

EOT

    echo -e "\n${YELLOW}Copy this key to your $PROVIDER account:${NC}"
    cat "$KEY_FILE.pub"

    echo -e "\nUse this to clone:"
    echo "git clone git@$HOST_ALIAS:username/repo.git"

    echo -e "${GREEN}Account added successfully!${NC}"
}

function delete_account() {
    echo -e "\n${RED}----- DELETE GIT ACCOUNT -----${NC}"
    read -p "Enter account name to delete: " ACC_NAME

    KEY_PRIV="$SSH_DIR/id_ed25519_$ACC_NAME"
    KEY_PUB="$SSH_DIR/id_ed25519_$ACC_NAME.pub"

    if [[ ! -f "$KEY_PRIV" ]]; then
        echo -e "${RED}Account not found!${NC}"
        return
    fi

    read -p "Are you sure? This will delete keys + config entry (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Cancelled."
        return
    fi

    echo "Removing SSH keys..."
    rm -f "$KEY_PRIV" "$KEY_PUB"

    echo "Removing config entry..."
    backup_config
    sed -i.bak "/# ACCOUNT: $ACC_NAME/,/IdentityFile/d" "$SSH_CONFIG"

    echo -e "${GREEN}Account removed successfully.${NC}"
}

function restore_backup() {
    echo -e "\n${BLUE}Available backups:${NC}"
    ls -1 "$BACKUP_DIR"

    read -p "Enter backup filename to restore: " FILE

    if [[ ! -f "$BACKUP_DIR/$FILE" ]]; then
        echo -e "${RED}Backup not found!${NC}"
        return
    fi

    cp "$BACKUP_DIR/$FILE" "$SSH_CONFIG"
    echo -e "${GREEN}Backup restored.${NC}"
}

function fix_repo_remote() {
    echo -e "\n${YELLOW}----- FIX REPOSITORY REMOTE URL -----${NC}"
    echo "This will convert HTTPS remote to SSH for a specific account"
    echo ""
    
    read -p "Enter path to your repository: " REPO_PATH
    
    if [[ ! -d "$REPO_PATH/.git" ]]; then
        echo -e "${RED}Not a valid git repository!${NC}"
        return
    fi
    
    cd "$REPO_PATH" || return
    
    echo -e "\n${BLUE}Current remote URL:${NC}"
    git remote -v
    
    echo -e "\n${BLUE}Available accounts:${NC}"
    grep "# ACCOUNT:" "$SSH_CONFIG" | sed 's/# ACCOUNT: //g'
    
    read -p $'\nEnter account name to use: ' ACC_NAME
    read -p "Enter provider (github/gitlab): " PROVIDER
    read -p "Enter repository owner/username: " OWNER
    read -p "Enter repository name: " REPO_NAME
    
    HOST_ALIAS="${PROVIDER}.com-$ACC_NAME"
    NEW_URL="git@${HOST_ALIAS}:${OWNER}/${REPO_NAME}.git"
    
    echo -e "\n${YELLOW}New URL will be:${NC} $NEW_URL"
    read -p "Proceed? (y/n): " CONFIRM
    
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Cancelled."
        return
    fi
    
    git remote set-url origin "$NEW_URL"
    
    echo -e "\n${GREEN}Remote URL updated!${NC}"
    echo -e "${BLUE}New remote:${NC}"
    git remote -v
    
    echo -e "\n${YELLOW}Testing connection...${NC}"
    ssh -T "git@${HOST_ALIAS}" 2>&1 | head -5
}

function test_connection() {
    echo -e "\n${YELLOW}----- TEST SSH CONNECTION -----${NC}"
    
    echo -e "${BLUE}Available accounts:${NC}"
    grep "# ACCOUNT:" "$SSH_CONFIG" | sed 's/# ACCOUNT: //g'
    
    read -p $'\nEnter account name to test: ' ACC_NAME
    read -p "Enter provider (github/gitlab): " PROVIDER
    
    HOST_ALIAS="${PROVIDER}.com-$ACC_NAME"
    
    echo -e "\n${YELLOW}Testing connection to ${HOST_ALIAS}...${NC}\n"
    ssh -T "git@${HOST_ALIAS}"
}

function get_ssh_key() {
    echo -e "\n${GREEN}----- GET SSH PUBLIC KEY -----${NC}"
    
    echo -e "${BLUE}Available accounts:${NC}"
    grep "# ACCOUNT:" "$SSH_CONFIG" | sed 's/# ACCOUNT: //g'
    
    read -p $'\nEnter account name: ' ACC_NAME
    
    KEY_FILE="$SSH_DIR/id_ed25519_$ACC_NAME.pub"
    
    if [[ ! -f "$KEY_FILE" ]]; then
        echo -e "${RED}SSH key not found for account '$ACC_NAME'!${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}Public SSH Key for '$ACC_NAME':${NC}\n"
    cat "$KEY_FILE"
    
    echo -e "\n${GREEN}Key copied to clipboard (if pbcopy available)${NC}"
    if command -v pbcopy &> /dev/null; then
        cat "$KEY_FILE" | pbcopy
        echo -e "${GREEN}✓ Copied to clipboard!${NC}"
    elif command -v xclip &> /dev/null; then
        cat "$KEY_FILE" | xclip -selection clipboard
        echo -e "${GREEN}✓ Copied to clipboard!${NC}"
    else
        echo -e "${YELLOW}Copy manually from above${NC}"
    fi
    
    echo -e "\n${BLUE}Add this key to your Git provider:${NC}"
    echo "GitHub: Settings → SSH and GPG keys → New SSH key"
    echo "GitLab: Preferences → SSH Keys → Add new key"
}

function diagnose_ssh_config() {
    echo -e "\n${BLUE}----- DIAGNOSE SSH CONFIGURATION -----${NC}"
    
    echo -e "\n${YELLOW}Checking SSH configuration for account...${NC}"
    read -p "Enter account name to diagnose: " ACC_NAME
    
    KEY_PRIV="$SSH_DIR/id_ed25519_$ACC_NAME"
    KEY_PUB="$SSH_DIR/id_ed25519_$ACC_NAME.pub"
    
    echo -e "\n${BLUE}1. Checking SSH Keys:${NC}"
    if [[ -f "$KEY_PRIV" ]]; then
        echo -e "  ${GREEN}✓${NC} Private key exists: $KEY_PRIV"
        ls -l "$KEY_PRIV" | awk '{print "    Permissions: " $1}'
    else
        echo -e "  ${RED}✗${NC} Private key NOT found: $KEY_PRIV"
    fi
    
    if [[ -f "$KEY_PUB" ]]; then
        echo -e "  ${GREEN}✓${NC} Public key exists: $KEY_PUB"
    else
        echo -e "  ${RED}✗${NC} Public key NOT found: $KEY_PUB"
    fi
    
    echo -e "\n${BLUE}2. Checking SSH Config Entries:${NC}"
    if grep -q "# ACCOUNT: $ACC_NAME" "$SSH_CONFIG"; then
        echo -e "  ${GREEN}✓${NC} Account entry found in SSH config"
        echo -e "\n${YELLOW}Config block:${NC}"
        sed -n "/# ACCOUNT: $ACC_NAME/,/^$/p" "$SSH_CONFIG" | sed 's/^/    /'
    else
        echo -e "  ${RED}✗${NC} Account entry NOT found in SSH config"
        echo -e "  ${YELLOW}This is likely why you're getting 'Could not resolve hostname' error${NC}"
    fi
    
    echo -e "\n${BLUE}3. Checking SSH Agent:${NC}"
    if ssh-add -l | grep -q "$KEY_PRIV"; then
        echo -e "  ${GREEN}✓${NC} Key is loaded in ssh-agent"
    else
        echo -e "  ${YELLOW}○${NC} Key is NOT loaded in ssh-agent"
        echo -e "    Run: ssh-add $KEY_PRIV"
    fi
    
    echo -e "\n${BLUE}4. All Configured Accounts:${NC}"
    if grep -q "# ACCOUNT:" "$SSH_CONFIG"; then
        grep "# ACCOUNT:" "$SSH_CONFIG" | sed 's/# ACCOUNT: //g' | sed 's/^/    /'
    else
        echo -e "  ${YELLOW}No accounts configured yet${NC}"
    fi
    
    echo -e "\n${BLUE}5. Current Git Remote (if in a repo):${NC}"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git remote -v | sed 's/^/    /' || echo "    No remotes configured"
    else
        echo "    Not in a git repository"
    fi
    
    echo -e "\n${YELLOW}Suggestions:${NC}"
    if [[ ! -f "$KEY_PRIV" ]]; then
        echo "  • Run option 1 to add this account"
    elif ! grep -q "# ACCOUNT: $ACC_NAME" "$SSH_CONFIG"; then
        echo "  • SSH key exists but config entry is missing"
        echo "  • Try deleting and re-adding the account"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

function configure_git_settings() {
    echo -e "\n${BLUE}----- CONFIGURE GIT SETTINGS -----${NC}"
    
    echo -e "\n${YELLOW}Current Git Global Configuration:${NC}"
    echo -e "${BLUE}Default Branch:${NC} $(git config --global init.defaultBranch 2>/dev/null || echo 'not set (uses master)')"
    echo -e "${BLUE}User Name:${NC} $(git config --global user.name 2>/dev/null || echo 'not set')"
    echo -e "${BLUE}User Email:${NC} $(git config --global user.email 2>/dev/null || echo 'not set')"
    
    echo -e "\n${YELLOW}What would you like to configure?${NC}"
    echo "1. Set default branch name (main/master/trunk)"
    echo "2. Set global user name and email"
    echo "3. Disable default branch warning"
    echo "4. View all git config"
    echo "5. Back to main menu"
    
    read -p "Select option (1-5): " CONFIG_OPTION
    
    case $CONFIG_OPTION in
        1)
            echo -e "\n${BLUE}Common branch names:${NC}"
            echo "  - main (modern standard)"
            echo "  - master (traditional)"
            echo "  - trunk"
            echo "  - development"
            
            read -p $'\nEnter default branch name [main]: ' BRANCH_NAME
            BRANCH_NAME=${BRANCH_NAME:-main}
            
            git config --global init.defaultBranch "$BRANCH_NAME"
            echo -e "${GREEN}✓ Default branch set to '$BRANCH_NAME'${NC}"
            ;;
        2)
            echo -e "\n${YELLOW}Note: This sets GLOBAL git config.${NC}"
            echo "For per-account config, set locally in each repo with:"
            echo "  git config user.name 'Your Name'"
            echo "  git config user.email 'your@email.com'"
            
            read -p $'\nEnter your name: ' GIT_NAME
            read -p "Enter your email: " GIT_EMAIL
            
            if [[ -n "$GIT_NAME" ]]; then
                git config --global user.name "$GIT_NAME"
                echo -e "${GREEN}✓ Global user name set to '$GIT_NAME'${NC}"
            fi
            
            if [[ -n "$GIT_EMAIL" ]]; then
                git config --global user.email "$GIT_EMAIL"
                echo -e "${GREEN}✓ Global user email set to '$GIT_EMAIL'${NC}"
            fi
            ;;
        3)
            git config --global advice.defaultBranchName false
            echo -e "${GREEN}✓ Default branch warning disabled${NC}"
            ;;
        4)
            echo -e "\n${BLUE}Global Git Configuration:${NC}"
            git config --global --list
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

while true; do
    echo -e "${BLUE}"
    echo "====================================="
    echo "     MULTI GIT ACCOUNT MANAGER"
    echo "====================================="
    echo "1. Add new Git account"
    echo "2. Delete existing Git account"
    echo "3. List accounts"
    echo "4. Get SSH public key"
    echo "5. Fix repository remote URL"
    echo "6. Test SSH connection"
    echo "7. Configure Git settings"
    echo "8. Diagnose SSH issues"
    echo "9. Restore config backup"
    echo "10. Exit"
    echo "====================================="
    echo -e "${NC}"

    read -p "Select option (1-10): " OPTION

    case $OPTION in
        1) add_account ;;
        2) delete_account ;;
        3) list_accounts ;;
        4) get_ssh_key ;;
        5) fix_repo_remote ;;
        6) test_connection ;;
        7) configure_git_settings ;;
        8) diagnose_ssh_config ;;
        9) restore_backup ;;
        10) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${NC}" ;;
    esac
done
