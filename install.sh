#!/usr/bin/env bash
set -Eeuo pipefail


REPO_RAW="https://raw.githubusercontent.com/<USER>/<REPO>/main"
SCRIPT="setup-zsh.sh"


# Requirements for fetching and running
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need_cmd curl
need_cmd bash


# Fetch the script to a temp file (safer than piping to bash by default)
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT


# -f: fail on HTTP errors; -L: follow redirects; -sS: silent w/ errors
curl -fLsS "$REPO_RAW/$SCRIPT" -o "$TMP"
chmod +x "$TMP"


# Execute
bash "$TMP"
