# 🚀 Dotfiles Bootstrap

This script automates the setup of your Zsh-based terminal environment on Ubuntu or other Debian based system.

## 📦 What It Installs

- `zsh`: the shell of legends
- `oh-my-zsh`: plugin manager and config framework
- `powerlevel10k`: beautiful and fast prompt theme
- `zsh-autosuggestions`: fish-style autosuggestions
- `zsh-syntax-highlighting`: real-time syntax coloring
- `trash-cli`: safer alternative to `rm`
- `JetbrainsMono Nerd Font`: for perfect font rendering with powerlevel10k

## 🗂 What It Does

- Backs up any existing `.zshrc` or `.p10k.zsh` files
- Installs the full Zsh + plugin stack
- Installs JetbrainsMono Nerd Font
- Sets Zsh as your default shell

## 🧪 How To Use
Replace <USER>/<REPO> with your GitHub path after you push these files:
`curl -fsSL https://raw.githubusercontent.com/<USER>/<REPO>/main/install.sh | bash`

- The installer will fetch setup-zsh.sh from the same repo and run it.
- You’ll be prompted for sudo to install apt packages.

## ♻️ Uninstall / Revert
- Restore your backups:
```
mv ~/.zshrc.OLD ~/.zshrc # or the timestamped variant
mv ~/.p10k.zsh.OLD ~/.p10k.zsh
```

- Change your default shell back to bash:
`chsh -s /bin/bash "$USER"`

- (Optional) Remove installed fonts:
`cd ~/.local/share/fonts/NerdFonts/JetBrainsMonoNL` and run `fc-cache -f`

## 📜 License
MIT
