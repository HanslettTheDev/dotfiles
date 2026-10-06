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
)

function command_exist() {
	command=$1
	return $(type $command &>/dev/null; echo $?)
}

# Ensure required apps are installed before running the install script
# If not available, install those apps

function install_required_tools() {
	$SUDO apt-get update
	$SUDO apt-get install -y "${PACKAGES[@]}" 2>&1

	for pkg in "${PACKAGES[@]}"; do
		if ! dpkg -s "$pkg" >/dev/null 2>&1; then
			echo "[=] $pkg already installed"
		else
			echo "[✓] $pkg installed"
		fi
	done
}

# Clone my dotfiles repository
function fetch_dotfiles_repository() {
	echo "[=] Cloning dotfiles repository"
	git clone https://github.com/HanslettTheDev/dotfiles.git "$HOME/dotfiles"
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
	curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	$SUDO apt-get install -y ./google-chrome-stable_current_amd64.deb
	$SUDO apt-get update
	echo "[✓] chrome installed"

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
	git clone https://github.com/JonnyHaystack/i3-resurrect.git "$HOME/i3-resurrect"
	cd i3-resurrect
	pip3 install --user . --break-system-packages
	echo "[✓] i3-resurrect installed"
	
	# configuring i3 and i3-resurrect
	echo "[=] configuring i3wm and i3-resurrect"
	ln -sv "$HOME/dotfiles/i3" "$HOME/.config/i3-resurrect"
	ln -sv "$HOME/dotfiles/i3-resurrect" "$HOME/.config/i3-resurrect"
	ln -sv "$HOME/dotfiles/i3-workspaces" "$HOME/.config/i3-workspaces"
	echo "[✓] i3 and i3-resurrect successfully configured"


}

# Command Line tools 
function terminal_configuration() {
	# install nerd fonts 
	echo "[=] Customizing the Terminal"


	# install nerd fonts
	echo "[=] Installing Nerd Fonts"
	"$HOME/dotfiles/font_install.sh"
	echo "[✓] Nerd fonts installed"

	# install starship
	echo "[=] installing starship"
	curl -sS https://starship.rs/install.sh | sh
	echo "[✓] starship installed"

	# configure starship
	echo "[=] Configuring starship"
	ln -sv "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"
	echo "[✓] Configuration complete"

	# copy git config
	echo "[=] Setting up .gitconfig"
	ln -sv "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
	echo "[✓] .gitconfig setup complete"

	# configure tmux
	echo "[=] Setup tmux"

	ln -sfv "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

	TPM_DIR="$HOME/.config/tmux/plugins/tpm"
	git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
	
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
	echo "[=] installing neovim"
	pip3 install neovim --break-system-packages
	git clone https://github.com/neovim/neovim "$HOME/neovim"
	cd neovim
	git checkout v0.11.7
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	$SUDO make install
	
	echo "[=] setting up neovim config"
	# set neovim config
	ln -sv "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
	echo "[✓] neovim config setup complete"

	echo "[✓] neovim installed"
}

function install_alacritty() {
	echo "[=] installing alacritty"
	git clone https://github.com/alacritty/alacritty.git "$HOME/alacritty"
	cd alacritty
	curl --proto '=https' --tlsv1.2 -sSf https://sh

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

	echo "[=] setting up alacritty config"
	ln -sv "$HOME/dotfiles/alacritty" "$HOME/.config/alacritty"
	echo "[✓] alacritty config setup successfully"

	echo "[✓] alacritty installed"
}



# Other DEV tools
# uv installation
function install_uv() {
	echo "[=] installing uv"
	curl -LsSf https://astral.sh/uv/install.sh | sh
	echo "[✓] uv installed"
} 
# nvm installation
function install_nvm() {
	echo "[=] installing nvm"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
	echo "[✓] nvm installed"
}

# Setup bashrc files 
function bash_config() {
	# check if the exist
	echo "[=] Setup .bashrc and .bash_aliases"
	[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
	[ -f "$HOME/.bash_aliases" ] && mv "$HOME/.bash_aliases" "$HOME/.bash_aliases.bak"

	# create symlink
	ln -sfv "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"
	ln -sfv "$HOME/dotfiles/.bash_aliases" "$HOME/.bash_aliases"

	# source the config
	source "$HOME/.bashrc"
	echo "[✓] .bashrc and .bash_aliases setup complete"
}

# Command Flow Setup
install_required_tools()

# fetch_dotfiles_repository()

# install_utility_apps()

# terminal_configuration()

# install_i3wm()

# install_neovim()

# install_alacritty()

# install_uv()

# install_nvm()

# bash_config()