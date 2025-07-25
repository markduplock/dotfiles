# 🚀 Dotfiles Bootstrap Script

This script automates the setup of your Zsh-based terminal environment on Fedora.

## 📦 What It Installs

- `zsh`: the shell of legends
- `oh-my-zsh`: plugin manager and config framework
- `powerlevel10k`: beautiful and fast prompt theme
- `zsh-autosuggestions`: fish-style autosuggestions
- `zsh-syntax-highlighting`: real-time syntax coloring
- `trash-cli`: safer alternative to `rm`
- `MesloLGS Nerd Font`: for perfect font rendering with powerlevel10k

## 🗂 What It Does

- Backs up any existing `.zshrc` or `.p10k.zsh` files
- Installs the full Zsh + plugin stack
- Installs MesloLGS Nerd Font locally
- Sets Zsh as your default shell
- Displays any aliases defined in your environment

## 🧪 How To Use

After cloning this dotfiles repo:

```bash
git clone https://github.com/markduplock/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap_dotfiles_*required_installer_.sh
./bootstrap_dotfiles_*required_installer.sh
```

Then log out and back in — or run:

```bash
exec zsh
```

## 💡 Pro Tip

If you don't like the look of the terminal, run:

```bash
p10k configure
```

to customize your prompt with the MesloLGS Nerd Font.

## 🧙‍♂️ Bonus Ideas

- Add your own aliases and functions to `.zshrc`
- Include Flatpak installs or VS Code config
- Automate SSH key setup or Tailscale

---

**Welcome to your new shell.** It's fast, it's clean, and it's yours.
