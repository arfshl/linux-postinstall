#!/bin/sh

# env is ubuntu gnome
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

# no snap installation or enforcing
echo 'Configuring APT Pinning...'
sudo tee /etc/apt/preferences.d/nativeapt > /dev/null <<EOF
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
sudo apt install vlc firefox-devedition adb btop htop lynx brasero wget curl nano git systemd-timesyncd gedit ufw gufw obs-studio systemd-zram-generator linux-headers-$(uname -r) build-essential libayatana-appindicator3-1 fastfetch software-properties-common software-properties-gtk libssl3 -y

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

# install docker engine
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

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

# install vmware-workstation
sudo ./VM*

# Copy Applications folder to home
cd
cp -r /home/alif/D_DRIVE/Linux/Applications /home/alif/Applications


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

# enhance zram
echo "Enabling zram..."
sudo tee -a /run/systemd/zram-generator.conf > /dev/null <<EOF
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

# use native ntfsplus driver
sudo apt remove ntfs-3g
sudo systemctl daemon-reload
echo 'defaults,uid=1000,gid=1000,fmask=0000,dmask=0022,windows_names,noatime'

sudo tee /etc/udisks2/mount_options.conf > /dev/null <<EOF
[defaults]
ntfs_defaults=uid=$UID,gid=$GID
EOF

# Enable swapfile with 4GB of size
sudo fallocate -l 4G /swapfile1 && sudo chmod 600 /swapfile1 && sudo mkswap /swapfile1 && sudo swapon /swapfile1 && echo '/swapfile1 none swap sw 0 0' | sudo tee -a /etc/fstab

