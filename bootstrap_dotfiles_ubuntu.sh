#!/bin/bash

# Set up environment variables
export DOTFILES="$HOME/.dotfiles"
export BACKUP="$HOME/.dotfiles_backup"

echo "🚀 Starting dotfiles bootstrap for Debian/Pi OS..."

# Backup existing dotfiles
mkdir -p "$BACKUP"

echo "📦 Backing up existing dotfiles..."
for file in .zshrc .p10k.zsh .gitconfig .nanorc .zshenv .zprofile; do
  if [ -f "$HOME/$file" ]; then
    echo "➡️  Backing up $file"
    mv "$HOME/$file" "$BACKUP/"
  fi
done

# Clone dotfiles if not already present
if [ ! -d "$DOTFILES" ]; then
  echo "🔄 Cloning dotfiles from GitHub..."
  git clone git@github.com:markduplock/dotfiles.git "$DOTFILES"
fi

# Install packages using APT
echo "🔧 Installing required packages via APT..."
sudo apt update && sudo apt install -y \
  zsh \
  git \
  curl \
  wget \
  fzf \
  bat \
  ripgrep \
  fd-find \
  nano \
  btop \
  fonts-powerline \
  locales \
  python3 \
  python3-pip \
  unzip \
  htop

# Create bat symlink (batcat → bat)
if command -v batcat &>/dev/null && [ ! -f /usr/local/bin/bat ]; then
  echo "🔗 Linking batcat to bat..."
  sudo ln -s $(which batcat) /usr/local/bin/bat
fi

# Link dotfiles
echo "🔗 Linking dotfiles..."
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.nanorc" "$HOME/.nanorc"
ln -sf "$DOTFILES/.zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES/.zprofile" "$HOME/.zprofile"

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "🐚 Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# Fastfetch if you want it (optional)
# sudo apt install fastfetch -y

echo "✅ Dotfiles bootstrap complete! Reload shell or run 'zsh' to apply."
