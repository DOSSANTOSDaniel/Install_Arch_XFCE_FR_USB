# Installation du gestionnaire de bureau XFCE4 sur Arch Linux

Installation du serveur graphique Xorg :

```Bash
sudo pacman -S xorg xorg-server  ????????????????????????????????????????????????????
```

Installation de XFCE4 et du gestionnaire de login Lightdm

```Bash
sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-{gtk-greeter,gtk-greeter-settings}
```

Activation de lightdm

```Bash
sudo systemctl enable lightdm
```

Installation d'autres paquets

```Bash
sudo pacman -S network-manager-applet leafpad capitaine-cursors arc-{gtk-theme,icon-theme} xdg-user-dirs-gtk git archlinux-wallpaper archlinux-artwork adwaita-icon-theme gnome-icon-theme-extras libreoffice-still-fr hunspell-fr firefox-{i18n-fr,ublock-origin} vlc file-
roller evince ffmpegthumbnailer xscreensaver
```


Configuration de Xorg en français

```Bash
sudo localectl set-x11-keymap fr pc105 --no-convert
```

Installation de dépendances audio
```Bash
sudo pacman -S pulseaudio pavucontrol bluez pulseaudio-{alsa,bluetooth,equalizer,jack,lirc} alsa-utils blueman
```

Installation de dépendances vidéo, multimédia :
```Bash
sudo pacman -S gst-plugins-{base,good,bad,ugly} gst-libav ffmpeg
```

Support GPU
```Bash
sudo pacman -S xf86-video-{vesa,ati,intel,amdgpu,nouveau,fbdev,dummy,openchrome,sisusb,vmware,qxl,voodoo} 
```

Installation de dépendances pour imprimantes
```Bash
sudo pacman -S cups foomatic-{db,db-ppds,db-gutenprint-ppds,db-nonfree,db-nonfree-ppds} gutenprint xsane system-config-printer
```

Activation de certains services :

```Bash
sudo systemctl enable {avahi-daemon,avahi-dnsconfd,org.cups.cupsd,ntpd}
```

* avahi-daemon   : Cups
* avahi-dnsconfd : Cups
* org.cups.cupsd : Cups
* ntpd           : Synchronisation de l'heure du système via le réseau.

Outils pour périphériques utilisant MTP
```Bash
sudo pacman -S --needed gvfs-mtp mtpfs
```

Installation des polices de caractères
```Bash
sudo pacman -S --needed noto-fonts noto-fonts-{cjk,emoji,extra} ttf-{dejavu,roboto,ubuntu-font-family,bitstream-vera,liberation,arphic-uming,baekmuk} xorg-fonts-type1 gnu-free-fonts sdl_ttf gsfonts
```

Installation de yay

```Bash
git clone https://aur.archlinux.org/yay
cd yay
makepkg -sri --noconfirm
```

Installation de Pamac
```Bash
yay -S --needed pamac --noconfirm
```

## Bonus

### Ajouter une image de fond à Grub

Prérequis concernant les caractéristiques de l'image de fond:

1. Format conseillé: 1920x1080
2. en: png

Télécharger une image et la mettre dans /boot/grub

```Bash
sudo cp ~user/background.png /boot/grub/
```

Configuration de Grub concernant l'emplacement de l'image de fond :
```Bash
sudo sed -i 's/#GRUB_BACKGROUND="\/path\/to\/wallpaper"/GRUB_BACKGROUND="\/boot\/grub\/background.png"/' /etc/default/grub
```

Nom 
```Bash
sudo sed -i 's/GRUB_DISTRIBUTOR="Arch"/GRUB_DISTRIBUTOR="Arch オペレーティングシステム"/' /etc/default/grub
```

Mise à jour de la configuration de grub
```Bash
grub-mkconfig -o /boot/grub/grub.cfg
```
