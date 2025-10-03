#!/usr/bin/env bash
# =============================================================================
# setup-zsh.sh
#
# Purpose:
#   Configure a Debian system with:
#     - JetBrainsMonoNL Nerd Font (installed for the current user)
#     - zsh + oh-my-zsh
#     - powerlevel10k theme
#     - zsh-autosuggestions & zsh-syntax-highlighting plugins
#     - trash-cli
#   Safely backs up ~/.zshrc and ~/.p10k.zsh (appends .OLD; adds timestamp if needed)
#   Sets zsh as the default shell for the invoking user.
#
# Usage:
#   bash setup-zsh.sh
#
# Notes:
#   - Uses Nerd Fonts release asset: JetBrainsMono.zip (contains *JetBrainsMonoNL* faces).
#   - Installs fonts per-user: ~/.local/share/fonts/...
#   - Idempotent: safe to re-run; will update/skip existing pieces when possible.
# =============================================================================

set -Eeuo pipefail

# ------------------------------- Utilities -----------------------------------

log()  { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

die() {
  err "$*"
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command '$1' not found."
}

backup_file() {
  # Backs up file if it exists to filename.OLD (or filename.OLD.YYYYmmdd-HHMMSS if .OLD exists)
  local f="$1"
  if [[ -f "$f" ]]; then
    local backup="${f}.OLD"
    if [[ -e "$backup" ]]; then
      backup="${backup}.$(date +%Y%m%d-%H%M%S)"
    fi
    log "Backing up $f -> $backup"
    mv -f -- "$f" "$backup"
  fi
}

clone_or_update() {
  # Clone repo into path if missing; otherwise fetch+pull fast-forward
  local url="$1" dest="$2" depth="${3:-1}"
  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")"
    git -C "$dest" fetch --depth="$depth" origin
    git -C "$dest" -c advice.detachedHead=false reset --hard "origin/$(git -C "$dest" rev-parse --abbrev-ref HEAD || echo main)" || true
  else
    log "Cloning $(basename "$dest")"
    git clone --depth="$depth" "$url" "$dest"
  fi
}

# ------------------------------ Pre-flight -----------------------------------

# Ensure we can install packages
if (( EUID == 0 )); then
  SUDO=""
else
  SUDO="sudo"
fi

need_cmd uname
need_cmd printf
need_cmd sed

# We’ll install these via apt
APT_BIN="$(command -v apt-get || true)"
if [[ -z "$APT_BIN" ]]; then
  APT_BIN="$(command -v apt || true)"
fi
[[ -n "$APT_BIN" ]] || die "apt/apt-get not found. Are you on Debian/Ubuntu?"

# ------------------------------ Install deps ---------------------------------

log "Updating apt package lists…"
$SUDO DEBIAN_FRONTEND=noninteractive "$APT_BIN" update -y

log "Installing base packages: zsh, git, curl, unzip, fontconfig, trash-cli"
$SUDO DEBIAN_FRONTEND=noninteractive "$APT_BIN" install -y \
  zsh git curl unzip fontconfig trash-cli

# Sanity: tools we just installed
need_cmd zsh
need_cmd git
need_cmd curl
need_cmd unzip
need_cmd fc-cache
need_cmd trash

# -------------------------- Install Nerd Font (JBM NL) -----------------------

# We fetch the JetBrainsMono Nerd Font release asset (contains JetBrainsMonoNL)
NF_ASSET_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

# Work in a temp dir and clean up afterwards
TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf -- "$TMP_DIR"; }
trap cleanup EXIT

log "Downloading JetBrainsMono Nerd Font archive (includes JetBrainsMonoNL)…"
curl -fL --retry 3 --retry-delay 2 -o "$TMP_DIR/JetBrainsMono.zip" "$NF_ASSET_URL"

log "Unpacking font archive…"
unzip -q -o "$TMP_DIR/JetBrainsMono.zip" -d "$TMP_DIR/JetBrainsMono"

# Install only the *No Ligatures* (NL) faces if present; otherwise fall back to all JBM faces.
USER_FONT_DIR="$HOME/.local/share/fonts/NerdFonts/JetBrainsMonoNL"
mkdir -p "$USER_FONT_DIR"

shopt -s nullglob
mapfile -t NL_TTFS < <(find "$TMP_DIR/JetBrainsMono" -type f \
  -iregex '.*JetBrains[ _-]*MonoNL.*\.\(ttf\|otf\)' | sort)

if (( ${#NL_TTFS[@]} > 0 )); then
  log "Installing JetBrainsMonoNL Nerd Font files to $USER_FONT_DIR"
  for f in "${NL_TTFS[@]}"; do
    # -n: no clobber; use -f to overwrite if you prefer updating
    cp -n -- "$f" "$USER_FONT_DIR/"
  done
else
  warn "Could not locate explicit *NL* faces in the archive; installing all JetBrainsMono Nerd Font files as a fallback."
  mapfile -t ALL_TTFS < <(find "$TMP_DIR/JetBrainsMono" -type f -iname '*JetBrains*Mono*.*tf' | sort)
  for f in "${ALL_TTFS[@]}"; do
    cp -n -- "$f" "$USER_FONT_DIR/"
  done
fi

log "Refreshing font cache…"
fc-cache -f >/dev/null

# -------------------------- Install Oh My Zsh stack ---------------------------

# Backup user configs before oh-my-zsh touches anything
backup_file "$HOME/.zshrc"
backup_file "$HOME/.p10k.zsh"

# Install oh-my-zsh non-interactively (do not auto-run zsh or chsh)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing Oh My Zsh…"
  export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "Oh My Zsh already installed; updating core…"
  "$HOME/.oh-my-zsh/tools/upgrade.sh" || true
fi

# Ensure we have a .zshrc (oh-my-zsh normally creates one)
if [[ ! -f "$HOME/.zshrc" ]]; then
  log "Creating default ~/.zshrc"
  cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k
clone_or_update "https://github.com/romkatv/powerlevel10k.git" \
  "$ZSH_CUSTOM/themes/powerlevel10k" 1

# Plugins
clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 1

clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 1

# ----------------------------- Configure .zshrc -------------------------------

# Set theme -> powerlevel10k
if grep -qE '^\s*ZSH_THEME=' "$HOME/.zshrc"; then
  sed -i 's|^\s*ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
else
  printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$HOME/.zshrc"
fi

# Ensure plugins line contains git, autosuggestions, and syntax-highlighting
if grep -qE '^\s*plugins=\(' "$HOME/.zshrc"; then
  sed -i 's|^\s*plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' "$HOME/.zshrc"
else
  printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$HOME/.zshrc"
fi

# Source p10k config if it exists (first run of p10k wizard creates ~/.p10k.zsh)
if ! grep -q 'p10k\.zsh' "$HOME/.zshrc"; then
  printf '\n# Load Powerlevel10k configuration if present\n[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh\n' >> "$HOME/.zshrc"
fi

# zsh-syntax-highlighting must be at/near the end for best results; oh-my plugin usually handles this,
# but we add a final safety source in case of custom setups.
if ! grep -q 'zsh-syntax-highlighting.zsh' "$HOME/.zshrc"; then
  printf '\n# (Safety) Ensure zsh-syntax-highlighting is loaded last\nif [[ -r "%s/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then\n  source "%s/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"\nfi\n' "$ZSH_CUSTOM" "$ZSH_CUSTOM" >> "$HOME/.zshrc"
fi

# ------------------------------ Default shell --------------------------------

TARGET_USER="${SUDO_USER:-$USER}"
CURRENT_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7 || echo "")"
ZSH_PATH="$(command -v zsh)"

if [[ -n "$ZSH_PATH" && "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  log "Setting default shell to zsh for user: $TARGET_USER"
  if $SUDO chsh -s "$ZSH_PATH" "$TARGET_USER"; then
    log "Default shell changed. Open a new terminal session to use zsh."
  else
    warn "Could not change default shell automatically. You can do it manually with:"
    printf '    chsh -s "%s" "%s"\n' "$ZSH_PATH" "$TARGET_USER"
  fi
else
  log "zsh is already the default shell for $TARGET_USER (or zsh path not found)."
fi

# ------------------------------- Final notes ---------------------------------

cat <<'EOF'

✔ All done!

What changed:
  • Installed JetBrainsMonoNL Nerd Font to: ~/.local/share/fonts/NerdFonts/JetBrainsMonoNL
  • Installed zsh, oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, trash-cli
  • Backed up: ~/.zshrc and ~/.p10k.zsh (if they existed)
  • Configured theme (powerlevel10k) and plugins in ~/.zshrc
  • Set zsh as your default shell (if possible)

Next steps:
  • Open a new terminal (or log out/in) to start using zsh.
  • On first prompt, powerlevel10k may launch a configuration wizard to create ~/.p10k.zsh.

EOF

