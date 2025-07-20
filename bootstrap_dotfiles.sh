#!/bin/bash

set -e

echo "🔧 Starting dotfiles bootstrap for Ubuntu..."

# === 1. Package Install ===
echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y zsh git curl wget trash-cli unzip fontconfig

# === 2. Backup existing configs ===
echo "🗂 Backing up existing .zshrc and .p10k.zsh (if any)..."
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc_fallback.old
[ -f ~/.p10k.zsh ] && mv ~/.p10k.zsh ~/.p10k.zsh_fallback.old

# === 3. Install Oh-My-Zsh ===
echo "🐚 Installing Oh-My-Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# === 4. Install Powerlevel10k ===
echo "✨ Installing powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# === 5. Install ZSH plugins ===
echo "🔌 Installing zsh-autosuggestions and zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# === 6. Install MesloLGS Nerd Font ===
echo "🔠 Installing MesloLGS Nerd Font..."
git clone --filter=blob:none --depth=1 --sparse https://github.com/ryanoasis/nerd-fonts.git ~/nerd-fonts
cd ~/nerd-fonts
git sparse-checkout set patched-fonts/Meslo
./install.sh Meslo
cd ~
rm -rf ~/nerd-fonts

# === 7. Set ZSH as default shell ===
echo "🔁 Setting zsh as the default shell..."
chsh -s $(which zsh)

# === 8. Completion ===
echo "✅ Setup complete!"

# === 9. Alias Summary ===
echo
echo "📚 Available aliases (from your dotfiles):"
alias | grep -E '^alias ' || echo "No aliases defined yet. Define them in ~/.zshrc or your dotfiles."

echo
echo "💡 Pro Tip: Run 'p10k configure' to configure your prompt."
