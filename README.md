# Linux Post-Install scripts
This project aims to make Linux workstation setup faster, but also more secure for both home and and education usage

## Features
- One-click installation, Just copy-paste command on Terminal
- Automates installation of daily-usage apps and Microsoft fonts
- Adding App Shortcut to Desktop for easy access
- Enable Firewall
- Enable [zram](https://wiki.archlinux.org/title/Zram)
- Setup DNS over TLS with systemd-resolved, using Cloudflare and Google DNS

## Auto-Installed Apps
- Google Chrome
- [OnlyOffice](https://www.onlyoffice.com/download-desktop.aspx) as Microsoft Office replacement, but you can still access Office Online or Google Workspaces via web browser
- VLC Media Player
- Spotify Linux Client
- GNOME Cheese (Camera App)
- GNOME Clocks
- Microsoft Corefonts (with `ttf-mscorefonts-installer` packages)

## Usage
Just copy-paste the commands to your terminal and execute. The script will automatically downloaded and executed

- Linux Mint Cinnamon, Linux Mint MATE, and Linux Mint Debian Edition

      curl -fssL https://raw.githubusercontent.com/arfshl/linuxmint-postinstall/refs/heads/main/linuxmint/cinnamon.sh | bash
  
- Linux Mint XFCE

      curl -fssL https://raw.githubusercontent.com/arfshl/linuxmint-postinstall/refs/heads/main/linuxmint/xfce.sh | bash

- Kubuntu or Debian KDE, with snapd disabled and comfy tools (if you want Linux mint feelings and feature, but with KDE Plasma desktop)

      curl -fssL https://raw.githubusercontent.com/arfshl/linuxmint-postinstall/refs/heads/main/debian/minty-kde.sh | bash

## All Debian-based distribution, but without shortcut to desktop

Works on:
- All Ubuntu and Debian flavor and desktop
- Zorin OS
- Pop! OS
- Linux Lite
- MX Linux [Enable systemd first!](https://mxlinux.org/wiki/system/systemd/)
- Elementary OS
- KDE Neon
- AnduinOS
- Q4OS
- And many more!

      curl -fssL https://raw.githubusercontent.com/arfshl/linuxmint-postinstall/refs/heads/main/debian/debian.sh | bash

## Enable swap manually if not enabled by default (4GB is default size)

      sudo fallocate -l 4G /swapfile1 && sudo chmod 600 /swapfile1 && sudo mkswap /swapfile1 && sudo swapon /swapfile1 && echo '/swapfile1 none swap sw 0 0' | sudo tee -a /etc/fstab

## VMware Tools

If you installing on VMware, use this command to install the drivers

      sudo apt install open-vm-tools-desktop -y

# Personal Setup
I also post my own setup script [here](https://github.com/arfshl/linuxmint-postinstall/tree/main/personal-use)
