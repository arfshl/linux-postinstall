#!/bin/sh
# this is my personal customization for the applist
# env is fedora gnome

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
sudo dnf mark user java-25-openjdk-devel -y

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

# install fnm
curl -fsSL https://fnm.vercel.app/install | bash
fnm install lts/*

# install protonvpn
wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d' ' -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm" && sudo dnf install ./protonvpn-stable-release-1.0.3-1.noarch.rpm && sudo dnf check-update --refresh  && sudo dnf install proton-vpn-gnome-desktop 

# Set local rtc clock, same with the system clock, for dualboot systems
timedatectl set-local-rtc 1

# Enable AdGuardHome
sudo systemctl stop named
sudo systemctl disable named
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
cd /home/alif/Applications/AdGuardHome
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
sudo dnf remove thunderbird libreoffice* gnome-boxes -y

# allowport for localsend
sudo firewall-cmd --permanent --add-port=53317/tcp
sudo firewall-cmd --permanent --add-port=53317/udp
sudo firewall-cmd --permanent --add-port=21118/tcp
sudo firewall-cmd --permanent --add-port=21118/udp
sudo firewall-cmd --reload

# install fdm localsend and flatseal flatpak
flatpak install org.localsend.localsend_app org.freedownloadmanager.Manager com.github.tchx84.Flatseal

# enhance zram
echo "Enabling zram..."
[ -f /usr/lib/systemd/zram-generator.conf ] && sudo rm /usr/lib/systemd/zram-generator.conf
sudo tee -a /usr/lib/systemd/zram-generator.conf > /dev/null <<EOF
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

# enable 4gb swap
sudo touch /swapfile1 && sudo chattr +C /swapfile1 && sudo dd if=/dev/zero of=/swapfile1 bs=1M count=4096 status=progress && sudo chmod 600 /swapfile1 && sudo mkswap /swapfile1 && sudo swapon /swapfile1 && echo '/swapfile1 none swap sw 0 0' | sudo tee -a /etc/fstab