#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ghcr.io/crashbit666/archbit:latest}"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║      ARCHBIT BOOTC — USB INSTALLER          ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  Image: $IMAGE"
echo ""

# Check dependencies
for cmd in podman lsblk; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "  ERROR: '$cmd' not found. Install it first."
    exit 1
  fi
done

# Check root
if [[ $EUID -ne 0 ]]; then
  echo "  This script must be run as root (sudo)."
  echo "  Usage: sudo $0 [image]"
  exit 1
fi

# Detect removable USB devices
echo "  Detecting USB devices..."
echo ""

DEVICES=()
while IFS= read -r line; do
  DEVICES+=("$line")
done < <(lsblk -dnpo NAME,SIZE,MODEL,TRAN 2>/dev/null | grep -i usb || true)

if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "  ERROR: No USB devices found."
  echo "  Insert a USB drive and try again."
  exit 1
fi

echo "  Available USB devices:"
echo ""
for i in "${!DEVICES[@]}"; do
  echo "    [$((i+1))] ${DEVICES[$i]}"
done
echo ""

# Select device
while true; do
  read -rp "  Select device [1-${#DEVICES[@]}]: " CHOICE
  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#DEVICES[@]} )); then
    break
  fi
  echo "  Invalid selection."
done

TARGET_DEV=$(echo "${DEVICES[$((CHOICE-1))]}" | awk '{print $1}')
TARGET_INFO="${DEVICES[$((CHOICE-1))]}"

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │  WARNING: ALL DATA WILL BE DESTROYED         │"
echo "  │                                              │"
echo "  │  Device: $TARGET_DEV"
echo "  │  Info:   $(echo "$TARGET_INFO" | sed 's/^ *//')"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo ""
read -rp "  Type 'YES' to confirm: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "  Aborted."
  exit 0
fi

# Unmount any mounted partitions from the device
echo ""
echo "  [1/3] Preparing device..."
for part in "${TARGET_DEV}"*; do
  if mountpoint -q "$part" 2>/dev/null || grep -q "$part" /proc/mounts 2>/dev/null; then
    umount "$part" 2>/dev/null || true
  fi
done

# Pull image
echo ""
echo "  [2/3] Pulling OCI image..."
podman pull "$IMAGE"

# Install to USB
echo ""
echo "  [3/3] Installing to USB (this will take several minutes)..."
echo ""

podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  "$IMAGE" \
  bootc install to-disk "$TARGET_DEV" \
    --filesystem ext4 \
    --generic-image \
    --wipe

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║            INSTALLATION COMPLETE             ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  Your Archbit Bootc USB is ready!"
echo ""
echo "  Next steps:"
echo "    1. Boot from the USB (UEFI mode)"
echo "    2. Complete the first-boot setup"
echo "    3. Enjoy your Archbit desktop"
echo ""
echo "  To install to internal disk later:"
echo "    sudo bootc install to-disk /dev/nvme0n1"
echo ""
