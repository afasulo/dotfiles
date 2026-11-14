#!/usr/bin/env bash
# Make zsh the login shell if it isn't already.
set -u
zsh_path="$(command -v zsh || true)"
[ -z "$zsh_path" ] && { echo "[dotfiles] zsh not installed; skipping chsh" >&2; exit 0; }

current="$(basename "${SHELL:-}")"
if [ "$(uname)" = "Linux" ]; then
  current="$(basename "$(getent passwd "$(id -un)" | cut -d: -f7)")"
fi
[ "$current" = "zsh" ] && exit 0

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
echo "[dotfiles] Changing login shell to $zsh_path (may ask for your password)"
if command -v chsh >/dev/null 2>&1; then
  chsh -s "$zsh_path" $([ "$(id -u)" -eq 0 ] && id -un)
else
  $SUDO usermod -s "$zsh_path" "$(id -un)"
fi || echo "[dotfiles] chsh failed; run: chsh -s $zsh_path" >&2
exit 0
