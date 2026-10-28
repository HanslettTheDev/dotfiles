# Ensure the following is installed
git
curl
wget
snap
python3-pip
fzf
python3-venv
make
gcc/build-essential
tmux
tree

# Run this first
sudo apt-get update 

# Telegram installation
sudo snap install telegram-desktop

# Chrome Installation
curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
sudo apt-get update
**// for any issues when opening chrome on ubuntu 24.04 and above in i3, run this command**
cp /usr/share/applications/google-chrome.desktop ~/.local/share/applications/
**// then edit each file manually to add this line anywhere you see `Exec` before %U**
--ozone-platform=x11

## i3wm stuff
sudo apt install i3 xdotool maim xclip
### change apt repository for i3 (ubuntu 22.04)
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2025.12.14_all.deb keyring.deb SHA256:2c816fbd12ea4d84811818aed0ce3a5da589be1afa30833eb32abc1e4fe6349e
sudo apt install ./keyring.deb
echo "deb [signed-by=/usr/share/keyrings/sur5r-keyring.gpg] http://debian.sur5r.net/i3/ $(grep '^VERSION_CODENAME=' /etc/os-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install i3

## i3resurrect
git clone git@github.com:JonnyHaystack/i3-resurrect.git
cd i3-resurrect
pip3 install --user . --break-system-packages

## Terminal stuff

# Installing nvm(node version manager) it will handle node and npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# fonts
chmod +x font_install.sh
./font_install.sh

# starship
curl -sS https://starship.rs/install.sh | sh

# tmux
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
**// before running this command, ensure tmux is running**
tmux source ~/.tmux.conf

# uv installation

curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
uv python install 3.12

# Neovim installation

### build tools for neovim
sudo apt-get install ninja-build gettext
sudo apt install ripgrep python3-pip unzip fd-find
pip3 install neovim --break-system-packages
git clone https://github.com/neovim/neovim
cd neovim
git checkout v0.11.7
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
config-dir = $HOME/.config/nvim


# Alacritty Installation
git clone https://github.com/alacritty/alacritty.git
cd alacritty
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
**// ensure I have the right rust compiler**
rustup override set stable
rustup update stable
**// Source this config to ensure rustup is available for use**
source .bashrc
**// dependencies to build alacritty**
sudo apt install cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 gzip scdoc
cargo build --release
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
infocmp alacritty
**// Add alacritty desktop icon for wayland**
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
**// setting up the man page**
sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
sudo mkdir -p /usr/local/share/man/man7
scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
scdoc < extra/man/alacritty-escapes.7.scd | gzip -c | sudo tee /usr/local/share/man/man7/alacritty-escapes.7.gz > /dev/null
**// Add shell completion(I choose these commands since I plan to delete the alacritty source directory after installation)**
mkdir -p ~/.bash_completion
cp extra/completions/alacritty.bash ~/.bash_completion/alacritty

# set background image

# Install docker
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker

**If docker isn't running**
sudo systemctl start docker
sudo docker run hello-world
# For managing and running test containers on linux
# install lxd and lxc

sudo snap install lxd

# Install LXD
sudo snap install lxd

# Add your current user to the lxd group
sudo usermod -aG lxd $USER
newgrp lxd

# Initialize LXD (press Enter to accept the standard defaults for networking/storage)
lxd init

lxc launch ubuntu:22.04 dotfile-sandbox

# take a snapshot of the container and restore later if a script breaks
lxc snapshot dotfile-sandbox clean-slate
lxc restore dotfile-sandbox clean-slate


# login to the container
lxc exec dotfile-sandbox -- /bin/bash

# create regular user
# Create the user and set a password
adduser testuser

# Add the user to the sudo group
usermod -aG sudo testuser

lxc exec dotfile-sandbox --user 1000 -- bash

or

lxc exec dotfile-sandbox -- su - testuser


# wipe the container
lxc delete dotfile-sandbox --force
