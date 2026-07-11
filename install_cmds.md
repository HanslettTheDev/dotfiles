# Ensure the following is installed
git
curl
wget
snap

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

## i3resurrect
git clone git@github.com:JonnyHaystack/i3-resurrect.git
cd i3-resurrect
pip3 install --user . --break-system-packages

## Terminal stuff

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

# Neovim installation

### build tools for neovim
sudo apt-get install ninja-build gettext cmake curl build-essential git
sudo apt install ripgrep npm python3-pip unzip
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


