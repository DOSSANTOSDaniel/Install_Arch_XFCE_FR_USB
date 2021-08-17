# Avant l'installation

## Téléchargement de l'image ISO

Vous pouvez récupérer l'image d'installation et sa signature PGP à cette adresse: [archlinux.org](https://archlinux.org/download) 

* Téléchargement du fichier signature PGP :

```Bash
wget https://archlinux.org/iso/2021.08.01/archlinux-2021.08.01-x86_64.iso.sig
```

* Téléchargement de l'image disque :

```Bash
wget http://archlinux.mirrors.ovh.net/archlinux/iso/2021.08.01/archlinux-2021.08.01-x86_64.iso
```

## Vérification de la signature PGP de l'image ISO

Cette vérification nous permet de garantir que c'est une image disque officielle.

```Bash
gpg --keyserver hkp://keyserver.ubuntu.com --keyserver-options auto-key-retrieve --verify archlinux-2021.08.01-x86_64.iso.sig archlinux-2021.08.01-x86_64.iso
```

Cette commande va récupérer la clé publique du développeur qui a signer le fichier ISO sur le site hkp://keyserver.ubuntu.com puis va l'importer sur votre trousseau de clés.

Par la suite il compare si l'empreinte de la clé publique, correspond à celle du développeur qui a signé le fichier.

Ici pour savoir si la vérification a réussie, vous devez avoir cette ligne :

`(Bonne signature de « Pierre Schmitz <pierre@archlinux.de>)`

## Vérification de l'intégrité de l'image disque

Cela permet de vérifier que l'image n'a pas été altérée pendant le téléchargement ou après.

```Bash
sha1sum archlinux-2021.08.01-x86_64.iso
```

Comparer la valeur de la somme de contrôle obtenue avec la valeur sur la page : [archlinux.org](https://archlinux.org/download).

Exemple pour l'image 2021.08.01 :(SHA1: 4904c8a6df8bac8291b7b7582c26c4da9439f1cf).

## Création d'une clé USB amorçable

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

Une fois que votre clé amorçable a été créé on va pouvoir la brancher sur un ordinateur pour démarrer l'installation.

Configurer le BIOS pour qu'il démarre sur votre clé USB d'installation.
