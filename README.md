# My Dotfiles

This repository includes an automated Linux bootstrap script: `install.sh`.

## What `install.sh` does

- Installs required tools (i3, alacritty, neovim, picom, starship, and supporting packages).
- Creates symlinks from this repository into your home config paths.
- Optionally sets up OBS profile files from `streamconfig/`.
- Optionally runs Neovim plugin sync (`PackerSync`).

Because configs are symlinked, editing files in this repository updates your live system config immediately.

## Run the installer

1. Clone this repository and enter it.

```bash
git clone https://github.com/HanslettTheDev/dotfiles.git
cd dotfiles
```

2. Make the script executable.

```bash
chmod +x install.sh
```

3. Run the installer.

```bash
./install.sh
```

## Optional flags

```bash
# Link OBS profile files (non-secret)
./install.sh --with-stream-profile

# Also link OBS service.json (contains stream key/tokens)
./install.sh --with-stream-secrets

# Skip Neovim plugin sync step
./install.sh --skip-nvim-sync
```

## Notes

- Supported package managers: `apt`, `dnf`, `pacman`, `zypper`.
- Existing config paths are backed up automatically before relinking.
- `--with-stream-secrets` links credential-bearing OBS config. Use only on trusted machines.
- If `i3-resurrect` is not available in your shell, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Post-install checklist

1. Confirm core binaries are available:

```bash
command -v i3 alacritty nvim picom starship i3-resurrect
```

2. Verify important config paths are symlinks:

```bash
ls -ld ~/.config/alacritty ~/.config/nvim ~/.config/picom ~/.config/i3
ls -l ~/.config/i3/config ~/.config/starship.toml ~/.config/i3-resurrect/config.json
```

3. Validate Alacritty theme import works:

```bash
alacritty -v
```

4. Validate Neovim plugins are present:

```bash
nvim --headless "+PackerSync" +qa
```

5. Verify i3 config syntax:

```bash
i3 -C
```

6. Log out and back in to your i3 session, then check:

- Keybindings load from your config.
- `picom` starts and transparency/blur behavior is applied.
- `nitrogen --restore` re-applies wallpaper.
