# Installation d'Arch Linux
## :hammer: En cours de réalisation ! :hammer:

## Installation spécifique pour les supports amovibles à mémoire flash NAND tels que clé USB,SSD,carte SD... .

| Document | Description |
|:--|:--|
| usb_arch_linux_project.md | Documentation. |
| before_install.md | Prérequis avant installation. |
| i`nstall_arch.md | Installation d'Arch Linux de base. |
| install_xfce.md | Installation et configuration d'un environnement graphique sous XFCE4. |
| install_arch_xfce.sh | Script pour automatiser l'installation et la configuration. |
| background.png | Fond pour le menu GRUB, [aurora-borealis-starry-night-night](https://publicdomainpictures.net/en/view-image.php?image=310278&picture=aurora-borealis-starry-night-night)|

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
