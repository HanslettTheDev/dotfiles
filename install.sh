#!/usr/bin/bash

# SCRIPT CONFIGURATIONS

# Let the script fail fast and loud
# -Ee exit immediately if a command fails and applys to functions and subshells
# -u Error for unset variables
# -o pipefail is self explanatory
set -Eeuo pipefail

# Turn on tracing only when debug mode is on
[[ "${DEBUG:-0}" == "1" ]] && set -x

# check if run is in sudo or not
if [[ $EUID -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

# let all package managers use a non-interactive user interface
export DEBIAN_FRONTEND=noninteractive


# FUNCTIONS AND GLOBAL VARIABLES

PACKAGES=(
curl
git
fzf
python3-pip
make
gcc
build-essential
tmux
tree
ninja-build
gettext
ripgrep
unzip
fd-find
cmake
)

# create the config dir
mkdir -p "$HOME/.config"

function command_exist() {
	type "$1" &>/dev/null
}

function dir_exists() {
	[ -d "$1" ]
}

function git_clone() {
	local url=$1 dest=$2
	if [ -d "$dest/.git" ]; then
		echo "[=] $dest already cloned, skipping"
	elif [ -e "$dest" ]; then
		echo "[!] $dest exists but is not a git repo" >&2
		return 1
	else 
		git clone "$url" "$dest"
	fi
}

# Ensure required apps are installed before running the install script
# If not available, install those apps

function install_required_tools() {
	$SUDO apt-get update
	$SUDO apt-get install -y "${PACKAGES[@]}" 2>&1

	for pkg in "${PACKAGES[@]}"; do
		if ! dpkg -s "$pkg" >/dev/null 2>&1; then
			echo "[✓] $pkg installed"
		else
			echo "[=] $pkg already installed"
		fi
	done
}

# Clone my dotfiles repository
function fetch_dotfiles_repository() {
	echo "[=] Cloning dotfiles repository"
	git_clone https://github.com/HanslettTheDev/dotfiles.git "$HOME/dotfiles"
	echo "[✓] Repository cloned!"
}


# INSTALL MY NICHE APPS
# telegram, chrome, firefox
function install_utility_apps() {
	# telegram
	echo "[=] installing Telegram"
	$SUDO snap install telegram-desktop
	echo "[✓] Telegram Installed!"

	# chrome
	echo "[=] installing Chrome"
	if ! command_exist google-chrome || ! command_exist google-chrome-stable; then
		curl -fL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		$SUDO apt-get install -y /tmp/google-chrome.deb
		$SUDO apt-get update
		echo "[✓] chrome installed"
	else
		echo "[✓] chrome already installed"
	fi
	# firefox
	echo "[=] Updating firefox"
	$SUDO snap refresh firefox
	echo "[✓] firefox updated"

	$SUDO apt-get update
}


# Window Manager
# Install i3 and configure it
function install_i3wm() {
	# installing i3
	echo "[=] installing i3wm"
	$SUDO apt-get install -y i3 xdotool maim xclip
	echo "[✓] i3 installed"

	# installing i3-resurrect and configuration
	echo "[=] installing i3-resurrect"
	git_clone https://github.com/JonnyHaystack/i3-resurrect.git "$HOME/i3-resurrect"
	cd "$HOME/i3-resurrect"
	pip3 install --user . --break-system-packages
	echo "[✓] i3-resurrect installed"
	
	# configuring i3 and i3-resurrect
	echo "[=] configuring i3wm and i3-resurrect"
	ln -sfnv "$HOME/dotfiles/i3" "$HOME/.config/i3"
	ln -sfnv "$HOME/dotfiles/i3-resurrect" "$HOME/.config/i3-resurrect"
	ln -sfnv "$HOME/dotfiles/i3-workspaces" "$HOME/.config/i3-workspaces"
	echo "[✓] i3 and i3-resurrect successfully configured"


}

# Command Line tools 
function terminal_configuration() {
	# install nerd fonts 
	echo "[=] Customizing the Terminal"


	# install nerd fonts
	echo "[=] Installing Nerd Fonts"
	"$HOME/dotfiles/font_install.sh"

	if ! command_exist starship; then
		# install starship
		echo "[=] installing starship"
		curl -sS https://starship.rs/install.sh | sh -s -- -y
		echo "[✓] starship installed"

		# configure starship
		echo "[=] Configuring starship"
		ln -snfv "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"
		echo "[✓] Configuration complete"
	else
		echo "[=] starship already installed"
	fi

	# copy git config
	echo "[=] Setting up .gitconfig"
	ln -snfv "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
	echo "[✓] .gitconfig setup complete"

	# configure tmux
	echo "[=] Setup tmux"

	ln -snfv "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

	TPM_DIR="$HOME/.config/tmux/plugins/tpm"
	git_clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
	
	# create a temporal tmux server to install plugins
	SESSION_NAME="tmux-setup-$$"
	CREATED_SESSION=0

	if ! tmux list-sessions >/dev/null 2>&1; then
		tmux new-session -d -s "$SESSION_NAME"
		CREATED_SESSION=1
	fi

	# source the tmux config
	tmux source-file "$HOME/.tmux.conf"

	# install tmux plugins non-interactively
	if [ -x "$TPM_DIR/bin/install_plugins" ]; then
		"$TPM_DIR/bin/install_plugins"
	else
		echo "TPM install_plugins not found or not executable" >&2
		exit 1
	fi

	# remove temporary tmux session
	if [ "$CREATED_SESSION" -eq 1 ]; then
		tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
	fi

	echo "[✓] tmux setup complete"
	echo "[✓] Terminal customization complete"	
}

# INSTALL DEV TOOLS
function install_neovim() {
	if ! command_exist nvim; then
		echo "[=] installing neovim"
		pip3 install neovim --break-system-packages
		git_clone https://github.com/neovim/neovim "$HOME/neovim"
		cd "$HOME/neovim"
		git checkout v0.11.7
		make CMAKE_BUILD_TYPE=RelWithDebInfo
		$SUDO make install
		echo "[✓] neovim installed"
	else
		echo "[!] neovim is already installed"
	fi
		
	echo "[=] setting up neovim config"
	# set neovim config
	ln -snfv "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
	echo "[✓] neovim config setup complete"
}

function install_alacritty() {
	if ! command_exist alacritty; then
		echo "[=] installing alacritty"
		git_clone https://github.com/alacritty/alacritty.git "$HOME/alacritty"
		cd "$HOME/alacritty"
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		set +eu
		source "$HOME/.bashrc"
		set -eu
		# **// ensure I have the right rust compiler**
		rustup override set stable
		rustup update stable
		# **// Source this config to ensure rustup is available for use**
		source $HOME/.bashrc
		# **// dependencies to build alacritty**
		$SUDO apt-get install -y cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 gzip scdoc
		cargo build --release
		$SUDO tic -xe alacritty,alacritty-direct extra/alacritty.info
		infocmp alacritty
		# **// Add alacritty desktop icon for wayland**
		$SUDO cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
		$SUDO cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
		$SUDO desktop-file-install extra/linux/Alacritty.desktop
		$SUDO update-desktop-database
		# **// setting up the man page**
		$SUDO mkdir -p /usr/local/share/man/man1
		$SUDO mkdir -p /usr/local/share/man/man5
		$SUDO mkdir -p /usr/local/share/man/man7
		scdoc < extra/man/alacritty.1.scd | gzip -c | $SUDO tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
		scdoc < extra/man/alacritty-msg.1.scd | gzip -c | $SUDO tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
		scdoc < extra/man/alacritty.5.scd | gzip -c | $SUDO tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
		scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | $SUDO tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
		scdoc < extra/man/alacritty-escapes.7.scd | gzip -c | $SUDO tee /usr/local/share/man/man7/alacritty-escapes.7.gz > /dev/null
		# **// Add shell completion(I choose these commands since I plan to delete the alacritty source directory after installation)**
		mkdir -p ~/.bash_completion
		cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
		echo "[✓] alacritty installed"
	else 
		echo "[!] neovim is already installed"
	fi

	echo "[=] setting up alacritty config"
	ln -snfv "$HOME/dotfiles/alacritty" "$HOME/.config/alacritty"
	echo "[✓] alacritty config setup successfully"
}



# Other DEV tools
# uv installation
function install_uv() {
	if ! command_exist uv; then
		echo "[=] installing uv"
		curl -LsSf https://astral.sh/uv/install.sh | sh
		echo "[✓] uv installed"
	fi
} 

# nvm installation
function install_nvm() {
	if ! command_exist nvm; then
		echo "[=] installing nvm"
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
		echo "[✓] nvm installed"
	fi
}

# Setup bashrc files 
function bash_config() {
	# check if the exist
	echo "[=] Setup .bashrc and .bash_aliases"
	[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
	[ -f "$HOME/.bash_aliases" ] && mv "$HOME/.bash_aliases" "$HOME/.bash_aliases.bak"
	
	# create symlink
	ln -snfv "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"
	ln -snfv "$HOME/dotfiles/.bash_aliases" "$HOME/.bash_aliases"

	# source the config
	set +eu
	source "$HOME/.bashrc"
	set -eu
	echo "[✓] .bashrc and .bash_aliases setup complete"
}

# Clean Up residual files
function clean_up() {
	echo "[=] Removing neovim, alacritty and i3-resurrect files"
	rm -rf "$HOME/neovim" "$HOME/alacritty" "$HOME/i3-resurrect"
	echo "[✓] clean up complete"

	echo "[=] Clone dotfiles to .dotfiles for version control"
	git_clone https://github.com/HanslettTheDev/dotfiles.git "$HOME/.dotfiles"
	echo "[✓] Clone successful"

	echo "[=] Remove dotfiles directory"
	rm -rf "$HOME/dotfiles"
	echo "[✓] dotfiles folder removed successfully"

	echo "[✓] Clean Up Complete"
}

# Command Flow Setup
install_required_tools

fetch_dotfiles_repository

install_utility_apps

terminal_configuration

install_i3wm

install_neovim

install_alacritty

install_uv

install_nvm

bash_config

clean_up

echo "=========================="
echo "[✓] Installation Complete"
echo "=========================="