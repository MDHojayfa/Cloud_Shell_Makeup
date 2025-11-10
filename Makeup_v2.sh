#!/bin/bash

# === MDH ULTIMATE GLITCH INSTALLER ===
#
# This script MUST be run with sudo.
# It will:
# 1. Detect the regular user (SUDO_USER) and the root user.
# 2. Install "hacker" tools: eza, bat, neofetch, fzf, figlet, lolcat, etc.
# 3. Install a "GLITCH" theme for the regular user.
# 4. Install a "DANGER/ROOT" theme for the root user.
#

# --- 1. CONFIGURATION & PREAMBLE ---

# Define colors for the installer script
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[00m' # No Color

# Markers for the config block to make it re-runnable
CONFIG_START_MARKER="# === START MDH ULTIMATE SHELL CONFIG ==="
CONFIG_END_MARKER="# === END MDH ULTIMATE SHELL CONFIG ==="

# --- 2. CRITICAL ROOT CHECK ---
echo -e "${BLUE}Checking permissions...${NC}"
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root to configure both user and root shells.${NC}" 
   echo -e "${YELLOW}Please run with: sudo ./mdh_ultimate_installer.sh${NC}"
   exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo -e "${RED}Error: SUDO_USER variable is not set.${NC}"
    echo -e "${YELLOW}Please run this using 'sudo' from a normal user account, not by logging in as root directly.${NC}"
    exit 1
fi

# Get the user's home directory
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
ROOT_HOME="/root"

# Define target files
USER_BASHRC="$USER_HOME/.bashrc"
ROOT_BASHRC="$ROOT_HOME/.bashrc"

cat << "EOF"

  __  __  ____  _   _ 
 |  \/  |/ ___|| | | |
 | |\/| | |  _ | |_| |
 | |  | | |_| ||  _  |
 |_|  |_|\____||_| |_|
 
 ULTIMATE GLITCH INSTALLER

EOF
echo -e "${GREEN}Running as root. Will configure user '${SUDO_USER}' and 'root' separately.${NC}"


# --- 3. TOOL INSTALLATION ---

echo -e "${YELLOW}Updating package lists and installing necessary tools...${NC}"
echo -e "${YELLOW}(This will take a moment...)${NC}"
apt-get update -y > /dev/null 2>&1
apt-get install -y figlet toilet lolcat pv cmatrix neofetch htop bat eza fzf > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Tool installation failed.${NC}"
    echo -e "${YELLOW}Please check your internet connection and run 'sudo apt-get update' manually.${NC}"
    exit 1
fi

# Create symlink for 'bat' if 'batcat' is installed (common on Ubuntu)
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    echo -e "${YELLOW}Creating symlink for 'batcat' -> 'bat'...${NC}"
    ln -s /usr/bin/batcat /usr/local/bin/bat
fi

echo -e "${GREEN}All tools installed.${NC}"


# --- 4. BACKUP EXISTING CONFIGS ---

echo -e "${YELLOW}Backing up existing configurations...${NC}"
cp $USER_BASHRC "$USER_BASHRC.mdh_backup_$(date +%F-%T)"
cp $ROOT_BASHRC "$ROOT_BASHRC.mdh_backup_$(date +%F-%T)"
echo -e "${GREEN}Backups created.${NC}"


# --- 5. DEFINE CONFIG PAYLOADS ---

# This is the "glitch" theme for the normal user
read -r -d '' USER_CONFIG << 'EOF'

# === START MDH ULTIMATE SHELL CONFIG ===

# --- 1. "GLITCH" ANIMATION FUNCTION ---
# This function runs on every new shell
function glitch_mdh() {
    clear
    local lines=$(tput lines)
    local cols=$(tput cols)
    local colors=('\033[0;32m' '\033[1;32m' '\033[0;37m') # Green, Bright Green, White
    local nc='\033[0m'

    # 1. Glitch Phase
    for i in {1..20}; do
        local rand_y=$((RANDOM % lines))
        local rand_x=$((RANDOM % (cols - 4)))
        local rand_color_idx=$((RANDOM % ${#colors[@]}))
        
        local text="MDH"
        if (( i % 3 == 0 )); then text="M#H"; fi
        if (( i % 5 == 0 )); then text="*D*"; fi
        if (( i % 7 == 0 )); then text="[ ]"; fi

        echo -en "$(tput cup $rand_y $rand_x)${colors[$rand_color_idx]}$text${nc}"
        sleep 0.015
    done
    
    # 2. Stable Logo Phase
    clear
    echo "MDH" | toilet -f slant | lolcat -a -d 5 -p 100
    echo ""
    
    # 3. Welcome Message
    WELCOME_MSG="Welcome, $(whoami). System online. All modules loaded."
    echo "$WELCOME_MSG" | pv -qL 100 | lolcat -p 7
    echo "------------------------------------------------------------" | lolcat -p 10
    echo "Type 'info' for system details, 'matrix' for fun, or 'l' for files."
    echo ""
}

# --- 2. RUN WELCOME ON INTERACTIVE SHELL ---
if [[ $- == *i* && $SHLVL -eq 1 ]]; then
    glitch_mdh
fi

# --- 3. "HACKER VIBE" ALIASES ---
alias ls='eza --icons --color=auto --group-directories-first'
alias ll='eza -l --icons --color=auto --group-directories-first'
alias l='eza -lFbhH --icons --color=auto --git --group-directories-first'
alias la='eza -la --icons --color=auto --group-directories-first'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias matrix='cmatrix -s -b -C green'
alias info='neofetch'
alias myip='curl ifconfig.me ; echo'
alias htop='htop'
alias ffind='fzf'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'

# --- 4. "HACKER VIBE" PROMPT (PS1) ---
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
MAGENTA='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NC='\[\033[00m\]'

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ('$MAGENTA'\1'$NC')/'
}

build_prompt() {
    local exit_code=$?
    local prompt_symbol
    if [ $exit_code -eq 0 ]; then
        prompt_symbol="$GREEN❯$NC"
    else
        prompt_symbol="$RED❯$NC"
    fi
    
    # Line 1: [user@host] (Cloud_Project_ID)
    PS1="$CYAN\u@\h$NC "
    PS1+="$YELLOW(\$CLOUD_SHELL_PROJECT_ID)$NC"
    
    # Line 2: └──[directory][git_branch] ❯
    PS1+="\n"
    PS1+="$WHITE└──$NC $BLUE\w$NC"
    PS1+="\$(parse_git_branch)"
    PS1+=" $prompt_symbol "
}

PROMPT_COMMAND="build_prompt"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# === END MDH ULTIMATE SHELL CONFIG ===
EOF


# This is the "danger" theme for the root user
read -r -d '' ROOT_CONFIG << 'EOF'

# === START MDH ULTIMATE SHELL CONFIG ===

# --- 1. ROOT WELCOME ---
# Aggressive, no animation, all red.
function root_welcome() {
    clear
    local red_color='\033[0;31m'
    local bright_red_color='\033[1;31m'
    local nc='\033[0m'
    
    echo -e "$bright_red_color"
    toilet -f small "ROOT ACCESS"
    echo -e "$red_color============================================"
    echo -e "$bright_red_color          SYSTEM PRIVILEGES ESCALATED"
    echo -e "$red_color   All actions are permanent. Handle with extreme care."
    echo -e "============================================$nc"
    echo ""
}

if [[ $- == *i* && $SHLVL -eq 1 ]]; then
    root_welcome
fi

# --- 2. ROOT ALIASES ---
# Practical, no "fun" aliases.
alias ls='eza --icons --color=auto --group-directories-first'
alias ll='eza -l --icons --color=auto --group-directories-first'
alias l='eza -lFbhH --icons --color=auto --git --group-directories-first'
alias la='eza -la --icons --color=auto --group-directories-first'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias htop='htop'

# --- 3. ROOT "DANGER" PROMPT ---
# Single line, all red, impossible to ignore.
PS1='\[\033[01;31m\]\u@\h:\w\$\[\033[00m\] '

# === END MDH ULTIMATE SHELL CONFIG ===
EOF


# --- 6. INJECT CONFIGURATIONS ---

echo -e "${YELLOW}Injecting configurations...${NC}"

# Remove old configs first (makes script re-runnable)
sed -i "/$CONFIG_START_MARKER/,/$CONFIG_END_MARKER/d" $USER_BASHRC
sed -i "/$CONFIG_START_MARKER/,/$CONFIG_END_MARKER/d" $ROOT_BASHRC

# Inject new configs
echo "$USER_CONFIG" >> $USER_BASHRC
echo "$ROOT_CONFIG" >> $ROOT_BASHRC

# Fix permissions on the user's file (since root just wrote to it)
chown $SUDO_USER:$SUDO_USER $USER_BASHRC

echo -e "${GREEN}Configurations injected successfully.${NC}"


# --- 7. FINAL MESSAGE ---
echo -e "${GREEN}Success! Your 'ultra-power' shell is installed.${NC}"
echo -e "${WHITE}--------------------------------------------------${NC}"
echo -e "To see the changes:"
echo -e " 1. ${YELLOW}Log out and log back in${NC} to your user account."
echo -e " 2. Type ${YELLOW}'sudo su -'${NC} to see the new root theme."
echo -e "${WHITE}--------------------------------------------------${NC}"

exit 0
