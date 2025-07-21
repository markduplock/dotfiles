
# Lean & Clean Powerlevel10k Config + Enhanced Right Prompt
# Includes essential elements + command time + RAM usage.

# Fonts
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

# Prompt segments
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir             # current directory
  vcs             # git status
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                # exit code of last command
  command_execution_time
  time
)

# Custom RAM segment
ram_usage() {
  local used=$(free -h | awk '/^Mem:/ {print $3}')
  local total=$(free -h | awk '/^Mem:/ {print $2}')
  local percent=$(free | awk '/^Mem:/ {printf("%.0f", $3/$2 * 100)}')
  echo "$used / $total ($percent%)"
}

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  time
  custom_ram
)

typeset -g POWERLEVEL9K_CUSTOM_RAM="ram_usage"
typeset -g POWERLEVEL9K_CUSTOM_RAM_BACKGROUND='52'
typeset -g POWERLEVEL9K_CUSTOM_RAM_FOREGROUND='255'



# Icons
typeset -g POWERLEVEL9K_HOME_ICON=''         # 
typeset -g POWERLEVEL9K_FOLDER_ICON=''       # 
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=false

# Time format
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=true

# Shorten long paths
typeset -g POWERLEVEL9K_DIR_SHORTEN_STRATEGY="truncate_middle"
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40

# Hide username unless root or SSH
typeset -g POWERLEVEL9K_SHOW_USERNAME=true
typeset -g POWERLEVEL9K_SHOW_HOSTNAME=true
typeset -g POWERLEVEL9K_ALWAYS_SHOW_USER=false

# Prompt spacing and aesthetics
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="❯ "

# Enable instant prompt (must be before zsh loads)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
