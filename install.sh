#!/bin/bash

# Dotfiles Installation Script
# Author: osvajac

# ASCII Art
cat << 'EOF'
██████████████████████████████████████████████████████████████████
██████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████ ████████████
████████████████████████████████████████████████████  ████████████
███████████████████████████████████████████████████   ████████████
████████████████████████████████████████████   ███    ████████████
███████████████████████████████████████████ █  ████   ████████████
███████████████████████████████████████████    ████   ████████████
████████████████████████████████████████████   ████   ████████████
█████████████████████████████████████████   ███████   ████████████
██████████████████████████████████████   ██████████   ████████████
███████████████████████████████████████████████████   ████████████
████████████       ████████████████████████████████  █████████████
███████████         ███████████████████████████      █████████████
██████████ ██████  ███████████████████████████           █████ ███
█████████████    ████████████████████████████           █████   ██
█████████████████████████████████████████████████▓     █████    ██
███████████████████████████████████████████████████   ██████    ██
████████  █████████ ██████████████████ ████████      ███████    ██
███████      █████   ████████ ████ █   █           █████████    ██
██████      █████    ██████                     ████████████    ██
█████ ██   ██████                           █████████████████   ██
████  ████████████                    ▓██████████████████████   ██
███  █████████████        ██ ████████████████████████████████   ██
███ ██████████████  █████████████████████████████████████████   ██
██  ███████████    ██████████████████████████████████████████ ████
██                ████████████████████████████████████████████████
███              █████████████████████████████████████████████████
███            ███████████████████████████████████████████████████
██████     ███████████████████████████████████████████████████████
██████████████████████████████████████████████████████████████████
██████████████████████████████████████████████████████████████████
EOF

echo ""
echo "=== Dotfiles Installation Script ==="
echo "This script will install and configure your custom dotfiles setup."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to ask user confirmation
ask_user() {
    local question="$1"
    while true; do
        echo -e "${BLUE}$question (y/n):${NC}"
        read -r answer
        case $answer in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch Linux systems with pacman package manager."
    exit 1
fi

# Check if ~/Dots directory exists
if [ ! -d "$HOME/Dots" ]; then
    print_error "~/Dots directory not found. Please ensure your dotfiles are in ~/Dots"
    exit 1
fi

DOTS_DIR="$HOME/Dots"

# Install suckless utilities dependencies
if ask_user "Install suckless utilities dependencies (dwm, dmenu, slock, slstatus)?"; then
    print_status "Installing suckless dependencies..."
    
    # Essential build dependencies for suckless tools
    sudo pacman -S --needed base-devel libx11 libxft libxinerama libxrandr imlib2 \
        freetype2 fontconfig xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
        xorg-xset alsa-utils libxss
    
    # Build and install suckless tools
    for tool in dwm dmenu slock slstatus; do
        if [ -d "$DOTS_DIR/$tool" ]; then
            print_status "Building and installing $tool..."
            cd "$DOTS_DIR/$tool"
            make clean
            make
            sudo make install
            cd - > /dev/null
        else
            print_warning "$tool directory not found in ~/Dots"
        fi
    done
fi

# Install fonts
if ask_user "Install fonts (JetBrains Mono Nerd Font and Font Awesome)?"; then
    print_status "Installing fonts..."
    
    # Install Font Awesome from official repos
    sudo pacman -S --needed ttf-font-awesome
    
    # Install AUR helper if not present (yay)
    if ! command -v yay &> /dev/null; then
        print_status "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd - > /dev/null
    fi
    
    # Install JetBrains Mono Nerd Font from AUR
    print_status "Installing JetBrains Mono Nerd Font from AUR..."
    yay -S --noconfirm ttf-jetbrains-mono-nerd
    
    # Refresh font cache
    print_status "Refreshing font cache..."
    fc-cache -fv
fi

# Install main applications and dependencies
if ask_user "Install main applications (pywal, mpv, feh, firefox, picom-ftlabs-git)?"; then
    print_status "Installing main applications..."
    
    # Install from official repos
    sudo pacman -S --needed python-pywal mpv feh firefox alacritty kitty dunst neovim \
        ncmpcpp mpd picom
    
    # Install AUR helper if not present (yay) - check again in case fonts step was skipped
    if ! command -v yay &> /dev/null; then
        print_status "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd - > /dev/null
    fi
    
    # Install picom-ftlabs-git from AUR
    print_status "Installing picom-ftlabs-git from AUR..."
    yay -S --noconfirm picom-ftlabs-git
fi

# Copy .config folders
if ask_user "Copy configuration folders to ~/.config?"; then
    print_status "Copying configuration files..."
    
    if [ -d "$DOTS_DIR/.config" ]; then
        # Create ~/.config if it doesn't exist
        mkdir -p "$HOME/.config"
        
        # Copy each config folder
        for config_dir in picom dunst nvim alacritty kitty ncmpcpp mpd; do
            if [ -d "$DOTS_DIR/.config/$config_dir" ]; then
                print_status "Copying $config_dir configuration..."
                cp -r "$DOTS_DIR/.config/$config_dir" "$HOME/.config/"
            else
                print_warning "$config_dir configuration not found in ~/Dots/.config"
            fi
        done
    else
        print_error ".config directory not found in ~/Dots"
    fi
fi

# Handle scripts folder
if ask_user "Install scripts to ~/scripts and copy to /bin?"; then
    print_status "Installing scripts..."
    
    if [ -d "$DOTS_DIR/scripts" ]; then
        # Copy scripts folder to home directory
        cp -r "$DOTS_DIR/scripts" "$HOME/"
        
        # Make all scripts executable in ~/scripts
        print_status "Making scripts executable..."
        if [ -d "$HOME/scripts" ]; then
            for script in "$HOME/scripts"/*; do
                if [ -f "$script" ]; then
                    chmod +x "$script"
                fi
            done
        fi
        
        # Copy scripts to /bin (requires sudo)
        print_status "Copying scripts to /bin (requires sudo)..."
        if [ -d "$HOME/scripts" ]; then
            for script in "$HOME/scripts"/*; do
                if [ -f "$script" ]; then
                    sudo cp "$script" /bin/
                    sudo chmod +x "/bin/$(basename "$script")"
                fi
            done
        fi
    else
        print_error "scripts directory not found in ~/Dots"
    fi
fi

# Handle pywal templates
if ask_user "Install pywal templates?"; then
    print_status "Installing pywal templates..."
    
    if [ -d "$DOTS_DIR/pywal" ]; then
        # Find Python site-packages directory (may vary)
        PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        PYWAL_TEMPLATE_DIR="/usr/lib/python${PYTHON_VERSION}/site-packages/pywal/templates"
        
        if [ -f "$DOTS_DIR/pywal/dwm.Xresources" ]; then
            sudo cp "$DOTS_DIR/pywal/dwm.Xresources" "$PYWAL_TEMPLATE_DIR/"
            print_status "Copied dwm.Xresources to pywal templates"
        fi
        
        if [ -f "$DOTS_DIR/pywal/.Xresources" ]; then
            cp "$DOTS_DIR/pywal/.Xresources" "$HOME/"
            print_status "Copied .Xresources to home directory"
        fi
    else
        print_error "pywal directory not found in ~/Dots"
    fi
fi

# Copy .bashrc
if ask_user "Copy .bashrc to home directory?"; then
    if [ -f "$DOTS_DIR/.bashrc" ]; then
        cp "$DOTS_DIR/.bashrc" "$HOME/"
        print_status "Copied .bashrc to home directory"
    else
        print_error ".bashrc not found in ~/Dots"
    fi
fi

# Handle Firefox configuration
if ask_user "Install Firefox Textfox theme?"; then
    print_status "Setting up Firefox Textfox theme..."
    
    if [ -d "$DOTS_DIR/firefox/textfox" ] && [ -f "$DOTS_DIR/firefox/textfox/chrome" ]; then
        # Find Firefox profile directory
        FIREFOX_PROFILE_DIR=$(find "$HOME/.mozilla/firefox" -name "*.default*" -type d | head -n 1)
        
        if [ -n "$FIREFOX_PROFILE_DIR" ]; then
            mkdir -p "$FIREFOX_PROFILE_DIR/chrome"
            cp "$DOTS_DIR/firefox/textfox/chrome" "$FIREFOX_PROFILE_DIR/chrome/"
            print_status "Copied Firefox Textfox theme to profile directory"
        else
            print_warning "Firefox profile directory not found. Please run Firefox first to create a profile."
        fi
    else
        print_error "Firefox textfox chrome file not found in ~/Dots/firefox/textfox/"
    fi
fi

# Final steps and recommendations
echo ""
echo -e "${GREEN}=== Done ===${NC}"
echo ""
echo "- Restart your terminal or run 'source ~/.bashrc' to load new bash configuration"
echo "- Run wallpaper to generate your first color scheme"
echo "- Configure dwm's config.h file because there are places you need to replace your username with"
echo "- Configure MPD by running 'mpd' and setting up your music directory"
echo "- Restart Firefox to apply the Textfox theme"
echo ""
echo -e "${YELLOW}Note:${NC} Some configurations may require a system restart to take full effect."
echo ""
echo "=== Enjoy ==="
