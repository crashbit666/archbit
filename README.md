<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/crashbit666/archbit/main/.github/assets/logo.svg">
    <img alt="Archbit Bootc" width="200" src="https://raw.githubusercontent.com/crashbit666/archbit/main/.github/assets/logo.svg">
  </picture>
</p>

<h1 align="center">⚡ ARCHBIT BOOTC ⚡</h1>

<p align="center">
  <b>Immutable Arch Linux — OCI-native — Atomic — Hyprland + Omarchy</b>
</p>

<p align="center">
  <code>Your OS is an artifact. Your desktop is a weapon.</code>
</p>

<br>

<p align="center">
  <a href="https://archlinux.org"><img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux"></a>
  <a href="https://github.com/bootc-dev/bootc"><img src="https://img.shields.io/badge/bootc-Atomic_OS-0078D4?style=for-the-badge&logo=codeblocks&logoColor=white" alt="bootc"></a>
  <a href="https://opencontainers.org"><img src="https://img.shields.io/badge/OCI-Native-262261?style=for-the-badge&logo=open-containers-initiative&logoColor=white" alt="OCI"></a>
  <a href="https://hyprland.org"><img src="https://img.shields.io/badge/Hyprland-00C4B3?style=for-the-badge&logo=wayland&logoColor=white" alt="Hyprland"></a>
  <a href="https://omarchy.com"><img src="https://img.shields.io/badge/Omarchy-Hacker_Desktop-8B5CF6?style=for-the-badge&logo=hackthebox&logoColor=white" alt="Omarchy"></a>
</p>

<p align="center">
  <a href="https://github.com/crashbit666/archbit/actions"><img src="https://img.shields.io/github/actions/workflow/status/crashbit666/archbit/build.yaml?style=flat-square&logo=github-actions&logoColor=white&label=build" alt="Build"></a>
  <a href="https://github.com/crashbit666/archbit/pkgs/container/archbit"><img src="https://img.shields.io/badge/GHCR-image_available-blue?style=flat-square&logo=github&logoColor=white" alt="GHCR"></a>
  <a href="https://github.com/crashbit666/archbit/blob/main/LICENSE"><img src="https://img.shields.io/github/license/crashbit666/archbit?style=flat-square&color=green" alt="License"></a>
</p>

---

```
   ╔══════════════════════════════════════════════════════════════╗
   ║                                                              ║
   ║   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         ║
   ║   │  Arch   │  │  bootc  │  │  OCI    │  │Hyprland │         ║
   ║   │  Linux  │──│ Atomic  │──│ Native  │──│Omarchy  │         ║
   ║   └─────────┘  └─────────┘  └─────────┘  └─────────┘         ║
   ║                                                              ║
   ║   The OS is an image.        Updates are atomic.             ║
   ║   Rollbacks are instant.     The host stays clean.           ║
   ║                                                              ║
   ╚══════════════════════════════════════════════════════════════╝
```

---

## 🔥 What is this?

**Archbit Bootc** is an experimental immutable Arch Linux system built as a **bootable OCI image**.

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   Fedora Silverblue  ──►  but Arch Linux                         │
│   + OCI containers   ──►  as the delivery format                 │
│   + Hyprland         ──►  Wayland-native compositor              │
│   + Omarchy          ──►  hacker desktop layer                   │
│   + bootc            ──►  image-based OS management              │
│   = cyberpunk workstation energy                                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 🧬 It combines

| Component | Role |
|:--|:--|
| 🏗️ **Arch Linux** | Base system — rolling release, always current |
| 📦 **bootc** | Image-based OS deployments + atomic upgrades |
| 🐳 **OCI images** | Distribution format — build, push, pull, deploy |
| 🔒 **composefs + ostree** | Immutable root with integrity verification |
| 🖥️ **Hyprland** | Dynamic tiling Wayland compositor |
| 🎨 **Omarchy** | Hacker-friendly desktop configs, themes and scripts |
| 📱 **Flatpak** | Sandboxed GUI applications |
| 🧰 **Distrobox / Toolbox** | Mutable development containers |

---

## ❓ Why?

> Traditional Linux systems are powerful, but they **drift**.

```
  Day 1                          Day 365
  ┌──────────┐                   ┌──────────┐
  │ ✅ Clean │    ───────►       │ 💀 ???   │
  │ ✅ Known │   manual edits    │ 💀 Drift │
  │ ✅ Works │   forgotten pkgs  │ 💀 Broke │
  └──────────┘   config entropy  └──────────┘
```

**Archbit Bootc** flips the model:

```
  ┌─────────────────────────────────────────────┐
  │  📦 The OS is an image                      │
  │  ⚛️  Updates are atomic                     │
  │  ⏪ Rollbacks are instant                   │
  │  🧹 The host stays clean                    │
  │  🔄 The workflow is reproducible            │
  └─────────────────────────────────────────────┘
```

This is **Arch Linux treated like infrastructure**.

---

## ⚙️ Core Features

### 🔒 Immutable root filesystem

```
  /usr     ──► read-only (composefs)
  /etc     ──► managed overlay
  /var     ──► mutable state
  /home    ──► user data (persistent)

  ┌────────────────────────────────────┐
  │  The machine is not a snowflake.   │
  │  It's a deployment target.         │
  └────────────────────────────────────┘
```

### 🐳 OCI-native operating system

Your OS is a container image. Pull it like any other:

```bash
# 📦 The image
ghcr.io/crashbit666/archbit:latest
```

Build it. Push it. Pull it. Deploy it. Roll it back. Version it. Diff it.

### ⚛️ Atomic updates with bootc

```bash
# 🔄 Upgrade
sudo bootc upgrade
sudo reboot

# ⏪ Something wrong? Roll back
sudo bootc rollback
sudo reboot
```

```
  Deploy A ◄──── Deploy B (current)
     │                │
     └── rollback ────┘
         instant, safe
```

### 🎯 Arch Linux, but disciplined

```
  ┌────────────────────────────────────────────┐
  │  Still Arch.  Still current.  Still fast.  │
  │                                            │
  │  + immutable deployments                   │
  │  + OCI delivery                            │
  │  + reproducible builds                     │
  │  + clean application layering              │
  │  + zero system drift                       │
  └────────────────────────────────────────────┘
```

### 🖥️ Hyprland + Omarchy

```
  ┌─────────────────────────────────────────────────┐
  │  Hyprland        dynamic tiling compositor      │
  │  Waybar          status bar                     │
  │  PipeWire        audio                          │
  │  Kitty/Foot      terminal emulators             │
  │  Mako            notifications                  │
  │  Omarchy         themes, keybinds, scripts      │
  │  uwsm            session manager                │
  └─────────────────────────────────────────────────┘
```

A sharp, minimal, hacker-oriented desktop that feels **engineered** rather than accumulated.

---

## 🧠 System Philosophy

```
  ┌─────────────────────────────────────────────────────────────┐
  │                                                             │
  │   ┌─────────────┐   ┌──────────────┐   ┌──────────────┐     │
  │   │  📦 IMAGE   │   │  📱 FLATPAK  │   │  🧰 DISTRO  │      │
  │   │             │   │              │   │     BOX      │     │
  │   │  kernel     │   │  firefox     │   │              │     │
  │   │  firmware   │   │  vscode      │   │  dev tools   │     │
  │   │  desktop    │   │  spotify     │   │  compilers   │     │
  │   │  services   │   │  discord     │   │  runtimes    │     │
  │   │  CLI tools  │   │  obs         │   │  databases   │     │
  │   │  containers │   │  ...         │   │  ...         │     │
  │   │             │   │              │   │              │     │
  │   │ IMMUTABLE   │   │  SANDBOXED   │   │   MUTABLE    │     │
  │   └─────────────┘   └──────────────┘   └──────────────┘     │
  │                                                             │
  │         the host stays clean, always                        │
  └─────────────────────────────────────────────────────────────┘
```

### 📱 GUI apps → Flatpak

```bash
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.visualstudio.code
```

### 🧰 Development → Distrobox / Toolbox

```bash
distrobox-create --name archdev --image archlinux:latest
distrobox-enter archdev

# Full mutable Arch inside a container
# Host stays untouched
```

---

## 🛠️ Tech Stack

```
  ┌──────────────────────────────────────────────┐
  │                ARCHBIT BOOTC                 │
  ├──────────────────────────────────────────────┤
  │                                              │
  │  🏗️  Arch Linux          base system         │
  │  📦  bootc               atomic OS mgmt      │
  │  🌳  ostree              deployment tree     │
  │  🔐  composefs           verified rootfs     │
  │  🥾  systemd-boot        boot manager        │
  │  🐋  Podman              container runtime   │
  │  📦  GHCR                image registry      │
  │  🖥️  Hyprland            Wayland compositor  │
  │  🎨  Omarchy             desktop layer       │
  │  📱  Flatpak             GUI apps            │
  │  🧰  Distrobox/Toolbox   dev environments    │
  │  🔊  PipeWire            audio stack         │
  │  ⌨️  uwsm                session manager     │
  │                                              │
  └──────────────────────────────────────────────┘
```

---

## 🔨 Build Workflow

```bash
# Build, lint, push, generate bootable image — all in one
./build-and-push.sh
```

```
  ┌────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
  │ pull base  │───►│  build OCI │───►│ bootc lint │───►│ push GHCR  │
  │   image    │    │   image    │    │  validate  │    │  + sign    │
  └────────────┘    └────────────┘    └────────────┘    └────────────┘
                                                               │
                                                               ▼
                                                        ┌────────────┐
                                                        │ generate   │
                                                        │ bootable   │
                                                        │   .img     │
                                                        └────────────┘
```

Or use the Justfile directly:

```bash
just build-containerfile          # build image
just generate-bootable-image      # create bootable .img
just bootc install to-disk ...    # install to disk
```

---

## 🚀 Getting Started

### First install (from bootable image)

```bash
# Generate the image
just generate-bootable-image

# Boot it in a VM or write to disk
```

### Switch an existing install to GHCR

```bash
sudo bootc switch ghcr.io/crashbit666/archbit:latest
sudo reboot
```

### Regular updates

```bash
sudo bootc upgrade    # pull new image
sudo reboot           # activate it
```

---

## 🔄 Automatic Updates

```
  ┌──────────────────────────────────────────────────────────┐
  │                                                          │
  │  🏗️  GitHub Actions                                      │
  │  │   builds + pushes OCI image daily                     │
  │  │   or on every push to main                            │
  │  │                                                       │
  │  ▼                                                       │
  │  📦  GHCR (ghcr.io/crashbit666/archbit:latest)     │
  │  │                                                       │
  │  ▼                                                       │
  │  💻  Client: bootc upgrade (timer or manual)             │
  │  │                                                       │
  │  ▼                                                       │
  │  👤  Human: decides when to reboot                       │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

---

## 🛡️ Security Model

```
  ┌────────────────────────────────────────────┐
  │  ✅  Immutable root filesystem             │
  │  ✅  Atomic deployments                    │
  │  ✅  Instant rollbacks                     │
  │  ✅  Cosign image signatures               │
  │  ✅  Minimal host mutation                 │
  │  ✅  Reproducible builds                   │
  │  ✅  OS / Apps / Dev separation            │
  └────────────────────────────────────────────┘
```

> ⚠️ **Never bake secrets into the image.**
> No tokens. No SSH keys. No passwords. No certs.
> The image should be safe to publish publicly.

---

## 📊 Current Status

```
  ┌──────────────────────────────────────────┐
  │                                          │
  │   Status:    🧪 EXPERIMENTAL             │
  │   Edge:      🩸 BLEEDING                 │
  │   Stability: ⚠️  USE AT OWN RISK         │
  │                                          │
  │   This is not a conventional Arch        │
  │   install. This is for people who        │
  │   want their workstation to behave       │
  │   like infrastructure.                   │
  │                                          │
  └──────────────────────────────────────────┘
```

---

## 💡 Inspiration

| Project | Influence |
|:--|:--|
| 🎩 Fedora Silverblue / Kinoite | Immutable desktop model |
| 🦎 Universal Blue / Bluefin / Bazzite | OCI-based OS customization |
| 🎮 SteamOS | Immutable gaming OS |
| 🔧 Talos Linux / Flatcar | Infrastructure-as-code OS |
| 🎨 Omarchy | Hacker desktop philosophy |
| 🏗️ Arch Linux | Rolling release, simplicity, power |

---

## 🎯 The Pitch

```
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║   Archbit Bootc is what happens when Arch Linux              ║
  ║   stops being a pet and becomes cattle.                      ║
  ║                                                              ║
  ║   Still yours.  Still sharp.  Still dangerous.               ║
  ║   But now image-based, atomic and rollbackable.              ║
  ║                                                              ║
  ║   ┌──────────────────────────────────────────────────────┐   ║
  ║   │  pacman       is for the image                       │   ║
  ║   │  flatpak      is for apps                            │   ║
  ║   │  distrobox    is for development                     │   ║
  ║   │  bootc        is for the operating system            │   ║
  ║   └──────────────────────────────────────────────────────┘   ║
  ║                                                              ║
  ║   Welcome to Arch, rebuilt as an artifact.                   ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
```

---

<p align="center">
  <sub>MIT License — Built with 🖤 and too much caffeine</sub>
</p>
