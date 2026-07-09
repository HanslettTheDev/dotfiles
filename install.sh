#!/usr/bin/env bash
set -euo pipefail

# Venom dotfiles bootstrap script
# - Installs required tools for i3/alacritty/nvim/picom/starship
# - Symlinks configs from this repository into ~/.config and ~/.i3
# - Optionally deploys OBS stream profile secrets

WITH_STREAM_PROFILE=0
WITH_STREAM_SECRETS=0
SKIP_NVIM_SYNC=0

for arg in "$@"; do
	case "$arg" in
		--with-stream-profile)
			WITH_STREAM_PROFILE=1
			;;
		--with-stream-secrets)
			WITH_STREAM_PROFILE=1
			WITH_STREAM_SECRETS=1
			;;
		--skip-nvim-sync)
			SKIP_NVIM_SYNC=1
			;;
		-h|--help)
			cat <<'EOF'
Usage: ./install.sh [options]

Options:
	--with-stream-profile   Install OBS profile config from streamconfig/
	--with-stream-secrets   Also link service.json (contains stream key/tokens)
  --skip-nvim-sync        Skip running Neovim plugin sync step
  -h, --help              Show this help

Examples:
  ./install.sh
  ./install.sh --with-stream-profile
  ./install.sh --with-stream-secrets
EOF
			exit 0
			;;
		*)
			echo "Unknown option: $arg"
			echo "Run ./install.sh --help"
			exit 1
			;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
	printf '\n[+] %s\n' "$*"
}

warn() {
	printf '\n[!] %s\n' "$*"
}

need_cmd() {
	command -v "$1" >/dev/null 2>&1
}

link_path() {
	local src="$1"
	local dst="$2"

	mkdir -p "$(dirname "$dst")"

	if [[ -L "$dst" ]]; then
		local current_target
		current_target="$(readlink "$dst")"
		if [[ "$current_target" == "$src" ]]; then
			log "Symlink already up to date: $dst -> $src"
			return
		fi
		rm -f "$dst"
	elif [[ -e "$dst" ]]; then
		local backup_path
		backup_path="${dst}.backup.$(date +%Y%m%d%H%M%S)"
		warn "Existing path found at $dst. Backing up to $backup_path"
		mv "$dst" "$backup_path"
	fi

	ln -s "$src" "$dst"
}

if [[ ! -f "$SCRIPT_DIR/starship.toml" ]]; then
	warn "Script must be run from inside this dotfiles repository."
	exit 1
fi

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]] && need_cmd sudo; then
	SUDO="sudo"
fi

detect_pkg_manager() {
	if need_cmd apt-get; then
		echo "apt"
	elif need_cmd dnf; then
		echo "dnf"
	elif need_cmd pacman; then
		echo "pacman"
	elif need_cmd zypper; then
		echo "zypper"
	else
		echo ""
	fi
}

PKG_MGR="$(detect_pkg_manager)"
if [[ -z "$PKG_MGR" ]]; then
	warn "No supported package manager found (apt, dnf, pacman, zypper)."
	exit 1
fi

install_packages() {
	case "$PKG_MGR" in
		apt)
			log "Updating apt package index"
			$SUDO apt-get update

			log "Installing base desktop/tooling packages (apt)"
			$SUDO apt-get install -y \
				git curl wget ca-certificates unzip tar gzip \
				i3 i3status dmenu dex xss-lock i3lock xclip xdotool maim nitrogen picom \
				pulseaudio-utils network-manager-gnome \
				alacritty neovim ripgrep fd-find build-essential make gcc \
				python3 python3-pip nodejs npm

			if [[ "$WITH_STREAM_PROFILE" -eq 1 ]]; then
				log "Installing OBS Studio (apt)"
				$SUDO apt-get install -y obs-studio
			fi
			;;
		dnf)
			log "Installing base desktop/tooling packages (dnf)"
			$SUDO dnf install -y \
				git curl wget ca-certificates unzip tar gzip \
				i3 i3status dmenu dex-autostart xss-lock i3lock xclip xdotool maim nitrogen picom \
				pulseaudio-utils NetworkManager-applet \
				alacritty neovim ripgrep fd-find make gcc gcc-c++ \
				python3 python3-pip nodejs npm

			if [[ "$WITH_STREAM_PROFILE" -eq 1 ]]; then
				log "Installing OBS Studio (dnf)"
				$SUDO dnf install -y obs-studio
			fi
			;;
		pacman)
			log "Refreshing package database (pacman)"
			$SUDO pacman -Sy --noconfirm

			log "Installing base desktop/tooling packages (pacman)"
			$SUDO pacman -S --needed --noconfirm \
				git curl wget ca-certificates unzip tar gzip \
				i3-wm i3status dmenu dex xss-lock i3lock xclip xdotool maim nitrogen picom \
				pulseaudio network-manager-applet \
				alacritty neovim ripgrep fd base-devel make gcc \
				python python-pip nodejs npm

			if [[ "$WITH_STREAM_PROFILE" -eq 1 ]]; then
				log "Installing OBS Studio (pacman)"
				$SUDO pacman -S --needed --noconfirm obs-studio
			fi
			;;
		zypper)
			log "Installing base desktop/tooling packages (zypper)"
			$SUDO zypper --non-interactive install \
				git curl wget ca-certificates unzip tar gzip \
				i3 i3status dmenu dex xss-lock i3lock xclip xdotool maim nitrogen picom \
				pulseaudio-utils NetworkManager-applet \
				alacritty neovim ripgrep fd make gcc gcc-c++ \
				python3 python3-pip nodejs npm

			if [[ "$WITH_STREAM_PROFILE" -eq 1 ]]; then
				log "Installing OBS Studio (zypper)"
				$SUDO zypper --non-interactive install obs-studio
			fi
			;;
	esac
}

install_starship() {
	if need_cmd starship; then
		log "starship already installed"
		return
	fi

	log "Installing starship prompt"
	if [[ "$PKG_MGR" == "pacman" ]]; then
		$SUDO pacman -S --needed --noconfirm starship
	elif [[ "$PKG_MGR" == "dnf" ]]; then
		$SUDO dnf install -y starship
	elif [[ "$PKG_MGR" == "zypper" ]]; then
		$SUDO zypper --non-interactive install starship
	else
		curl -fsSL https://starship.rs/install.sh | sh -s -- -y
	fi
}

install_i3_resurrect() {
	if need_cmd i3-resurrect; then
		log "i3-resurrect already installed"
		return
	fi

	log "Installing i3-resurrect with pip"
	if need_cmd pip3; then
		pip3 install --user i3-resurrect
	else
		warn "pip3 not found; skipping i3-resurrect install"
	fi
}

deploy_configs() {
	log "Linking Alacritty config"
	link_path "$SCRIPT_DIR/alacritty" "$HOME/.config/alacritty"

	log "Linking i3 config"
	link_path "$SCRIPT_DIR/i3/config" "$HOME/.config/i3/config"

	log "Linking i3-resurrect config"
	link_path "$SCRIPT_DIR/i3-resurrect/config.json" "$HOME/.config/i3-resurrect/config.json"

	log "Linking saved i3 workspace snapshots"
	link_path "$SCRIPT_DIR/i3-storage/i3-resurrect" "$HOME/.i3/i3-resurrect"

	log "Linking picom config"
	link_path "$SCRIPT_DIR/picom" "$HOME/.config/picom"

	log "Linking starship config"
	link_path "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"

	log "Linking Neovim config"
	link_path "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
}

deploy_stream_profile() {
	local obs_profile_dir="$HOME/.config/obs-studio/basic/profiles/streamconfig"

	log "Linking OBS profile (non-secret files)"
	mkdir -p "$obs_profile_dir"
	link_path "$SCRIPT_DIR/streamconfig/basic.ini" "$obs_profile_dir/basic.ini"
	link_path "$SCRIPT_DIR/streamconfig/streamEncoder.json" "$obs_profile_dir/streamEncoder.json"

	if [[ "$WITH_STREAM_SECRETS" -eq 1 ]]; then
		warn "Linking stream secrets (service.json). Keep this machine trusted."
		link_path "$SCRIPT_DIR/streamconfig/service.json" "$obs_profile_dir/service.json"
	else
		warn "Skipping service.json because it contains stream credentials/tokens."
		warn "Use --with-stream-secrets to link it explicitly."
	fi
}

bootstrap_nvim() {
	if [[ "$SKIP_NVIM_SYNC" -eq 1 ]]; then
		warn "Skipping Neovim plugin sync (--skip-nvim-sync)"
		return
	fi

	if ! need_cmd nvim; then
		warn "nvim not found; skipping plugin sync"
		return
	fi

	log "Running headless Neovim sync (packer)"
	nvim --headless "+autocmd User PackerComplete quitall" "+PackerSync" || \
		warn "PackerSync failed; open Neovim and run :PackerSync manually"
}

print_shell_hint() {
	cat <<'EOF'

[+] Installation complete.

Recommended shell setup snippets:

  # bash (~/.bashrc)
  eval "$(starship init bash)"

  # zsh (~/.zshrc)
  eval "$(starship init zsh)"

If i3-resurrect is not in PATH, add this line to your shell rc:
  export PATH="$HOME/.local/bin:$PATH"

EOF
}

log "Starting setup using package manager: $PKG_MGR"
install_packages
install_starship
install_i3_resurrect
deploy_configs

if [[ "$WITH_STREAM_PROFILE" -eq 1 ]]; then
	deploy_stream_profile
fi

bootstrap_nvim
print_shell_hint
