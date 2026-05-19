zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (minimal but useful)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Enable Powerlevel10k instant prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# User-defined aliases
alias rm='trash'
alias ..='cd ..'
alias b='cd ~/bin'
alias d='cd ~/dev'
alias dl='cd ~/Downloads'
alias zz='systemctl suspend'


# Export PATH additions if needed
# export PATH="$HOME/bin:$PATH"

# Enable colors in `ls` and use human-readable file sizes
alias ls='ls -ahl --group-directories-first --color=auto'
alias ll='ls -lah'
alias la='ls -A'

# Fix key repeat delay in some terminal emulators
export KEYTIMEOUT=1

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000


# # Fuzzy cd to directories using fzf (case-insensitive)
# cdf() {
#   local dir
#   dir=$(find . -type d -iname '*' 2>/dev/null | fzf --height=40% --reverse --border) && cd "$dir"
# }

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
