#!/bin/bash
# Set -e to exit immediately if a command exits with a non-zero status
set -e

# --- 1. Preparation ---

echo "Starting SoloLinux setup..."

# Ensure we are in the home directory
cd ~

# Define the repository URL
SOLOLINUX_REPO="https://github.com/Solomon-DbW/SoloLinux"

# --- 2. System and Core Package Installation ---

# IMPORTANT: Always perform a full system update before installing new packages on Arch.
# This prevents "partial upgrades" which can break the system.
echo "Performing full system update (pacman -Syu)..."
sudo pacman -Syu --noconfirm

# Install pacman packages
# Removed duplicates and grouped by function for clarity.
# Added '--noconfirm' for a non-interactive script.
echo "Installing core and application packages..."
sudo pacman -S --noconfirm \
    git curl \
    linux linux-firmware \
    arch-install-scripts pacman-mirrorlist man-db man-pages \
    vim neovim emacs \
    zsh starship \
    rofi hyprland waybar hyprpaper hyprlock wlogout waypaper swaync mako \
    kitty tmux \
    firefox \
    gdm gnome-shell gnome-control-center xdg-user-dirs gnome-desktop nemo \
    networkmanager wpa_supplicant dialog openresolv network-manager-applet \
    ttf-dejavu noto-fonts noto-fonts-emoji ttf-font-awesome ttf-jetbrains-mono \
    pipewire pavucontrol \
    libreoffice \
    brightnessctl cpufetch fastfetch \
    zoxide eza fzf jq ast-grep figlet cava \
    yarn npm nodejs jupyter-notebook \
    lua-language-server ghc haskell-language-server \
    qemu yazi \
    base-devel # Added for later yay compilation

# --- 3. Shell Setup ---

# Install oh-my-zsh FIRST so $ZSH_CUSTOM is defined correctly.
echo "Installing Oh My Zsh..."
# Use 'runzsh=no' to prevent the install script from immediately switching the shell
# and breaking the current script flow.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
# If the above fails, you might need to use the method below:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh-autosuggestions (Now $ZSH_CUSTOM should be defined)
echo "Installing zsh-autosuggestions plugin..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Change shell to zsh (Moved after zsh setup)
echo "Changing default shell to zsh..."
sudo chsh -s $(which zsh) "$USER" # Use "$USER" for robustness, though usually implied

# --- 4. AUR Helper Installation (yay) ---

# NOTE: AUR build tools (makepkg) MUST be run as a regular user, not root.
echo "Installing AUR helper 'yay'..."
if [ -d "yay" ]; then
    rm -rf yay
fi
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# --- 5. Configuration (Dotfiles) ---

# Get SoloLinux config files
echo "Cloning SoloLinux config files..."
git clone "$SOLOLINUX_REPO"

# Remove pre-existing config files and replace them with SoloLinux files
# Added backups and a dedicated loop for cleaner config management.
echo "Removing existing configs and replacing them with SoloLinux files (Backups created)..."
declare -A configs=(
    [emacs]=".config"
    [hypr]=".config"
    [kitty]=".config"
    [nvim]=".config"
    [rofi]=".config"
    [waybar]=".config"
    [fastfetch]=".config"
    [starship.toml]=".config"
)

# Handle directory/file moves
for src in "${!configs[@]}"; do
    dest_dir="${configs[$src]}"
    dest_path="$HOME/$dest_dir/$src"
    solo_path="$HOME/SoloLinux/$src"

    if [ "$src" == "starship.toml" ]; then
        solo_path="$HOME/SoloLinux/starship.toml" # Correct source path for the file
    elif [ "$src" == "tmux" ]; then
        solo_path="$HOME/SoloLinux/tmuxconffile"
        dest_path="$HOME/.tmux.conf"
    elif [ "$src" == "zshrc" ]; then
        solo_path="$HOME/SoloLinux/zshrcfile"
        dest_path="$HOME/.zshrc"
    fi

    if [ -e "$dest_path" ]; then
        echo "   -> Backing up $dest_path to $dest_path.bak"
        mv "$dest_path" "$dest_path.bak"
    fi
    echo "   -> Moving $solo_path to $dest_path"
    mv "$solo_path" "$dest_path"
done

# Specific cleanups mentioned in original script
rm -rf ~/.config/emacs/elpaca 
rm -rf ~/SoloLinux # Remove the repo clone

# --- 6. AUR and Third-Party Installs ---

# Install Brave browser (Using curl | sh is generally discouraged, but kept for consistency)
echo "Installing Brave browser..."
curl -fsS https://dl.brave.com/install.sh | sh

# Install AUR packages via 'yay' (Removed redundant packages)
echo "Installing AUR packages via yay..."
yay -S --noconfirm hyprshade hyprshot-gui git-credential-manager-bin ags

# --- 7. Cosmetic OS Name Change ---

OS_RELEASE_FILE="/etc/os-release"

# Backup the original file
echo "Backing up $OS_RELEASE_FILE to ${OS_RELEASE_FILE}.bak"
sudo cp "$OS_RELEASE_FILE" "${OS_RELEASE_FILE}.bak"

# Replace NAME and PRETTY_NAME
echo "Changing OS name to SoloLinux..."
sudo sed -i 's/^NAME="Arch Linux"/NAME="SoloLinux"/' "$OS_RELEASE_FILE"
sudo sed -i 's/^PRETTY_NAME="Arch Linux"/PRETTY_NAME="SoloLinux"/' "$OS_RELEASE_FILE"

echo "OS name changed to SoloLinux in $OS_RELEASE_FILE."

echo "--- Setup Complete! ---"
