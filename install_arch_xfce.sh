#!/bin/bash
#-*- coding: UTF8 -*-

#--------------------------------------------------#
# Script_Name: install_arch_xfce.sh	                               
#                                                   
# Author:  'dossantosjdf@gmail.com'                 
# Date: dim. 08 août 2021 04:29:15                                             
# Version: 1.0                                      
# Bash_Version: 5.0.17(1)-release                                     
#--------------------------------------------------#
# Description: 
# Ce script permet d'automatiser l'iinstallation d'Arch Linux sur clé USB
#                                                   
#                                                                                                      
#  Usage:
#  ./install_arch_xfce.sh -[h|v]
#  
#  ./install_arch_xfce.sh -d <Disque>:<Passe chiffrement> -u <Nom utilisateur>:<Passe utilisateur> -n <Nom machine>
#  
#  -h : Affiche l'aide.
#  -v : Affiche la version.
#  
#  -n : Nom de la machine.
#  -u : Nom utilisateur suivie du mot de passe utilisateur.  Ex: (daniel:****)
#  -d : Nom du disque suivie sa passe phrase de chiffrement. Ex: (sda:***************)
# 
#
#  Exemples:
#  * Pour Installer Arch Linux sur un périphérique physique (hd, ssd, usb):
#  sudo "${0}" -d sdb:*************** -u daniel:******** -n Arch
#
#                                                   
# Limits:                                           
#                                                   
# Licence:                                          
#--------------------------------------------------#

#set -eu

### Includes ###

### Fonctions ###

usage() {
  cat << EOF
  
  ___ Script : $(basename "${0}") ___
  
  Le script doit être lancé en tant que root.
  
  Rôle:                                          

  Détail des fonctionnalités :

  Usage:
  ./$(basename "${0}") -[h|v]
  
  ./$(basename "${0}") -d <disque>:<passe chiffrement> -u <nom utilisateur>:<pass utilisateur> -n <hostname>
  
  -h : Affiche cette page.
  -v : Affiche la version.
  
  -n : Nom de la machine.
  -u : Nom utilisateur suivie du mot de passe utilisateur.  Ex: (daniel:****)
  -d : Nom du disque suivie sa passe phrase de chiffrement. Ex: (sda:***************)
  
  Exemples:
  * Pour Installer Arch Linux sur un périphérique physique (hd, ssd, usb):
  sudo "${0}" -d sdb:*************** -u daniel:******** -n Arch
  
EOF
}


version() {
  local ver='1'
  local dat='08/08/21'
  cat << EOF
  
  ___ Script : $(basename "${0}") ___
  
  Version : "${ver}"
  Date : "${dat}"
  
EOF
}


execute_it_again() {
if [[ -f /tmp/arch_install_usb ]]
then
  alert_info "E" "Impossible de relancer le scripte, il faut redémarrer d'abord !"
  exit 1
fi

touch /tmp/arch_install_usb
}


check_disk_name() {
  local disk="$1"
  local regex="^[s][d][a-z]$"

  if [[ $disk_name =~ ${regex} ]]
  then
    echo "Disque : /dev/${disk}"
  else
    alert_info 'E' 'Erreur de saisie (nom du disque)!'
    usage
    exit 1
  fi
}

alert_info() {
  local msg1="${1}" # $1 : E = ERREUR, I = INFO
  local msg2="${2}" # $2 : Informations.

  #Colors
  local red="\033[0;31m"
  local green="\033[0;32m"
  local nc="\033[0m" # Stop Color

  if [[ ${1} == 'E' ]]
  then
    echo -e "\n${red}>>> $msg1 : $msg2 ...${nc}\n"
  elif [[ ${1} == 'I' ]]
  then
    echo -e "\n${green}>>> $msg1 : $msg2 ...${nc}\n"
  else
    echo -e "\n>>> $msg2 ...\n"
  fi
}

start_end() {
clear

cat <<"EOF"

    _    ____   ____ _   _     ___ _   _ ____ _____  _    _     _
   / \  |  _ \ / ___| | | |   |_ _| \ | / ___|_   _|/ \  | |   | |
  / _ \ | |_) | |   | |_| |    | ||  \| \___ \ | | / _ \ | |   | |
 / ___ \|  _ <| |___|  _  |    | || |\  |___) || |/ ___ \| |___| |___
/_/   \_\_| \_\\____|_| |_|___|___|_| \_|____/ |_/_/   \_\_____|_____|
                         |_____|

EOF

sleep 2
}

#### Main ####
start_end

execute_it_again

# User
user_pass=''

# Disque name and crypt pass
disk_crypt=''

# Hostname and root pass
host_name=''

# Grub
grub_background=true

# Keyboard layout
Keyboard_layout='fr-latin9'

# Localization language
language='fr_FR.UTF-8'

# Localization
geo_locale='Europe/Paris'

# Export function to chroot env
export -f alert_info

if [[ $(id -u) -ne 0 ]]
then
  alert_info "E" "Le script doit être lancé en tant que root"
  usage
  exit 1
fi


while getopts "hvd:u:n:" argument
do
  case "${argument}" in
    h)
      usage
      exit 1
      ;;
    v)
      version
      exit 1
      ;;
    d)
      readonly disk_crypt="${OPTARG:?'Nom disque et pass obligatoire !'}"
      ;;
    u)
      readonly user_pass="${OPTARG:='userx:usertemppass'}"
      ;;
    n)
      readonly host_name="${OPTARG:='Arch'}"
      ;;      
    :)
      alert_info "E" "L'option nécessite un argument."
      usage
      exit 1
      ;;
    \?)
      alert_info "E" "Option invalide !"
      usage
      exit 1
      ;;
    *)
      exit 1
      ;;
  esac
done

# User
username_name="$(echo "$user_pass" | cut -d: -f1)"
username_pass="$(echo "$user_pass" | cut -d: -f2)"

# Disque name and crypt pass
disk_name="$(echo "$disk_crypt" | cut -d: -f1)"
disk_pass="$(echo "$disk_crypt" | cut -d: -f2)"

check_disk_name "$disk_name"

########## Basic Install ##############################
#######################################################

########## Archiso configuring timezone
########################################
timedatectl set-timezone $geo_locale
timedatectl set-ntp true

export LANG=$language

########## Partitioning
########################################
alert_info "I" "Début du partitionnement, disque : /dev/${disk_name}" 
sleep 2
  
# Creating Partitions
# Clean and create GPT table
sgdisk --zap-all /dev/"${disk_name}"
sgdisk --clear /dev/"${disk_name}"

alert_info 'I' "Etat du disque ${disk_name}"
  
sgdisk --verify /dev/"${disk_name}"
  
# Partition 1 10Mb BIOS Boot
sgdisk --new=1::+10M /dev/"${disk_name}"
sgdisk --typecode=1:ef02 /dev/"${disk_name}"
  
# Partition 2 250Mb EFI FAT32
sgdisk --new=2::+250M /dev/"${disk_name}"
sgdisk --typecode=2:ef00 /dev/"${disk_name}"
  
# Partition 3 F2FS linux system
sgdisk --largest-new=3 /dev/"${disk_name}"
  
# Encrypt a Linux partition 3
echo "$disk_pass" | cryptsetup -q luksFormat /dev/"${disk_name}"3
  
# Unlock partition
echo "$disk_pass" | cryptsetup -q open /dev/"${disk_name}"3 cryptroot
  
# Format encrypt partition (F2FS)
yes | mkfs.f2fs -f /dev/mapper/cryptroot
  
# Format partition 2 EFI (FAT32)
yes | mkfs.fat -F32 /dev/"${disk_name}"2
  
# Mount partitions 2 and 3
mount -t f2fs /dev/mapper/cryptroot /mnt
  
mkdir /mnt/boot && mount /dev/"${disk_name}"2 /mnt/boot


########## Install base system
########################################
alert_info "I" "Installation du système de base" 

# System installation and dependances
pacstrap /mnt base linux linux-firmware linux-headers base-devel pacman-contrib grub networkmanager openssh dosfstools efibootmgr exfat-utils man-db man-pages man-pages-fr texinfo arch-install-scripts f2fs-tools

# Apply partition table configs in fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy Grub background
cp background.png /mnt/root

########## Chroot ENV
########################################
# Enter in the new system (chroot) default shell is Bash
arch-chroot /mnt << EOF

# Setup lacalization and language

ln -sf /usr/share/zoneinfo/$geo_locale /etc/localtime

# Setup clock
hwclock --systohc

# Setup time server
systemctl enable systemd-timesyncd

sed -i 's/#NTP=/NTP=/' /etc/systemd/timesyncd.conf

sed -i 's/^#FallbackNTP=.*/FallbackNTP=0.fr.pool.ntp.org 1.fr.pool.ntp.org 2.fr.pool.ntp.org 3.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf

timedatectl set-ntp true

# Setup time other  
timedatectl set-local-rtc 0
timedatectl --adjust-system-clock set-local-rtc 0
    
# Setup system language and keyboard layout 
sed -i 's/#'${language}' UTF-8/'${language}' UTF-8/g' /etc/locale.gen

echo "LANG=${language}" > /etc/locale.conf  
echo "LANGUAGE=fr_FR" >> /etc/locale.conf
echo "KEYMAP=$Keyboard_layout" > /etc/vconsole.conf
  
locale-gen

# Setup network
echo "$host_name" > /etc/hostname
  
echo "  
127.0.0.1       localhost
::1             localhost
127.0.1.1       ${host_name}.lan        $host_name
" >> /etc/hosts 

# Setup mkinitcpio HOOKS
alert_info "I" "Configuration d'Initramfs"
sleep 2

sed -i.bak 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev block keymap keyboard encrypt filesystems fsck)/g' /etc/mkinitcpio.conf
  
mkinitcpio -p linux

alert_info "I" "Configuration de GRUB" 
sleep 2

# Install and configure GRUB
grub-install --target=i386-pc --boot-directory=/boot /dev/"${disk_name}"  
grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --removable --recheck
  
# Config to Grub boot with crypted partition 
sed -i.bak "s/loglevel=3 quiet/loglevel=3 quiet cryptdevice=UUID=$(blkid /dev/"${disk_name}"3 -s UUID -o value):cryptroot root=\/dev\/mapper\/cryptroot/" /etc/default/grub

# Copy Grub background to /boot
cp /root/background.png /boot/grub || grub_background=false
  
# Change Grub background
$grub_background && sed -i 's/#GRUB_BACKGROUND="\/path\/to\/wallpaper"/GRUB_BACKGROUND="\/boot\/grub\/background.png"/' /etc/default/grub
  
# Update GRUB configurations
grub-mkconfig -o /boot/grub/grub.cfg

# Create a new user
alert_info "I" "Création du nouvel utilisateur $username_name" 
sleep 2

useradd -m -G wheel "$username_name"
echo ${username_name}:${username_pass} | chpasswd

# Config sudoers file
sed -i.bak 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Enable systemd services (NetworkManager and SSHD)
systemctl enable {NetworkManager,sshd}

# Optional configurations
# No adapt network interface name with hardware setup 
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
  
# Systemd journal in RAM
sed -i.bak 's/#Storage=auto/Storage=volatile/' /etc/systemd/journald.conf
  
# No Overfill RAM systemd limit to 50M
sed -i 's/#RuntimeMaxUse=/RuntimeMaxUse=50M/' /etc/systemd/journald.conf
  
# Microcodes support
# CPU AMD  : amd-ucode
# CPU Intel: intel-ucode
pacman -Sy --needed amd-ucode intel-ucode --noconfirm
  

########## Graphic Install ############################
#######################################################

alert_info "I" "Installation de XFCE et autres applications !" 
sleep 2

# Update mirrors
pacman -Sy --needed reflector rsync --noconfirm

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector --verbose --country France -l20 -p https,rsync --sort rate --save /etc/pacman.d/mirrorlist

pacman -Sy
  
# Installing Xorg and GPU support
pacman -Sy --needed xorg xorg-drivers --noconfirm  
 
# Installing XFCE4 and lightdm
pacman -Sy --needed xfce4 xfce4-goodies lightdm lightdm-{gtk-greeter,gtk-greeter-settings} --noconfirm 

# Systemd enable lightdm
systemctl enable lightdm

########## Optional applications
#######################################################

alert_info "I" "Installation d'autres applications !" 
sleep 2

pacman -Sy --needed network-manager-applet leafpad capitaine-cursors arc-{gtk-theme,icon-theme} xdg-user-dirs-gtk git archlinux-wallpaper gnome-icon-theme-extras libreoffice-still-fr hunspell-fr firefox-{i18n-fr,ublock-origin} vlc ffmpegthumbnailer --noconfirm 
 
# Audio supports
alert_info "I" "Installation pour le support audio !" 
sleep 2

pacman -Sy --needed pulseaudio pavucontrol bluez pulseaudio-{alsa,bluetooth} alsa-utils blueman --noconfirm 
  
# Printer supports
alert_info "I" "Installation pour le support imprimantes !" 
sleep 2

pacman -Sy --needed cups foomatic-{db,db-ppds,db-gutenprint-ppds,db-nonfree,db-nonfree-ppds} gutenprint system-config-printer --noconfirm 
  
# Device use MTP
alert_info "I" "Installation pour le support des connexions via MTP !" 
sleep 2
pacman -Sy --needed  gvfs-mtp mtpfs --noconfirm 
  
# Fonts
alert_info "I" "Installation de polices de charactères !" 
sleep 2

pacman -Sy --needed noto-fonts noto-fonts-{cjk,emoji,extra} ttf-{dejavu,roboto,ubuntu-font-family,bitstream-vera,liberation,arphic-uming,baekmuk} xorg-fonts-type1 sdl_ttf gsfonts --noconfirm 

# Setup for support 32 bits applications
alert_info "I" "Configuration pour le support des application en 32bits  !" 
sleep 2

sed -i.bak '/#\[multilib\]/,/#Include/ s/#//' /etc/pacman.conf

# Setup keymap for X11 
echo '  Section "InputClass"
      Identifier         "Keyboard Layout"
      MatchIsKeyboard    "yes"
      Option             "XkbLayout"  "fr"
      Option             "XkbVariant" "latin9"
  EndSection
' >> /etc/X11/xorg.conf.d/00-keyboard.conf

# Update time
timedatectl set-local-rtc 1
timedatectl set-local-rtc 0
EOF

start_end

alert_info "I" "FIN du script !"

# Exit install
umount --recursive /mnt && shutdown now
