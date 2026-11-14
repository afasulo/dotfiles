# dotfiles

My shell, CLI tools, and dotfiles for macOS, Ubuntu/Debian, and Fedora/RHEL, managed with [chezmoi](https://chezmoi.io).

## Set up a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply afasulo
```

On the first run it asks:

| Prompt | What it does |
| --- | --- |
| `profile` | `personal` or `work`; sets the defaults for the questions below |
| `git_name` / `git_email` | identity written to `~/.gitconfig` on this machine |
| `pkg_security` | gdb + GEF, ghidra, nmap, gobuster, shodan, vsftpd |
| `pkg_hardware` | librealsense, tracy (macOS) |
| `pkg_langs` | Java (temurin/OpenJDK), gradle, freetds, Haskell via ghcup |

The answers are saved in `~/.config/chezmoi/chezmoi.toml`. To change them later, run `chezmoi init --prompt`.

### Machines with existing config (e.g. work)

Do it in two steps so you can see what will change before it happens:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init afasulo   # clone + prompts only
chezmoi diff                                                           # review
chezmoi apply                                                          # do it
```

On the first `apply`, a migration script runs before anything is written:

- Copies the existing `.zshrc`, `.zprofile`, `.gitconfig`, `.p10k.zsh`, and `.gdbinit` to `~/.dotfiles-backup/<timestamp>/`.
- Collects every line of the old `.zshrc` that isn't in the shared one into `~/.zshrc.local`, **commented out**. Uncomment the work-specific functions and aliases you want to keep, then `exec zsh`.
- Copies the old `.gitconfig` to `~/.gitconfig.local`, which the shared config includes, so it stays active.
- Moves anything in the old `.zprofile` other than brew setup to `~/.zprofile.local`, which is sourced.

## Files chezmoi never touches

| File | Use for |
| --- | --- |
| `~/.zshrc.local` | machine-specific shell config (work scripts, aliases) |
| `~/.secrets` | tokens and API keys (`export FOO_TOKEN=...`), `chmod 600` |
| `~/.gitconfig.local` | machine-specific git config (work email, signing keys) |
| `~/.zprofile.local` | machine-specific login-shell setup |

## Everyday use

```sh
chezmoi update                       # pull latest from GitHub and apply
chezmoi edit --apply ~/.zshrc        # edit a managed file
chezmoi add ~/.config/foo/config     # start tracking a file
chezmoi cd                           # jump into the repo, then commit + push
chezmoi diff                         # preview pending changes
```

To add a package, edit `.chezmoidata/packages.yaml`. The install script reruns on the next `chezmoi apply`.

## Layout

| Path | Purpose |
| --- | --- |
| `.chezmoi.toml.tmpl` | per-machine prompts |
| `.chezmoidata/packages.yaml` | package sets for brew, cask, apt, and dnf |
| `.chezmoiexternal.toml.tmpl` | oh-my-zsh, powerlevel10k, zsh plugins, and GEF, pulled from upstream |
| `.chezmoitemplates/zshrc` | the shared `.zshrc` |
| `dot_*` | dotfiles (`dot_zshrc.tmpl` → `~/.zshrc`) |
| `run_once_before_00-migrate-existing.sh.tmpl` | first-run backup and migration |
| `run_onchange_before_10-install-packages.sh.tmpl` | package install |
| `run_once_after_90-set-default-shell.sh` | sets zsh as the login shell |
