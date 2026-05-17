# Archbit Bootc

> Immutable Arch Linux.  
> OCI-native.  
> Atomic updates.  
> Hyprland + Omarchy.  
> Built like the future.

---

![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![bootc](https://img.shields.io/badge/bootc-Atomic-blue?style=for-the-badge)
![OCI](https://img.shields.io/badge/OCI-Native-black?style=for-the-badge&logo=docker)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green?style=for-the-badge)
![Omarchy](https://img.shields.io/badge/Omarchy-Hacker_Desktop-purple?style=for-the-badge)

---

## What is this?

**Archbit Bootc** is an experimental immutable Arch Linux system built as a bootable OCI image.

It combines:

- **Arch Linux** as the base system
- **bootc** for image-based operating system deployments
- **OCI images** as the distribution format
- **composefs + ostree** for immutable root deployments
- **systemd-boot** for boot management
- **Hyprland** for a modern Wayland desktop
- **Omarchy** as the hacker-friendly desktop layer
- **Flatpak, Distrobox and Toolbox** for clean application and development workflows

Think of it as:

```text
Fedora Silverblue
+
Arch Linux
+
OCI containers
+
Hyprland
+
Omarchy
+
Cyberpunk workstation energy
```

---

## Why?

Traditional Linux systems are powerful, but they drift.

You install packages manually.  
You edit configs.  
You forget what changed.  
One day an update breaks something and the system becomes archaeology.

Archbit Bootc flips the model:

```text
The OS is an image.
Updates are atomic.
Rollbacks are expected.
The host stays clean.
The workflow becomes reproducible.
```

This is Arch Linux treated like infrastructure.

---

## Core Features

### Immutable root filesystem

The base system is designed to be:

- read-only
- image-based
- reproducible
- atomically updated
- rollback-friendly

The machine stops being a pile of manual mutations and becomes a deployment target.

---

### OCI-native operating system

The OS is published as a container image:

```bash
ghcr.io/crashbit666/archbit-bootc:latest
```

Your operating system becomes something you can build, push, pull, deploy and roll back.

---

### Atomic updates with bootc

Update safely:

```bash
sudo bootc upgrade
sudo reboot
```

If the new deployment is bad, roll back.

```bash
sudo bootc rollback
sudo reboot
```

---

### Arch Linux, but disciplined

Still Arch.

Still current.

Still fast.

But now with:

- immutable deployments
- OCI delivery
- reproducible builds
- clean application layering
- less system drift

---

### Hyprland + Omarchy

Archbit Bootc includes a Wayland-first desktop foundation:

- Hyprland
- Waybar
- PipeWire
- WirePlumber
- Kitty / Alacritty
- Mako
- Omarchy configs, themes and scripts
- modern fonts and desktop components

The goal is a sharp, minimal, hacker-oriented desktop that feels engineered rather than accumulated.

---

## System Philosophy

### The base image is sacred

Put these in the immutable image:

- kernel
- firmware
- boot stack
- desktop session
- system services
- core CLI tools
- container tooling

### GUI apps go to Flatpak

```bash
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.visualstudio.code
```

### Development goes to Distrobox or Toolbox

```bash
distrobox-create --name archdev --image archlinux:latest
distrobox-enter archdev
```

The host remains clean.  
The development environment remains flexible.

---

## Included Technologies

- Arch Linux
- bootc
- ostree
- composefs
- systemd-boot
- Podman
- GHCR
- Hyprland
- Omarchy
- Flatpak
- Distrobox
- Toolbox
- Wayland

---

## Build Workflow

Build and push the image:

```bash
./build-and-push.sh
```

The script can:

- pull the latest Arch base image
- detect changes
- rebuild the OCI image only when needed
- run `bootc container lint`
- push to GHCR
- generate a bootable `.img`
- copy it to `~/Baixades/isos/`
- generate a checksum

---

## First Switch to GHCR

Inside the installed VM or machine:

```bash
sudo bootc switch ghcr.io/crashbit666/archbit-bootc:latest
sudo reboot
```

After that, normal updates are simple:

```bash
sudo bootc upgrade
sudo reboot
```

---

## Automatic Updates

Recommended model:

```text
Host timer:
  rebuilds and pushes new OCI images when Arch or the Containerfile changes

Client timer:
  runs bootc upgrade periodically

Human:
  decides when to reboot
```

This turns a Linux desktop into a small CI/CD-driven operating system.

---

## Security Model

Archbit Bootc aims for:

- immutable root filesystem
- atomic deployments
- rollback support
- minimal host mutation
- reproducible image builds
- separation between base OS, apps and dev environments

Do not bake secrets into the image.

Avoid embedding:

- personal tokens
- SSH private keys
- real user passwords
- private certificates
- sensitive configs

The image should be safe to publish publicly.

---

## Current Status

Experimental.

Bleeding edge.

Not a conventional Arch install.

Not for people who want to edit the host manually and hope for the best.

This is for people who want their workstation to behave like infrastructure.

---

## Inspiration

- Fedora Silverblue
- Fedora Kinoite
- Universal Blue
- Bluefin
- Bazzite
- SteamOS
- Talos Linux
- Flatcar
- Omarchy
- Arch Linux

---

## The Pitch

Archbit Bootc is what happens when Arch Linux stops being a pet system and becomes cattle.

Still yours.  
Still sharp.  
Still dangerous.  
But now image-based, atomic and rollbackable.

```text
pacman is for the image.
Flatpak is for apps.
Distrobox is for development.
bootc is for the operating system.
```

Welcome to Arch, rebuilt as an artifact.

---

## License

MIT
