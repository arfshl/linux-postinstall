#!/bin/sh

# Updating package database
echo "Updating package database..."
sudo apt update

# Install Google Chrome
echo "Installing Google Chrome..."
mkdir -p $HOME/pkgtmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P $HOME/pkgtmp
sudo apt install $HOME/pkgtmp/google-chrome-stable_current_amd64.deb -y
xdg-settings set default-web-browser google-chrome.desktop
rm $HOME/pkgtmp/google-chrome-stable_current_amd64.deb
ln -s /usr/share/applications/google-chrome.desktop $HOME/Desktop/google-chrome.desktop
chmod -R 755 $HOME/Desktop/
echo "Google Chrome Installed"

# Install OnlyOffice
echo "Installing OnlyOffice as Microsoft Office replacement..."
wget https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb -P $HOME/pkgtmp
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo apt install $HOME/pkgtmp/onlyoffice-desktopeditors_amd64.deb -y
xdg-mime default onlyoffice-desktopeditors.desktop application/pdf
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
xdg-mime default onlyoffice-desktopeditors.desktop application/msword
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-word.document.macroEnabled.12
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-excel
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-excel.sheet.macroEnabled.12
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-excel.sheet.binary.macroEnabled.12
xdg-mime default onlyoffice-desktopeditors.desktop text/csv
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-powerpoint
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-powerpoint.presentation.macroEnabled.12
rm $HOME/pkgtmp/onlyoffice-desktopeditors_amd64.deb
rmdir $HOME/pkgtmp/
ln -s /usr/share/applications/onlyoffice-desktopeditors.desktop $HOME/Desktop/onlyoffice-desktopeditors.desktop
chmod -R 755 $HOME/Desktop/
echo "OnlyOffice Installed"

# Install spotify-client
echo "Installing Spotify Client..."
sudo apt-get install spotify-client -y
ln -s /usr/share/applications/spotify.desktop $HOME/Desktop/spotify.desktop
chmod -R 755 $HOME/Desktop/
echo "Spotify Client Installed"

# Install VLC, UFW, GUFW, systemd-resolved, ttf-mscorefonts firefox
echo "Installing System Tools..."
echo "Installing VLC..."
echo "Installing Microsoft fonts..."
echo "Updating Mozilla Firefox..."
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo apt install vlc ttf-mscorefonts-installer cheese gnome-system-monitor gnome-clocks firefox software-properties-common software-properties-gtk yaru-cinnamon-theme-gtk yaru-cinnamon-theme-icon -y
xdg-mime default vlc.desktop video/mp4
xdg-mime default vlc.desktop video/x-matroska
xdg-mime default vlc.desktop audio/mpeg
xdg-mime default vlc.desktop video/hevc
xdg-mime default vlc.desktop video/webm
ln -s /usr/share/applications/vlc.desktop $HOME/Desktop/vlc.desktop
ln -s /usr/share/applications/firefox.desktop $HOME/Desktop/firefox.desktop
chmod -R 755 $HOME/Desktop/
echo "System Tools Installed"

# Enable UFW, Profile default, Deny incoming, Allow outgoing
echo "Updating Firewall..."
sudo apt install ufw gufw -y
echo "Enabling Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw status verbose


# Enable DNS-Over-TLS with systemd-resolved, Primary server is cloudflare and secondary is google
echo "Updating systemd-resolved..."
sudo apt install systemd-resolved -y
echo "Enabling Encrypted DNS..."
sudo tee -a /etc/systemd/resolved.conf > /dev/null <<EOF
DNS=1.1.1.1#cloudflare-dns.com
FallbackDNS=76.76.2.0#p0.freedns.controld.com
DNSOverTLS=yes
Domains=~.
ReadEtcHosts=yes
EOF

sudo systemctl enable systemd-resolved 
sudo systemctl restart systemd-resolved

# Enable zram with zstd compression algorithm
echo "Installing systemd-zram-generator ..."
sudo apt install systemd-zram-generator -y
echo "Enabling zram..."
[ -f /etc/systemd/zram-generator.conf ] && sudo rm /etc/systemd/zram-generator.conf
sudo tee -a /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = min(ram, 16384)
compression-algorithm = zstd
EOF

sudo tee -a /etc/sysctl.d/99-vm-zram-parameters.conf > /dev/null <<EOF
vm.swappiness = 100
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 62
vm.page-cluster = 0
EOF

sudo sysctl --system > /dev/null
sudo systemctl restart systemd-zram-setup@zram0.service

# Disable apt Pager at Debian 13 or Ubuntu 26.04
echo 'Binary::apt::Pager "false";' | sudo tee -a  /etc/apt/apt.conf.d/99nopager

# Done Process
echo "Welcome to Linux Mint XFCE!"