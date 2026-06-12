#!/bin/sh

# env is ubuntu based Linux
# do aftermount only

# add latest firefox, thunderbird and keepassxc ppa
sudo apt update
sudo install -d -m 0755 /etc/apt/keyrings
sudo apt-get install wget -y
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
sudo add-apt-repository ppa:phoerious/keepassxc -y

# no snap installation or enforcing
echo 'Configuring APT Pinning...'
sudo tee /etc/apt/preferences.d/nativeapt > /dev/null <<EOF
Package: *
Pin: origin deb.debian.org
Pin-Priority: 1

Package: *
Pin: origin security.debian.org
Pin-Priority: 1

Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: chromium
Pin: origin security.debian.org
Pin-Priority: 1000

Package: chromium-common
Pin: origin security.debian.org
Pin-Priority: 1000

Package: chromium-sandbox
Pin: origin security.debian.org
Pin-Priority: 1000

Package: firefox
Pin: release o=Ubuntu
Pin-Priority: -1

Package: thunderbird
Pin: release o=Ubuntu
Pin-Priority: -1

Package: chromium-browser
Pin: release o=Ubuntu
Pin-Priority: -1

Package: snapd
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

echo 'Done'

# Install required tools
sudo apt install vlc firefox-devedition torbrowser-launcher keepassxc adb zram-tools partitionmanager btop htop lynx brasero default-jre wget curl nano git systemd-timesyncd ufw gufw apache2 bind9 simplescreenrecorder linux-headers-$(uname -r) build-essential libayatana-appindicator3-1 -y

# install protonvpn
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb && sudo dpkg -i ./protonvpn-stable-release_*_all.deb && sudo rm protonvpn-stable-release_*_all.deb && sudo apt update && sudo apt install proton-vpn-gnome-desktop -y

# generate custom grub config (disable os-prober, block kvm module, amoled black grub wallpaper, and enable verbose boot)
# cp /home/alif/D_DRIVE/Linux/Packages/1.png /home/alif/1.png
sudo mv /etc/default/grub /etc/default/grub.bak
sudo tee /etc/default/grub > /dev/null <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=-1
GRUB_DISTRIBUTOR='Kubuntu'
#GRUB_CMDLINE_LINUX_DEFAULT='quiet splash'
#GRUB_CMDLINE_LINUX_DEFAULT='kvm.enable_virt_at_load=0'
GRUB_CMDLINE_LINUX_DEFAULT=''
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_OS_PROBER=false
EOF
sudo update-grub

# disable apt pager
echo 'Binary::apt::Pager "false";' | sudo tee -a  /etc/apt/apt.conf.d/99nopager

# Set local rtc clock, same with the system clock, for dualboot systems
sudo timedatectl set-local-rtc 1

# install all local .deb apps
cd /home/alif/D_DRIVE/Linux/Packages/
sudo apt install ./*.deb

# add gh desktop repo
sudo curl https://gpg.polrivero.com/public.key | sudo gpg --dearmor -o /usr/share/keyrings/polrivero.gpg
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/polrivero.gpg] https://deb.github-desktop.polrivero.com/ stable main" | sudo tee /etc/apt/sources.list.d/github-desktop-plus.list
sudo apt update && sudo apt install github-desktop-plus -y

# add vscode repo and install
sudo apt install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/code.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
sudo apt update && sudo apt install code # or code-insiders

# install vmware-workstation
sudo ./VM*

# Copy Applications folder to home
cd
cp -r /home/alif/D_DRIVE/Linux/Applications /home/alif/Applications

# Enable powertunnel services
cd /home/alif/Applications/PowerTunnel/
sudo cp /home/alif/Applications/PowerTunnel/powertunnel.service /etc/systemd/system/powertunnel.service
sudo systemctl enable powertunnel
sudo systemctl start powertunnel

# Enable AdGuardHome
sudo systemctl stop named
sudo systemctl disable named
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
cd /home/alif/Applications/AdGuardHome
sudo ./AdGuardHome -s install
sudo systemctl start AdGuardHome

# disable networkmanager management for /etc/resolv.conf
#sudo tee /etc/NetworkManager/conf.d/nodns.conf > /dev/null <<EOF
#[main]
#dns=none
#EOF

# rewrite /etc/resolv.conf
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
echo 'nameserver 127.0.0.1' | sudo tee -a /etc/resolv.conf

# disable networkmanager management for /etc/resolv.conf
sudo tee /etc/NetworkManager/conf.d/nodns.conf > /dev/null <<EOF
[main]
dns=none
EOF
sudo systemctl restart NetworkManager

# Enable UFW, Profile default, Deny incoming, Allow outgoing
echo "Updating Firewall..."
sudo apt install ufw gufw -y
echo "Enabling Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw status verbose
sudo ufw allow 53317/tcp
sudo ufw allow 53317/udp
sudo ufw allow 21118/tcp
sudo ufw allow 21118/udp

# Enable zram with lz4 compression algorithm
echo "Installing zram-tools..."
sudo apt install zram-tools -y
echo "Enabling zram..."
echo 'ALGO=lz4
PERCENT=50' | sudo tee -a /etc/default/zramswap
echo 'vm.page-cluster = 0' | sudo tee -a /etc/sysctl.conf

# Enable swapfile with 4GB of size
sudo fallocate -l 4G /swapfile1 && sudo chmod 600 /swapfile1 && sudo mkswap /swapfile1 && sudo swapon /swapfile1 && echo '/swapfile1 none swap sw 0 0' | sudo tee -a /etc/fstab

# remove unnecessary package
sudo apt purge libreoffice* thunderbird gimp konqueror juk dragonplayer kmail akregator -y

# install nodejs lts
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install lts/*
# Verify the Node.js version:
node -v # Should print "v24.15.0".
# Download and install Yarn:
corepack enable yarn
# Verify Yarn version:
yarn -v
npm install -g http-server
