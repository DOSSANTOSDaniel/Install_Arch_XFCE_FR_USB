# Installation d'Arch Linux sur un média amovible

## Changer la configuration du clavier

Attention par défaut le clavier est en QWERTY donc (loqdkeys fr) :

```Bash
loadkeys fr
```

Par défaut Le live d'Arch Linux à une configuration réseau valide(en DHCP), donc si vous voulez vous connecter en SSH c'est possible, SSHD est par défaut déjà démarré, il faut juste définir un mot de passe pour root,(passwd).

```Bash
passwd
```

## Configuration de l'heure et de la date

Configuration du fuseau horaire :

```Bash
timedatectl set-timezone Europe/Paris
```

L'outil timedatectl fait parti des outils de systemd, il permet de régler l'heure, la date, le fuseaux horaires mais aussi de définir des serveurs de temps et s'y synchroniser.

Serveurs de temps français ici: [www.pool.ntp.org](https://www.pool.ntp.org/zone/fr)

Activation de la synchronisation avec les serveurs de temps :

```Bash
timedatectl set-ntp true
```

## Partitionnement du disque

Création de trois partitions dont une partition chiffrée.

Schéma :

```

      +------------------+
Part 1: bios boot 10mo   | sdX1 (BIOS Boot)
      +------------------+
 
      +------------------+ 
Part 2: efi 250 mo       | sdX2 (FAT32) /mnt/boot
      +------------------+
 
      +------------------+
Part 3:                  | sdX3 (F2FS)
      +----------+-------+
                 |
                 |         Linux systeme 
                 |         +------------------+
                 +------3.1:   cryptroot      |  (Crypted) /mnt
                           +------------------+
```

### Description des différentes partitions 

#### La partition /dev/sdX1 (BIOS Boot)

Cette partition va permettre au GRUB d'amorcer un système lancé en mode BIOS sur un disque avec une table de partitions en GPT.

Cette partition est vide et ne contient pas de formatage, GRUB va directement écrire dessus.

On appelle ça un démarrage BIOS/GPT.

#### La partition /dev/sdX2 (EFI/ESP)

Cette partition abrite les information de démarrage des système amorcé en mode UEFI avec une table de partition en GPT.

Cette partition contient un dossier EFI/ qui contient les dossiers correspondant aux configurations des différents systèmes d'exploitation gérés.

Voici un exemple :

```Bash

/efi/EFI/
├── Boot
│   └── bootx64.efi
├── ARCH
│   └── grubx64.efi
└── Microsoft
    ├── Boot
    └── Recovery

```

Comme on peut le voir la partition ESP est conçue pour supporter la configuration de plusieurs systèmes.

Dans ces répertoires on trouve des fichiers avec l’extension .efi, ce sont les différents noyaux à lancer par le bootloader au démarrage, ici le bootloader c'est GRUB.

La partition doit être formater en FAT 32 et puis sa taille peut varier selon le nombre de systèmes configurés dessus, cela peut aller de 128 Mo à 512 Mo, cela dépend aussi de la taille des noyaux.

#### La partition /dev/sdX3 (system linux)

Cette partition est destinée aux données c'est là que nous allons installer notre système, vous êtes libre de choisir le formatage, pour cette partition j'ai choisie d'avoir un système de fichiers en F2FS.


##### Le système de fichiers F2FS

F2FS pour flash-friendly file system, c'est un système de fichiers spécialement conçu pour les périphérique avec de la mémoire flash NAND.
Ce système de fichiers est pris en charge à partir du noyau Linux 3.8. 

[wiki.archlinux.F2FS](https://wiki.archlinux.org/title/F2FS)

##### Installation de la prise en charge de F2FS

```Bash
pacman -Sy f2fs-tools
```

### Le partitionnement du disque

Nettoyage du disque et création d'une nouvelle table de partitions GPT :

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

Création de la troisième partition, code hexadécimal par défaut 8300 pour système Linux :
```Bash
sgdisk --largest-new=3 /dev/sdX
```

### Chiffrement de la partition de travail

Création de la partition de travail chiffrée et définition du mot de passe :

```Bash
cryptsetup luksFormat /dev/sdX3
```

Déverrouillage de la partition avec le mot de passe créé précédemment :

```Bash
cryptsetup open /dev/sdX3 cryptroot
```

### Formatage et montage des différentes partitions

Formatage de la partition chiffrée en F2FS :

```Bash
mkfs.f2fs -f /dev/mapper/cryptroot
```                   

Formatage de la partition EFI en FAT32 :

```Bash
mkfs.fat -F32 /dev/sdX2
```

La partition SWAP :

Comme j'envisage d'installer Arch Linux sur ma clé USB alors je ne vais pas créer de partition SWAP pour éviter au maximum l'écriture sur la clé l'USB. 

Montage des partitions :

* Partition 2 : EFI       FAT32 /mnt/boot.
* Partition 3 : cryptroot F2FS  /mnt.

```Bash
mount -t f2fs /dev/mapper/cryptroot /mnt

mkdir /mnt/boot && mount /dev/sdX2 /mnt/boot
```

## Installation de Linux et dépendances puis configurations

### Installation des paquets

Pacstrap permet de créer une nouvelle installation de Linux en installant certains paquets sur la nouvelle racine montée.

Pacstrap se chroot dans la nouvelle racine et par la suite se comporte comme pacman avec les clés de signature et la liste de miroirs du système hôte. 

Installation du système de base et d'autres paquets sur la nouvelle racine (/mnt) :

```Bash
pacstrap /mnt base linux linux-firmware linux-headers base-devel pacman-contrib vim nano openssh grub networkmanager dosfstools ntfs-3g gvfs efibootmgr exfat-utils man-db man-pages man-pages-fr bash-completion arch-install-scripts
```

### Génération du fichier fstab

Application des modifications de partitionnement sur fstab

```Bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Bascule sur le nouveau système

La commande arch-chroot est une implémentation de la commande chroot spécifique à Arch Linux, chroot nous permet de entrée dans un environnement isolé(chroot jail).

[wiki.archlinux.chroot](https://wiki.archlinux.fr/chroot).

On va maintenant passer du système live au système qu'on vient d'installer et qui est monté sur /mnt :

```Bash
arch-chroot /mnt
```

### Configuration du système installé

#### Configuration du fuseau horaire :

```Bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

Ici on a prit le fichier qui correspond à notre fuseau horaire et on à appliqué un lien symbolique vers /etc/localtime, l'option -f supprime /etc/localtime s'il existe déjà.  


Définition de l'horloge matérielle sur l'heure du système actuel :

```Bash
hwclock --systohc
```

#### Configuration des paramètres régionaux

Configuration de la locale (langue du système):

```Bash
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
```

Création du fichier locale.conf :

```Bash
echo 'LANG=fr_FR.UTF-8' > /etc/locale.conf
```

Configuration de la disposition du clavier pour la console virtuelle (tty):

```Bash
echo 'KEYMAP=fr-latin9' > /etc/vconsole.conf
```

Génération des fichiers de paramètres régionaux :

```Bash
locale-gen
```

Pour la session courante :

```Bash
export LANG=fr_FR.UTF-8
```

#### Configurations réseau

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

#### Configuration noyau.

L'initramfs est une copie d'un vrais système linux avec sont ensemble de fichiers et de répertoires, le tout dans une seule archive, l'initramfs se charge en mémoire au même moment que le noyau Linux, le noyau va monter l'initramfs dans la racine (/) dans l'objectif de par exemple charger d'autres modules externes au noyau. 

L'objectif de initramfs est d'aider le système a monter la partition racine du système de fichier réel.
 
```Bash
nano /etc/mkinitcpio.conf
```

Modifier cette ligne :

```Bash
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

Par celle là :

```Bash
HOOKS=(base udev block keymap keyboard encrypt filesystems fsck)
```

Ici keyboard et keymap sont chargés avant encrypt pour qu'ont puise avoir le clavier en français au moment de saisir notre phrase de passe.

Encrypt est devant filesystems pour pouvoir déverrouiller le système de fichier.

Ici on a changer l'ordre de chargement de certains modules, puis on a enlever d'autres c'est pour cette raison que nous devons actualiser la configuration :

```Bash
mkinitcpio -p linux
```

#### Installation de GRUB

Installation de Grub2 EFI et Legacy côte à côte, en mode hybride.

Pour que cela fonctionne il faut :
	* Utiliser le partitionnement GPT.
	* Avoir une partition BIOS Boot.


Installation dans le MBR de GPT:

```Bash
grub-install --target=i386-pc --boot-directory=/boot /dev/sdX
```

Installation dans la partition EFI :

```Bash
grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --removable --recheck
```

#### Configuration de GRUB

Récupérer de l'UUID de la troisième partition avec la commande : `blkid`

Dans le fichier /etc/default/grub remplacer la ligne :

```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

Par :

```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID='l'UUID de la partition 3':cryptroot root=/dev/mapper/cryptroot"
```

Exemple :

```Bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=UUID=4a1a09ac-0125-4128-8db8-1a4da561c6df:cryptroot root=/dev/mapper/cryptroot"
```

Ici la partie "UUID=4a1a09ac-0125-4128-8db8-1a4da561c6df" c'est ce que nous avons récupéré avec la commande `blkid`.

On indique ici au GRUB de passer au noyau certains paramètres comme par exemple la racine de notre système (root=/dev/mapper/cryptroot).

Application des configurations de GRUB :

```Bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Ici grub-mkconfig va analyser les modifications que nous avons fait sur le fichier /etc/default/grub et génère un fichier de configuration.

#### Création d'un nouvel utilisateur

Exemple ici avec l'utilisateur "daniel":

```Bash
useradd -m -G wheel daniel
```

Changement du mot de passe de daniel :

```Bash
passwd daniel
```

#### Configuration du fichier sudoers 

```Bash
EDITOR="nano" visudo
```

Dé-commenter la ligne "# %wheel ALL=(ALL) ALL" : 

```Bash
%wheel ALL=(ALL) ALL
```

Activation de NetworkManager et du serveur OpenSSH

```Bash
systemctl enable {NetworkManager,sshd}
```

### Autres configurations optionnelles

#### Nom des interfaces réseau

Systemd, attribue aux interfaces réseau des noms en fonction des composants matériel de l'ordinateur. 

Cela risque de nous poser un problème si nous voulons utiliser notre clé USB Arch Linux sur d'autres machines.

Pour être sure que les interfaces réseau ne changeant pas on va activer la dénomination traditionnelle du système Arch Linux.
`
```Bash
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
```

Source : [hmags.nsupdate.info](https://mags.nsupdate.info/arch-usb.html)

#### Systemd et son journal

On peut configurer systemd pour qu'il stocke son journal en RAM, ainsi on évite d'écrire sur la clé USB.

```Bash
sed -i 's/#Storage=auto/Storage=volatile/' /etc/systemd/journald.conf
```

Pour éviter que Système utilise toute la RAM, on peut appliquer des limitations, ici 30 Mb.

```Bash
sed -i 's/#RuntimeMaxUse=/RuntimeMaxUse=30M/' /etc/systemd/journald.conf
```

#### Support des microcodes CPU

```Bash 
pacman -S amd-ucode    # CPU AMD
pacman -S intel-ucode  # CPU Intel
```

### Fin de l'installation

On va sortir du système puis démonter récursivement les points de montage à partir de /mnt et redémarrer l'ordinateur.

```Bash
exit

umount -R /mnt

reboot
```

### Sources

* https://wiki.archlinux.org/
* https://wiki.archlinux.org/title/Main_page_(Fran%C3%A7ais)
* https://mags.nsupdate.info/arch-usb.html
* https://www.linuxsecrets.com/archlinux-wiki/wiki.archlinux.org/index.php/Installing_Arch_Linux_on_a_USB_key.html
* https://wiki.archlinux.org/title/Install_Arch_Linux_on_a_removable_medium
* https://wiki.archlinux.org/title/Xfce#Installation
* https://blog.fredericbezies-ep.fr/2019/07/01/guide-dinstallation-darchlinux-version-de-juillet-2019/
* https://wiki.archlinux.org/title/Dm-crypt_(Fran%C3%A7ais)
