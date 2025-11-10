#!/bin/bash

# === MDH ULTIMATE FINAL INSTALLER ===
# Level: EXTREME
#
# This script must be run with sudo. It provides two entirely different,
# high-impact shell environments for the regular user and the root user.

# --- 1. CONFIGURATION & PREAMBLE ---

# Define colors for the installer script
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[00m' # No Color

# Markers for the config block to make it re-runnable
CONFIG_START_MARKER="# === START MDH ULTIMATE FINAL CONFIG ==="
CONFIG_END_MARKER="# === END MDH ULTIMATE FINAL CONFIG ==="

# --- 2. CRITICAL ROOT CHECK ---
echo -e "${BLUE}Initiating Level 10 Setup...${NC}"
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Full control required.${NC}" 
   echo -e "${YELLOW}Please run with: sudo ./mdh_ultimate_final_installer.sh${NC}"
   exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo -e "${RED}Error: Cannot detect calling user.${NC}"
    echo -e "${YELLOW}Run this using 'sudo' from your normal account, not by logging in as root directly.${NC}"
    exit 1
fi

# Get the user's home directory
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
ROOT_HOME="/root"

# Define target files
USER_BASHRC="$USER_HOME/.bashrc"
ROOT_BASHRC="$ROOT_HOME/.bashrc"

cat << "EOF"

 █▀█ █▄█ █░█ █▀▀ █▀█ ▀█▀ ▀█▀ █▀█ █▀█ 
 █▀▀ ░█░ █▄█ █▄▄ █▀▄ ░█░ ░█░ █▄█ █▀▄ 
 
 FINAL VERSION
 EOF
echo -e "${GREEN}Configuring User: ${SUDO_USER} | Root: System${NC}"


# --- 3. EXTREME TOOL INSTALLATION ---

echo -e "${YELLOW}Installing core dependencies (eza, bat, fzf, zoxide, ripgrep, tldr)...${NC}"
# Adding zoxide, ripgrep, tldr for true power-user experience
local_tools="figlet toilet lolcat pv cmatrix neofetch htop bat eza fzf zoxide ripgrep tldr"
apt-get update -y > /dev/null 2>&1
apt-get install -y $local_tools > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Critical tool installation failed. Manual intervention required.${NC}"
    exit 1
fi

# Symlinks and Zoxide setup
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    ln -s /usr/bin/batcat /usr/local/bin/bat
fi
# Initialize zoxide (fast directory switcher)
echo -e "${YELLOW}Initializing zoxide integration...${NC}"
chown $SUDO_USER:$SUDO_USER $USER_HOME

echo -e "${GREEN}All systems operational.${NC}"


# --- 4. BACKUP AND CLEANUP ---

echo -e "${YELLOW}Backing up existing configurations and removing old MDH blocks...${NC}"
cp $USER_BASHRC "$USER_BASHRC.mdh_backup_$(date +%F-%T)"
cp $ROOT_BASHRC "$ROOT_BASHRC.mdh_backup_$(date +%F-%T)"

# Remove old configs
sed -i "/$CONFIG_START_MARKER/,/$CONFIG_END_MARKER/d" $USER_BASHRC
sed -i "/$CONFIG_START_MARKER/,/$CONFIG_END_MARKER/d" $ROOT_BASHRC

echo -e "${GREEN}Cleanup complete.${NC}"


# --- 5. DEFINE USER CONFIG (BLUE/GLITCH) ---

# User Config: Short, sharp glitch and blue/cyan prompt theme
read -r -d '' USER_CONFIG << 'EOF'
# === START MDH ULTIMATE FINAL CONFIG ===

# --- 1. SHORT, SHARP GLITCH ANIMATION ---
function glitch_mdh() {
    clear
    tput civis # Hide cursor
    local colors=('\033[0;36m' '\033[1;34m' '\033[0;37m') # Cyan, Bright Blue, White

    # Quick 10-frame glitch
    for i in {1..10}; do
        local rand_y=$((RANDOM % 15 + 1))
        local rand_x=$((RANDOM % 50))
        local rand_color_idx=$((RANDOM % ${#colors[@]}))
        local text="MDH"
        if (( i % 2 == 0 )); then text="[#$i]"; fi
        echo -en "$(tput cup $rand_y $rand_x)${colors[$rand_color_idx]}$text\033[0m"
        sleep 0.01
    done
    
    # Final Logo Phase (Animated Rainbow)
    clear
    echo "MDH" | toilet -f future | lolcat -a -d 5 -p 150
    echo ""
    
    # Welcome Message (Cyan/Blue)
    WELCOME_MSG="[USER_LEVEL] Initializing Cloud Core v3.0 | Status: Operational"
    echo "$WELCOME_MSG" | pv -qL 120 | lolcat -f
    echo "------------------------------------------------------------" | lolcat -p 10 -F 0.5
    echo ""
    tput cnorm # Show cursor
}

# --- 2. RUN WELCOME ON INTERACTIVE SHELL ---
if [[ $- == *i* && $SHLVL -eq 1 ]]; then
    glitch_mdh
fi

# --- 3. POWER ALIASES & TOOLS ---
alias ls='eza --icons --color=auto --group-directories-first'
alias ll='eza -l --icons --color=auto --group-directories-first'
alias l='eza -lFbhH --icons --color=auto --git --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='rg --color=always' # Use ripgrep
alias matrix='cmatrix -s -b -C cyan'
alias info='neofetch'
alias htop='htop'
alias cd='zoxide' # Use zoxide for 'cd' (faster navigation)
alias z='zoxide'
alias man='tldr' # Use tldr for simplified man pages

# --- 4. BLUE/CYAN POWER PROMPT (PS1) ---
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
MAGENTA='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NC='\[\033[00m\]'

parse_git_branch() {
    # Check if inside a git repo and show branch in magenta
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ('$MAGENTA'\1'$NC')/'
}

build_user_prompt() {
    local exit_code=$?
    local prompt_symbol
    
    # Dynamic prompt symbol: CYAN >> on success, RED X>> on failure
    if [ $exit_code -eq 0 ]; then
        prompt_symbol="$CYAN>>$NC"
    else
        prompt_symbol="$RED\e[7m X \e[27m$NC" # Inverted Red X on failure
    fi
    
    # Line 1: [user@host] (GCloud_Project_ID)
    PS1="$BLUE[${CYAN}\u$BLUE@\h$BLUE]$NC "
    PS1+="$YELLOW(\$CLOUD_SHELL_PROJECT_ID)$NC"
    
    # Line 2: Blue Path, Git Status, Prompt Symbol
    PS1+="\n"
    PS1+="$BLUE\w$NC"
    PS1+="\$(parse_git_branch)"
    PS1+=" $prompt_symbol "
}

PROMPT_COMMAND="build_user_prompt"
# Zoxide and fzf initialization
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
eval "$(zoxide init bash --cmd cd)"

# === END MDH ULTIMATE FINAL CONFIG ===
EOF


# --- 6. DEFINE ROOT CONFIG (ACTIVE/MULTI-COLOR DANGER) ---

# Root Config: Complex multi-color prompt with dynamic [ACTIVE] sign
read -r -d '' ROOT_CONFIG << 'EOF'
# === START MDH ULTIMATE FINAL CONFIG ===

# --- 1. ROOT WELCOME (Multi-color warning) ---
function root_welcome() {
    clear
    local red_color='\033[0;31m'
    local bright_red_color='\033[1;31m'
    local yellow_color='\033[1;33m'
    local nc='\033[0m'
    
    echo -e "$bright_red_color"
    toilet -f small "SYSTEM CORE"
    echo -e "$red_color============================================"
    echo -e "$yellow_color          CRITICAL PRIVILEGE LEVEL ACTIVE"
    echo -e "$bright_red_color   Log all actions. Damage potential: Maximum."
    echo -e "$red_color============================================$nc"
    echo ""
}

if [[ $- == *i* && $SHLVL -eq 1 ]]; then
    root_welcome
fi

# --- 2. ROOT ALIASES (Tools are the same, aliases are practical) ---
alias ls='eza --icons --color=auto --group-directories-first'
alias ll='eza -l --icons --color=auto --group-directories-first'
alias l='eza -lFbhH --icons --color=auto --git --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='rg --color=always'
alias htop='htop'
alias z='zoxide'

# --- 3. ROOT "ACTIVE" PROMPT (PS1) ---
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
MAGENTA='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NC='\[\033[00m\]'

build_root_prompt() {
    local exit_code=$?
    local ACTIVE_SIGN=""
    local DANGER_ZONE="$MAGENTA[SYSTEM CORE]$NC"
    
    # Dynamic Active Sign: Flashing Red/Yellow/Green based on status
    if [ $exit_code -eq 0 ]; then
        # Green on success: Flashing, Bold, High Contrast
        ACTIVE_SIGN="$GREEN\e[5m\e[1m\e[40m[ S O K ]\e[49m\e[25m\e[22m$NC"
    else
        # Red on failure: Flashing, Bold, High Contrast
        ACTIVE_SIGN="$RED\e[5m\e[1m\e[40m[ D A N G E R ]\e[49m\e[25m\e[22m$NC"
    fi
    
    # Format: [ACTIVE] | [SYSTEM CORE] | [user@host] | /current/dir # 
    PS1="$ACTIVE_SIGN $BLUE|$NC $DANGER_ZONE $BLUE|$NC $RED\u$NC@$RED\h$NC $BLUE|$NC $YELLOW\w$NC $RED\#$NC "
}

PROMPT_COMMAND="build_root_prompt"
# Zoxide initialization for root
eval "$(zoxide init bash --cmd cd)"

# === END MDH ULTIMATE FINAL CONFIG ===
EOF


# --- 7. INJECT CONFIGURATIONS AND FINALIZE ---

echo -e "${YELLOW}Injecting configurations...${NC}"

# Inject user config (written by root, owned by user)
echo "$USER_CONFIG" >> $USER_BASHRC
# Inject root config (written by root, owned by root)
echo "$ROOT_CONFIG" >> $ROOT_BASHRC

# Fix permissions on the user's file
chown $SUDO_USER:$SUDO_USER $USER_BASHRC

echo -e "${GREEN}SYSTEM: Configuration Deployment Successful.${NC}"
echo -e "${WHITE}--------------------------------------------------${NC}"
echo -e "To view the final results:"
echo -e " 1. ${YELLOW}Exit and start a new Cloud Shell tab${NC} for your blue/glitch theme."
echo -e " 2. Type ${YELLOW}'sudo su -'${NC} to enter the Red/Yellow 'SYSTEM CORE' with the flashing active sign."
echo -e "${WHITE}--------------------------------------------------${NC}"

# The script does not use 'exec bash' here because 'sudo' is still active, 
# which would reload the root shell. The user must manually start a new terminal.
exit 0
