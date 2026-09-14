#!/bin/sh
# this is my personal customization for the applist
# env is fedora spin kde

# enable rpmfusion and mozilla repo
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf makecache --refresh
sudo dnf install rpmfusion-*-appstream-data rpmfusion-*-tainted -y
sudo dnf config-manager addrepo --id=mozilla --set=baseurl=https://packages.mozilla.org/rpm/firefox --set=gpgkey=https://packages.mozilla.org/rpm/firefox/signing-key.gpg --set=repo_gpgcheck=0
sudo dnf makecache --refresh

# install package
sudo dnf install android-tools libayatana-appindicator-gtk3 keepassxc firefox kate btop htop git java-25-openjdk-headless torbrowser-launcher dnsutils httpd kernel-devel kernel-headers -y
sudo dnf install vlc vlc-plugins-freeworld ffmpeg intel-media-driver libdvdcss mesa-va-drivers-freeworld mesa-va-drivers-freeworld.i686 mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld qt5-qtwebengine-freeworld telegram-desktop --allowerasing -y
# libva-intel-driver libva-nvidia-driver libva-nvidia-driver.{i686,x86_64}
sudo dnf install @development-tools
curl -LO https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo dnf install curl cabextract xorg-x11-font-utils fontconfig -y
sudo rpm -ivh --nodigest --nofiledigest ./msttcore-fonts-installer-2.6-1.noarch.rpm
fc-cache -f -v
# mark as user installed
sudo dnf mark user java-25-openjdk-headless -y

# generate custom grub config (disable os-prober, block kvm module, amoled black grub wallpaper, and enable verbose boot)
sudo mv /etc/default/grub /etc/default/grub.bak
sudo tee /etc/default/grub > /dev/null <<EOF
GRUB_TIMEOUT=-1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rhgb quiet"
#GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EOF
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

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

# install protonvpn
wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d' ' -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm" && sudo dnf install ./protonvpn-stable-release-1.0.3-1.noarch.rpm && sudo dnf check-update --refresh  && sudo dnf install proton-vpn-gnome-desktop 

# Set local rtc clock, same with the system clock, for dualboot systems
timedatectl set-local-rtc 1

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
cd /home/alif/D_DRIVE/Applications/AdGuardHome
sudo ./AdGuardHome -s install
sudo systemctl start AdGuardHome

# rewrite /etc/resolv.conf
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
echo 'nameserver 127.0.0.1' | sudo tee -a /etc/resolv.conf

# disable networkmanager management for /etc/resolv.conf
sudo tee /etc/NetworkManager/conf.d/nodns.conf > /dev/null <<EOF
[main]
dns=none
EOF
sudo systemctl restart NetworkManager

# remove
sudo dnf remove thunderbird libreoffice* dragonplayer elisa akregator kmahjongg kmines kwrite kpatience korganizer neochat kmail kpat -y

# allowport for localsend
sudo firewall-cmd --permanent --add-port=53317/tcp
sudo firewall-cmd --permanent --add-port=53317/udp
sudo firewall-cmd --permanent --add-port=21118/tcp
sudo firewall-cmd --permanent --add-port=21118/udp
sudo firewall-cmd --reload

# install weathr rust app
rustup toolchain install stable
cargo install weathr
sudo ln -s /home/alif/.cargo/bin/weathr /usr/bin/weathr
mkdir -p /home/alif/.config/weathr/
tee /home/alif/.config/weathr/config.toml > /dev/null <<EOF
# Hide the HUD (Heads Up Display) with weather details
hide_hud = false

# Run silently without startup messages (errors still shown)
silent = false

[location]
# Location coordinates (overridden if auto = true)
latitude = -3.6486
longitude = 103.771

# Auto-detect location via IP (defaults to true if config missing)
auto = false

# Hide the location name in the UI
hide = false

[units]
# Temperature unit: "celsius" or "fahrenheit"
temperature = "celsius"

# Wind speed unit: "kmh", "ms", "mph", or "kn"
wind_speed = "kmh"

# Precipitation unit: "mm" or "inch"
precipitation = "mm"
EOF


