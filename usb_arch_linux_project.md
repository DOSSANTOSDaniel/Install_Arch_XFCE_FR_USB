# Projet clé USB Arch Linux

## Composition matériel d'une clé USB

```
                          Controller
                              ▲
                              │
                  ┌───────────┼──────────────────────────────────────────────┐
                  │           │                                              │
                  │     ┌─────┴────┐    ┌────────────────────────────────┐   │
                  │     │          │    │                                │   │
┌─────────────────┤     │ ┌──────┐ │    │                                │   │
│                 │     │ │ RISC │ │    │                                │   │
│   ┌─┐           │     │ └──────┘ │    │                                │   │
│   │ │           │     │          │    │                                │   │
│   └─┘           │     │ ┌─────┐  │    │                                │   │
│                 │     │ │ RAM │  │    │       NAND flash memory        │   │
│   ┌─┐           │     │ └─────┘  │    │                                │   │
│   │ │           │     │          │    │                                │   │
│   └─┘           │     │ ┌─────┐  │    │                                │   │
│                 │     │ │ ROM │  │    │                                │   │
└─────────────────┤     │ └─────┘  │    │                                │   │
                  │     │          │    │                                │   │
                  │     └──────────┘    └────────────────────────────────┘   │
                  │                                                          │
                  └──────────────────────────────────────────────────────────┘
```

[Definition clé USB](https://www.techno-science.net/glossaire-definition/Cle-USB-page-2.html)

Une clé USB est principalement composée par :

* La mémoire flash NAND c'est une mémoire de type non volatile, c'est dans cette partie où les données sont stockées.

* Le contrôleur permet de rendre la mémoire de la clé USB accessible à un autre appareil, c'est une interface.

## Le débit écriture/lecture de la clé USB

Dépend de plusieurs facteurs :
* La conception matérielle de la clé USB.
* L'architecture des circuits.
* Le contrôleur mémoire.
* Le système d'exploitation sur lequel la clé USB fonctionne.
* Le matériel de l'ordinateur sur lequel la clé USB fonctionne.
* L'organisation du contenu de la clé USB.
* Cela dépend aussi du type de fichiers transférés le débit peut chuter quand on copie une grande quantité de petits fichiers.

## Limites

* La mémoire flash supporte en moyenne 100 000 écritures et effacements.

## Outils

F2FS pour flash-friendly file system, c'est un système de fichiers spécialement conçu pour les périphérique avec de la mémoire flash NAND.
Ce système de fichiers est pris en charge à partir du noyau Linux 3.8. 

[wiki.archlinux.F2FS](https://wiki.archlinux.org/title/F2FS)

Installation :
```
apt install f2fs-tools
```

Formatage :
```
sudo mkfs.f2fs /dev/sdX
```

## Caractéristiques :

- Table de partitions : GPT
- Partitionnement : UEFI/BIOS
- Chiffrement : Luks
- Bootloader : GRUB

## Processus de démarrage du système Linux

0. UEFI
1. Partition EFI
2. GRUB
3. Noyau Linux
4. Initramfs
5. Init
6. Rc

### UEFI

Le UEFI se lance à partir du moment ou on appuie sur le bouton power.

* Il a pour fonction d'initialiser les composant matériels de la carte mère et de vérifier leurs états.

* Par la suite UEFI recherche le premier disque sur le système et trouve la première partition puis exécute un premier chargeur de démarrage situé dans la partition système EFI.

### Bootloader (grub,syslinux,mbr,lilo...)

Dans le premier secteur(512 octets) lancé par le BIOS ou dans la partition EFI lancé par UEFI se trouve le bootloader.

* La première tâche du bootloader est de se charger complètement en mémoire RAM.
* Il prend connaissance de sa configuration et choisit un périphérique puis une partition dans ce périphérique qui contient le noyau et aussi un initrd (initramfs).
* Pour finir le bootloader envoie certains paramétrés au noyau, puis c'est le noyau qui prend le relai. 

### Noyau Linux

* Première tâche du noyau, initialiser les configuration du processeur et les périphériques.
* Tâche numéro deux, il monte la "/".
* Il lance init mais si un initrd (initramfs) est présent alors il l'utilise à la place puis un script est lancé et prend en charge le montage de la racine.

### Initramfs

le noyau décompresse les archives initramfs dans le rootfs.
Permet le chargement dynamique de drivers et configuration comme par exemple le réseau ou le nfs.

c'est une archive montée à la racine avant le montage de la vraie racine , le but est de rendre la vraie racine accessible (partitions chiffrées, nfs, drivers manquants, LVM...).

Puis la dernière tâche qu'il accompli est de charger init.

### systemd (init)

C'est le premier processus lancé par le noyau il a pour PID 1, il récupère sa configuration dans le fichier /etc/inittab.

Il lance /etc/init.d/rc avec comme paramètre le runlevel.

### Rc

C'est un script qui a pour objectif de lancer différents démons qui se trouvent dans /etc/rcX.d où X est un runlevel.

[Arch_boot_process](https://wiki.archlinux.org/title/Arch_boot_process)






