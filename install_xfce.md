# Installation du gestionnaire de bureau XFCE4 sur Arch Linux

Nous allons tout d’abord mettre à jour notre liste de miroirs.

La commande reflector va nous permettre de générer une liste de miroirs dans le but de sélectionner les miroirs qui offrent le meilleure débit, ce qui va augmenter la vitesse de téléchargement de nos paquets.

```Bash
sudo pacman -S reflector rsync

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
```

Ici on demande la génération des 20 plus rapides miroirs qui utilisent le protocole HTTPS et rsync le tout sera sauvegardé dans la liste des miroirs du système.

```Bash
sudo reflector --verbose --country France -l20 -p https,rsync --sort rate --save /etc/pacman.d/mirrorlist
```

Pour consulter l'état des miroirs : ![archlinux.org/mirrors](https://archlinux.org/mirrors/status/)

Recherche de mises à jour du système et installation si nécessaire :

```Bash
pacman -Syu

```

Installation du serveur graphique Xorg :

```Bash
sudo pacman -S xorg
```

Installation de XFCE4 et du gestionnaire de login Lightdm :

```Bash
sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-{gtk-greeter,gtk-greeter-settings}
```

Activation de lightdm :

```Bash
sudo systemctl enable lightdm
```

Installation d'autres paquets :

```Bash
sudo pacman -S network-manager-applet leafpad capitaine-cursors arc-{gtk-theme,icon-theme} xdg-user-dirs-gtk git archlinux-wallpaper gnome-icon-theme-extras libreoffice-still-fr hunspell-fr firefox-{i18n-fr,ublock-origin} vlc ffmpegthumbnailer ntp
```


Configuration de la langue du clavier dans l'interface graphique :

```Bash
sudo localectl set-x11-keymap fr pc105 --no-convert
```

Installation de dépendances multimédia :

```Bash
sudo pacman -S pulseaudio pavucontrol bluez pulseaudio-{alsa,bluetooth} alsa-utils blueman
```

Support GPU :

```Bash
sudo pacman -S --needed xorg-drivers
```

Installation de dépendances pour imprimantes :

```Bash
sudo pacman -S cups foomatic-{db,db-ppds,db-gutenprint-ppds,db-nonfree,db-nonfree-ppds} gutenprint xsane system-config-printer
```

Activation de certains services :

```Bash
sudo systemctl enable {cups,ntpd}
```

Outils pour périphériques utilisant MTP :

```Bash
sudo pacman -S gvfs-mtp mtpfs
```

Installation des polices de caractères : 

```Bash
sudo pacman -S noto-fonts noto-fonts-{cjk,emoji,extra} ttf-{dejavu,roboto,ubuntu-font-family,bitstream-vera,liberation,arphic-uming,baekmuk} xorg-fonts-type1 sdl_ttf gsfonts
```

Installation de yay :

```Bash
git clone https://aur.archlinux.org/yay && cd yay

makepkg -sri
```

Installation de Pamac :

```Bash
yay -S pamac
```

Pour pouvoir installer des application en 32bits :

```Bash
sudo nano /etc/pacman.conf
```

De-commenter la section "multilib" ainsi que la ligne en dessous :

```Bash
[multilib]
Include = /etc/pacman.d/mirrorlist

sudo pacman -Syu
```

Installation des pilotes propriétaires de Nvidia si nécessaire :

```Bash
sudo pacman -S nvidia-utils nvidia
```

## Warnings firmware

```Bash
==> WARNING: Possibly missing firmware for module: wd719x
==> WARNING: Possibly missing firmware for module: aic94xx
==> WARNING: Possibly missing firmware for module: xhci_pci  
```

Solution :

```Bash
yay -S wd719x-firmware

yay -S aic94xx-firmware

yay -S upd72020x-fw
```

Redémarrer le système :

```Bash
sudo reboot
```