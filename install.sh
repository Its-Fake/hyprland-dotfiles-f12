#!/bin/bash

# abort by errors 
set -e

echo "stow install for symlinks"
sudo pacman -S --needed stow

echo "remove standard .bashrc"
rm -rf ~/.bashrc

echo "link dotfiles with stow"
for dir in */; do
    pkg=$(basename "$dir")
    if [ "$pkg" == ".git" ]; then continue; fi

    echo "stowing $pkg..."
    stow -R -v "$pkg"
done

echo ""
read -p "do you want to install the packages from pkglist? (y/n): " confirm_pacman
if [[ "$confirm_pacman" =~ ^[Yy]$ ]]; then
    echo "install packages..."
    grep -v '^#' pkglist | sudo pacman -S --needed -
else
    echo "-> skip packages"
fi

# --- YAY INSTALLATION ---
echo ""
read -p "do you want to install yay (AUR helper) for the aur packages? (y/n): " confirm_yay
if [[ "$confirm_yay" =~ ^[Yy]$ ]]; then
    if ! command -v yay &> /dev/null; then
        echo "install yay..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "-> yay is already installed"
    fi
else
    echo "-> skip yay installation"
fi

# --- AUR PAKETE ---
echo ""
read -p "do you want to install the packages from aurlist? if yes --noconfirm is used (y/n): " confirm_aur
if [[ "$confirm_aur" =~ ^[Yy]$ ]]; then
    # security check: only works if yay is installed
    if command -v yay &> /dev/null; then
        echo "install AUR packages..."
        # grep filter the comments
        yay -S --needed --noconfirm $(grep -v '^#' aurlist)
    else
        echo "ERROR: can't install AUR packages, because yay isn't installed"
    fi
else
    echo "-> skip AUR packages"
fi

echo ""
echo " hyprland should be ready to run"
