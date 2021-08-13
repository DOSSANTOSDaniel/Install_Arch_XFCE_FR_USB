# Installations d'Arch Linux
## En cours de réalisation ! :hammer:

## Installation spécifique pour les supports amovibles à mémoire flash NAND tels que clé USB,SSD,carte SD... .

| Document | Description |
|:--|:--|
| before_install.md | Prérequis avant installation. |
| install_arch.md | Installation d'Arch Linux de base. |
| install_xfce.md | Installation et configuration d'un environnement graphique sous XFCE4. |
| install_arch_xfce.sh | Script pour automatiser l'installation et la configuration. |

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


## Installation UEFI en dual-boot avec Windows 10

| Document | Description |
|:--|:--|
| before_install.md |  |
| install_arch_win.md |  |
