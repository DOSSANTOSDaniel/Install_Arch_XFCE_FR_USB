## Prérequis avant installation

* Architecture x86_64.
* 1 GB de RAM minimum.
* 10 GB d'espace de stockage minimum.
* Réseau LAN avec une connexion internet.
* Ports USB.
* Un ordinateur.
* Une clé avec l'image live d'Arch Linux.
* Une clé USB vierge, c'est là où on va installer Arch Linux.

Il y a plusieurs méthodes possibles pour réaliser cette procédure :

* Méthode 1 :
Vous pouvez créer une clé USB amorçable d'Arch Linux puis à partir de cette clé, installer Arch Linux sur une autre clé USB vierge.

* Méthode 2 :
Vous pouvez lancer l'image système d'Arch Linux dans une machine virtuelle et y rattacher une clé USB vierge ainsi vous aurez besoin que d'une seule clé USB, celle où sera installé le système Arch Linux.

Exemple avec Qemu :
```Bash
qemu-system-x86_64 -cpu host -m 2048 -smp 2 -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:2222-:22 -drive file=/dev/sdb,format=raw -cdrom archlinux-2021.08.01-x86_64.iso -boot once=d
``` 

Réseau : NAT
RAM    : 2G
CPU    : 2
SSH    : ssh root@localhost
USB    : /dev/sdb
ISO    : archlinux-2021.08.01-x86_64.iso

Pour cette procédure on va utiliser la méthode 1.

### Téléchargement de l'image d'installation

Vous pouvez récupérer l'image d'installation et sa signature PGP à cette adresse:![archlinux.org](https://archlinux.org/download) 

* Téléchargement du fichier signature PGP :
```Bash
wget https://archlinux.org/iso/2021.08.01/archlinux-2021.08.01-x86_64.iso.sig
```

* Téléchargement de l'image disque :
```Bash
wget http://archlinux.mirrors.ovh.net/archlinux/iso/2021.08.01/archlinux-2021.08.01-x86_64.iso
```

### Vérification de la signature PGP

Cette vérification nous permet de garantir que c'est une image disque officielle.
```Bash
gpg --auto-key-locate clear,wkd -v --locate-external-key pierre@archlinux.de

gpg --keyserver-options auto-key-retrieve --verify archlinux-2021.08.01-x86_64.iso.sig archlinux-2021.08.01-x86_64.iso
```

Ici pour savoir si la vérification a réussie, vous devez avoir cette ligne :
`(Bonne signature de « Pierre Schmitz <pierre@archlinux.de>)`

### Vérification de l'intégrité de l'image disque

Cela permet de vérifier que l'image n'a pas été altérée pendant le téléchargement ou après. 
```Bash
sha1sum archlinux-2021.08.01-x86_64.iso
```

Comparer la valeur de la somme de contrôle obtenue avec la valeur sur la page ![archlinux.org](https://archlinux.org/download).

Exemple pour l'image 2021.08.01 :(SHA1: 4904c8a6df8bac8291b7b7582c26c4da9439f1cf).

### Création d'une clé USB amorçable

Tout d'abord brancher la clé USB sur un des ports de votre ordinateur.

On va avoir besoin d'identifier le nom /dev de votre périphérique USB, pour cela on utilise cette commande :
```Bash
lsblk --exclude 7
```

Exemple:
```Bash
┌──[daniel👾S3810]-(~)
│
└─$ lsblk --exclude 7

NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 447,1G  0 disk 
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0     1K  0 part 
└─sda5   8:5    0 446,7G  0 part /
sdb      8:16   1  14,5G  0 disk 
└─sdb1   8:17   1  14,5G  0 part /media/daniel/32DB-D8B2
```

Ici pour l'installation je vais utiliser le disque /dev/sdb de 14Gb.

Lancement de la création de la clé avec la commande dd :
```Bash
dd bs=4M if=archlinux-2021.08.01-x86_64.iso of=/dev/sdb status=progress oflag=sync
```

## Début de l'installation sur l'ordinateur

Maintenant que votre clé amorçable a été créé on va pouvoir la brancher sur un ordinateur pour démarrer l'installation.

Configurer le BIOS pour qu'il démarre sur votre clé USB d'installation.

Brancher aussi la clé USB vierge, c'est dans ce périphérique que nous allons installer Arch Linux.

### Changer la configuration du clavier pour français :

Attention par défaut le clavier est en QWERTY donc (loqdkeys fr-pc) :
```Bash
loadkeys fr-pc
```

Par défaut Le live d'Arch Linux à une configuration réseau valide, donc si vous voulez vous connecter en SSH c'est possible, SSHD est par défaut déjà activé.

Modification du mot de passe root :
```Bash
passwd
```

### Configuration de la localisation et de l'heure système :

```Bash
timedatectl set-timezone Europe/Paris
```

Configuration de l'heure du système :

Ici on va utiliser des serveurs de temps pour synchroniser l'heure et la date sur notre système.

Serveurs de temps français ici: ![www.pool.ntp.org](https://www.pool.ntp.org/zone/fr)

```Bash
sed -i 's/#NTP=/NTP=/' /etc/systemd/timesyncd.conf

sed -i 's/#FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org/FallbackNTP=0.fr.pool.ntp.org 1.fr.pool.ntp.org 2.fr.pool.ntp.org 3.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf
```

Activation de la synchronisation :
```Bash
timedatectl set-ntp true
```

### Partitionnement du disque vierge

Création de trois partitions et une partition chiffrée.

Schéma :
```
      +------------------+
Part 1: bios boot 10mo   | sdX1 (BIOS Boot)
      +------------------+
 
      +------------------+ 
Part 2: efi 250 mo       | sdX2 (Fat32) /mnt/boot
      +------------------+
 
      +------------------+
Part 3:                  | sdX3 (ext4)
      +----------+-------+
                 |
                 |         Linux systeme 
                 |         +------------------+
                 +------3.1:   cryptroot      |  (Crypted) /mnt
                           +------------------+
```

Nettoyage et création d'une nouvelle table de partitions GPT :

```Bash
sgdisk --zap-all /dev/sdX
sgdisk --clear /dev/sdX
sgdisk --verify /dev/sdX
```

Création de la première partition, code hexadécimal ef02 pour BIOS Boot  :
```Bash
sgdisk --new=1::+10M /dev/sdX 
sgdisk --typecode=1:ef02 /dev/sdX
```

Création de la deuxième partition, code hexadécimal ef00 pour EFI :
```Bash
sgdisk --new=2::+250M /dev/sdX
sgdisk --typecode=2:ef00 /dev/sdX
```

Création de la troisième partition, code hexadécimal par défaut 8300 pour EXT4 système Linux :
```Bash
sgdisk --largest-new=3 /dev/sdX
```

Création de la partition de travail chiffrée et définition du mot de passe :
```Bash
cryptsetup luksFormat /dev/sdX3
```

Déverrouillage de la partition avec le mot de passe créé précédemment :
```Bash
cryptsetup open /dev/sdX3 cryptroot
```

Formatage de la partition chiffrée en EXT4 :
```Bash
mkfs.ext4 -O "^has_journal" /dev/mapper/cryptroot
                   ^
                   |
                   +------- Désactivation de la journalisation
```                   

Formatage de la partition EFI en FAT32 :
```Bash
mkfs.fat -F32 /dev/sdX2
```

Comme j'envisage d'installer Arch Linux sur ma clé USB vierge alors je ne vais pas créer de partition SWAP pour éviter au maximum l'écriture sur la clé l'USB. 

Montage des partitions :

* Partition 2 : EFI /mnt/boot.
* Partition 3 : cryptroot EXT4 /mnt.

```Bash
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot && mount /dev/sdX2 /mnt/boot
```

## Installation de Linux et autres dépendances

A l'aide de la commande pacstrap on va pouvoir installer le système de base et d'autres paquets sur le nouveau système monté sur /mnt :

```Bash
pacstrap /mnt base linux linux-firmware linux-headers base-devel pacman-contrib vim nano openssh grub networkmanager dosfstools ntfs-3g gvfs efibootmgr exfat-utils man-db man-pages man-pages-fr bash-completion
```

Application des modifications de partitionnement sur fstab

```Bash
genfstab -U /mnt >> /mnt/etc/fstab
```

On va maintenant passer du système live au système qu'on vient d'installer et qui est monté sur /mnt :

```Bash
arch-chroot /mnt
```

## Configuration du système installé

Configuration du fuseau horaire :
```Bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

```Bash
hwclock --systohc
```

Configuration de la locale pour "français de France" :

```Bash
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
```

```Bash
locale-gen
```

```Bash
echo 'LANG=fr_FR.UTF-8' > /etc/locale.conf
```

Spécification pour la session courante :
```Bash
export LANG=fr_FR.UTF-8
```

Configuration de la disposition du clavier :
```Bash
echo 'KEYMAP=fr-pc' > /etc/vconsole.conf
```

### Configurations réseau

Choix du nom de la machine, ici j'ai choisi "arch" :
```Bash
echo "arch" > /etc/hostname
```

Configuration du fichier hosts :
```Bash
nano /etc/hosts
```

Ajouter ces lignes, vous pouvez choisir un autre nom que "arch" bien sûr.

```Bash
127.0.0.1       localhost
::1             localhost
127.0.1.1       arch.lan        arch
```

Configuration d'Initramfs.
L'objectif de initramfs est d'aider le système a monter la partition racine du système de fichier.
 
```Bash
nano /etc/mkinitcpio.conf
```

Modifier cette ligne :
```Bash
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

Vers celle là :
```Bash
HOOKS=(base udev block keyboard keymap encrypt filesystems fsck)
```

Appliquer la modification :
```Bash
mkinitcpio -p linux
```

## Installation de grub

Installation hybride EFI et BIOS Boot :
```Bash
grub-install --target=i386-pc --boot-directory=/boot /dev/sdX

grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --removable --recheck
```

Configuration de grub

Récupérer l'UUID de la troisième partition avec la commande : `blkid`

Dans le fichier /etc/default/grub remplacer la ligne:

```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```
Par :

```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID='UUID de la partition 3 ici':cryptroot root=/dev/mapper/cryptroot /etc/default/grub"
```

Exemple :
```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=UUID=4a1a09ac-0125-4128-8db8-1a4da561c6df:cryptroot root=/dev/mapper/cryptroot /etc/default/grub"
```

Ici la partie "UUID=4a1a09ac-0125-4128-8db8-1a4da561c6df" c'est ce que nous avons récupéré avec la commande `blkid`.

Application des configurations de Grub :
```Bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## Création du nouvel utilisateur

Exemple ici avec l'utilisateur "daniel":
```Bash
useradd -m -G wheel,audio,video,optical,storage,scanner daniel
```

Changement du mot de passe de daniel :

```Bash
passwd daniel
```

### Configuration du fichier sudoers 

```Bash
sudo EDITOR="nano" visudo
```

Dé-commenter la ligne "# %wheel ALL=(ALL) ALL" : 

```Bash
%wheel ALL=(ALL) ALL
```

Activation de NetworkManager et du serveur OpenSSH

```Bash
systemctl enable {NetworkManager,sshd}
```

## Autres configurations

### Nom des interfaces réseau

Systemd, attribue aux interfaces réseau des noms en fonction des composants matériel de l'ordinateur. 

Cela risque de nous poser un problème si nous voulons utiliser notre clé USB Arch Linux sur d'autres machines.

Pour être sure que les interfaces ethernet et wifi ne changeant pas on va activer la dénomination traditionnelle du système Arch Linux.
`
```Bash
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
```

Source : https://mags.nsupdate.info/arch-usb.html

### Systemd et son journal

On peut configurer Systemd pour qu'il stocke son journal en RAM, ainsi on évite d'écrire sur la clé USB.

```Bash
sed -i 's/#Storage=auto/Storage=volatile/' /etc/systemd/journald.conf
```

Pour éviter que Système utilise toute la RAM, on peut appliquer des limitations, ici 30 Mb.
```Bash
sed -i 's/#RuntimeMaxUse=/RuntimeMaxUse=30M/' /etc/systemd/journald.conf
```

### Support pour les pavés tactiles standard des ordinateurs portables

```Bash
pacman -S xf86-input-synaptics
```

### Support pour la vérification de l'état de la batterie sur ordinateurs portable

```Bash
pacman -S acpi
```

### Support des microcodes CPU

```Bash 
pacman -S amd-ucode    # CPU AMD
pacman -S intel-ucode  # CPU Intel
```

## Fin de l'installation

On va sortir du système démonter récursivement les points de montage sur /mnt et redémarrer.

```Bash
exit

umount -R /mnt

reboot
```

## Sources

* https://wiki.archlinux.org/
* https://wiki.archlinux.org/title/Main_page_(Fran%C3%A7ais)
* https://mags.nsupdate.info/arch-usb.html
* https://www.linuxsecrets.com/archlinux-wiki/wiki.archlinux.org/index.php/Installing_Arch_Linux_on_a_USB_key.html
* https://wiki.archlinux.org/title/Install_Arch_Linux_on_a_removable_medium
* https://wiki.archlinux.org/title/Xfce#Installation
* https://blog.fredericbezies-ep.fr/2019/07/01/guide-dinstallation-darchlinux-version-de-juillet-2019/
* https://wiki.archlinux.org/title/Dm-crypt_(Fran%C3%A7ais)
