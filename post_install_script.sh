# Ensure we are in the home directory
cd ~/

# Install pacman packages
sudo pacman -Sy git curl linux linux-firmware arch-install-scripts pacman-mirrorlist man-db man-pages vim  zsh starship rofi  gdm gnome-shell gnome-control-center xdg-user-dirs  hyprland waybar  emacs neovim kitty firefox  networkmanager wpa_supplicant dialog openresolv  ttf-dejavu noto-fonts noto-fonts-emoji ttf-font-awesome  zsh hyprland waybar hyprpaper rofi kitty nvim tmux firefox gnome-desktop libreoffice emacs brightnessctl pipewire starship zoxide eza fzf cpufetch jq yarn npm nodejs jupyter-notebook brightnessctl emacs ttf-jetbrains-mono pavucontrol  nemo gnome-desktop libreoffice yarn npm nodejs jupyter-notebook mako lua-language-server ghc haskell-language-server pipewire yazi hyprlock fzf fastfetch neofetch wlogout waypaper networkmanager network-manager-applet qemu cava swaync ast-grep figlet

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Get SoloLinux config files
git clone https://github.com/Solomon-DbW/SoloLinux

# Remove pre-existing config files and replace them with SoloLinux files
rm -rf ~/.config/emacs && mv ~/SoloLinux/emacs ~/.config && rm -rf ~/.config/emacs/elpaca # Elpaca directory removed to avoid startup issues
rm -rf ~/.config/hypr && mv ~/SoloLinux/hypr ~/.config
rm -rf ~/.config/kitty && mv ~/SoloLinux/kitty ~/.config
rm -rf ~/.config/nvim && mv ~/SoloLinux/nvim ~/.config
rm -rf ~/.config/rofi && mv ~/SoloLinux/rofi ~/.config
rm -rf ~/.config/waybar && mv ~/SoloLinux/waybar ~/.config
rm -rf ~/.config/fastfetch && mv ~/SoloLinux/fastfetch ~/.config
rm -rf ~/.config/starship.toml && mv ~/SoloLinux/starship.toml ~/.config
rm -rf ~/.tmux.conf && mv ~/SoloLinux/tmuxconffile ~/.tmux.conf
rm -rf ~/.zshrc && mv ~/SoloLinux/zshrcfile ~/.zshrc

# Change shell to zsh
sudo chsh -s $(which zsh)

# Install yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Brave browser
curl -fsS https://dl.brave.com/install.sh | sh

# Install AUR packages via 'yay'
yay -S hyprshade hyprshot-gui git-credential-manager-bin neofetch wlogout waypaper ags

OS_RELEASE_FILE="/etc/os-release"

# Backup the original file
sudo cp "$OS_RELEASE_FILE" "${OS_RELEASE_FILE}.bak"

# Replace NAME and PRETTY_NAME
sudo sed -i 's/^NAME="Arch Linux"/NAME="SoloLinux"/' "$OS_RELEASE_FILE"
sudo sed -i 's/^PRETTY_NAME="Arch Linux"/PRETTY_NAME="SoloLinux"/' "$OS_RELEASE_FILE"

echo "OS name changed to SoloLinux in $OS_RELEASE_FILE."
echo "Original file backed up as ${OS_RELEASE_FILE}.bak"
