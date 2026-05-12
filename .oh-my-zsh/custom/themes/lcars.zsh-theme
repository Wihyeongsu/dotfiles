# LCARS Theme for Oh My Zsh
# Inspired by the Star Trek: The Next Generation computer interface
# Author: Liam Gulliver
# 
# Requirements:
# - A Nerd Font (https://www.nerdfonts.com/) for icon support
#
# Installation:
# Copy this file to ~/.oh-my-zsh/custom/themes/lcars.zsh-theme
# Then set ZSH_THEME="lcars" in your ~/.zshrc

# Color definitions (LCARS palette - authentic colors)
LCARS_ORANGE="%F{208}"      # Bright orange/gold
LCARS_PINK="%F{213}"        # Pink/magenta
LCARS_BLUE="%F{111}"        # Light blue/periwinkle  
LCARS_PURPLE="%F{183}"      # Lavender
LCARS_YELLOW="%F{221}"      # Soft yellow
LCARS_RED="%F{203}"         # LCARS red/salmon
LCARS_PEACH="%F{216}"       # Peach/tan
LCARS_WHITE="%F{255}"       # White
LCARS_BLACK="%F{232}"       # Black/dark gray
LCARS_ALERT_RED="%F{196}"  # Bright red for alerts
RESET="%f"

# Background colors
BG_ORANGE="208"
BG_PINK="213"
BG_BLUE="111"
BG_PURPLE="183"
BG_PEACH="216"
BG_LCARS_LABEL="234"
BG_ALERT_RED="196"

# Icons (Nerd Fonts required)
ICON_USER=$'\uf007'  # 
ICON_FOLDER=$'\uf07c'  # 
ICON_GIT=$'\ue725'  # 
ICON_TIME=$'\uf017'  # 
ICON_TIMER=$'\uf2f2'  # 
ICON_SSH=$'\uf489'  # 
ICON_CHECK=$'\uf00c'  # 
ICON_CROSS=$'\uf00d'  # 

# Hooks for timing
autoload -Uz add-zsh-hook
typeset -g LCARS_CMD_START=0
typeset -g LCARS_LAST_DURATION=""

# OS-specific icons
if [[ "$(uname)" == "Darwin" ]]; then
    ICON_OS=$'\uf179'  #  Apple logo for macOS
elif [[ "$(uname)" == "Linux" ]]; then
    ICON_OS=$'\uf17c'  #  Linux/Tux penguin
else
    ICON_OS=$'\uf17a'  #  Windows logo
fi

# Capture command start time
lcars_preexec() {
    LCARS_CMD_START=$EPOCHREALTIME
}

# Compute last command duration
lcars_precmd() {
    if (( LCARS_CMD_START > 0 )); then
        local now=$EPOCHREALTIME
        local delta=$(( now - LCARS_CMD_START ))
        LCARS_CMD_START=0
        # Format: >10s -> integer s, >1s -> 1 decimal s, else ms
        if (( delta >= 10 )); then
            LCARS_LAST_DURATION=$(printf "%ds" ${delta%.*})
        elif (( delta >= 1 )); then
            LCARS_LAST_DURATION=$(printf "%.1fs" $delta)
        else
            LCARS_LAST_DURATION=$(printf "%dms" $(( delta * 1000 )))
        fi
    else
        LCARS_LAST_DURATION=""
    fi
}

add-zsh-hook preexec lcars_preexec
add-zsh-hook precmd lcars_precmd
# Git status symbols
ZSH_THEME_GIT_PROMPT_DIRTY=" ${LCARS_ALERT_RED}●${RESET}"
ZSH_THEME_GIT_PROMPT_CLEAN=" ${LCARS_YELLOW}●${RESET}"
ZSH_THEME_GIT_PROMPT_ADDED="${LCARS_PEACH}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="${LCARS_YELLOW}*"
ZSH_THEME_GIT_PROMPT_DELETED="${LCARS_RED}-"
ZSH_THEME_GIT_PROMPT_RENAMED="${LCARS_PINK}→"
ZSH_THEME_GIT_PROMPT_UNMERGED="${LCARS_ALERT_RED}‡"
ZSH_THEME_GIT_PROMPT_UNTRACKED="${LCARS_WHITE}?"

# Return status indicator
return_status() {
    echo "%(?:${LCARS_YELLOW}${ICON_CHECK}:${LCARS_ALERT_RED}${ICON_CROSS})${RESET}"
}

# User and host
user_host() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo "${ICON_SSH} %m"
    else
        echo ""
    fi
}

# Current directory
current_dir() {
    echo "${ICON_FOLDER} %~"
}

# Time display
time_display() {
    echo "${ICON_TIME} %D{%H:%M:%S}"
}

# Git status with counts
git_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git_current_branch)
        local bg_color="$BG_BLUE"
        
        # Red alert mode if last command failed
        if [[ $? -ne 0 ]]; then
            bg_color="$BG_ALERT_RED"
        fi
        
        # Get counts for different change types
        local added=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        local modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        local deleted=$(git status --porcelain 2>/dev/null | grep -c '^ D')
        local untracked=$(git status --porcelain 2>/dev/null | grep -c '^??')
        local renamed=$(git status --porcelain 2>/dev/null | grep -c '^ R')
        local unmerged=$(git status --porcelain 2>/dev/null | grep -c '^UU')
        
        # Build status string with counts
        local status_str=""
        [[ $added -gt 0 ]] && status_str+="${LCARS_PEACH}+${added}"
        [[ $modified -gt 0 ]] && status_str+="${LCARS_YELLOW}*${modified}"
        [[ $deleted -gt 0 ]] && status_str+="${LCARS_RED}-${deleted}"
        [[ $untracked -gt 0 ]] && status_str+="${LCARS_WHITE}?${untracked}"
        [[ $renamed -gt 0 ]] && status_str+="${LCARS_PINK}→${renamed}"
        [[ $unmerged -gt 0 ]] && status_str+="${LCARS_ALERT_RED}‡${unmerged}"
        
        # Determine if dirty
        local is_dirty=""
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            is_dirty=" ${LCARS_ALERT_RED}●${RESET}"
        else
            is_dirty=" ${LCARS_YELLOW}●${RESET}"
        fi
        
        echo "%K{${bg_color}}${LCARS_BLACK}  ${ICON_GIT} ${branch}${is_dirty}${status_str}  "
    fi
}

# Build the prompt
build_prompt() {
    # Capture last exit status
    local last_status=$?
    
    # Status indicator
    local status_indicator="$(return_status)"
    
    # Directory and git info
    local dir_info="$(current_dir)"
    local git_info="$(git_status)"
    local time="$(time_display)"
    
    # Determine colors based on last command status
    local label_bg="$BG_LCARS_LABEL"
    local dir_bg="$BG_ORANGE"
    
    # RED ALERT MODE - all segments turn red on error
    if [[ $last_status -ne 0 ]]; then
        label_bg="$BG_ALERT_RED"
        dir_bg="$BG_ALERT_RED"
    fi
    
    # Battery segment (if available)
    local battery_segment=""
    if (( $+functions[battery_pct_prompt] )); then
        local battery_pct=$(battery_pct_prompt)
        local battery_level=${battery_pct//[^0-9]/}
        local bat_icon=""
        
        if [[ $battery_level -ge 80 ]]; then
            bat_icon=$'\uf240'
        elif [[ $battery_level -ge 60 ]]; then
            bat_icon=$'\uf241'
        elif [[ $battery_level -ge 40 ]]; then
            bat_icon=$'\uf242'
        elif [[ $battery_level -ge 20 ]]; then
            bat_icon=$'\uf243'
        else
            bat_icon=$'\uf244'
        fi
        
        battery_segment="%K{${BG_PINK}}${LCARS_BLACK}  ${bat_icon} ${LCARS_YELLOW}${battery_pct}${LCARS_BLACK}"
    fi

    # Time segment
    local time_segment="%K{${BG_PURPLE}}${LCARS_BLACK}  ${time} "
    
    # Duration segment (last command) - with rounded end
    local rounded_end=$'\ue0b4'
    local duration_segment=""
    if [[ -n $LCARS_LAST_DURATION ]]; then
        duration_segment="%K{${BG_PEACH}}${LCARS_BLACK}  ${ICON_TIMER} ${LCARS_LAST_DURATION} %k%F{${BG_PEACH}}${rounded_end}%f"
    else
        # No duration, so time segment gets the rounded end
        time_segment="%K{${BG_PURPLE}}${LCARS_BLACK}  ${time} %k%F{${BG_PURPLE}}${rounded_end}%f"
    fi
    
    # LCARS segments with background colors
    local lcars_label="%K{${label_bg}}${LCARS_WHITE} ${ICON_OS} "
    local dir_segment="%K{${dir_bg}}${LCARS_BLACK}  ${dir_info}  "
    
    # Build the prompt line
    echo ""
    echo "${lcars_label}${dir_segment}${git_info}${battery_segment:+$battery_segment}${time_segment}${duration_segment}"
    echo "${status_indicator} ${LCARS_ORANGE}▌${RESET} "
}

# Right prompt (empty)
build_rprompt() {
    echo ""
}

# Set the prompts
PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Display command execution time for long-running commands
REPORTTIME=10
