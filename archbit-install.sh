#!/bin/bash

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║       ARCHBIT BOOTC — DISK INSTALLER        ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
  echo "  This script must be run as root."
  echo "  Usage: sudo archbit-install"
  exit 1
fi

# Detect the boot device (so we can exclude it)
BOOT_DEV=$(findmnt -n -o SOURCE / 2>/dev/null | sed 's/[0-9]*$//' | sed 's/p$//')

# Detect available block devices (exclude loop, sr, zram, boot device)
echo "  Detecting disks..."
echo ""

DEVICES=()
while IFS= read -r line; do
  DEV_NAME=$(echo "$line" | awk '{print $1}')
  # Skip the boot device
  if [[ "$DEV_NAME" == "$BOOT_DEV" ]]; then
    continue
  fi
  DEVICES+=("$line")
done < <(lsblk -dnpo NAME,SIZE,MODEL,TRAN 2>/dev/null | grep -v -E 'loop|sr[0-9]|zram')

if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "  ERROR: No available disks found."
  exit 1
fi

echo "  Available disks:"
echo ""
for i in "${!DEVICES[@]}"; do
  echo "    [$((i+1))] ${DEVICES[$i]}"
done
echo ""

if [[ -n "${BOOT_DEV:-}" ]]; then
  echo "  (Boot device $BOOT_DEV excluded)"
  echo ""
fi

# Select device
while true; do
  read -rp "  Select disk [1-${#DEVICES[@]}]: " CHOICE
  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#DEVICES[@]} )); then
    break
  fi
  echo "  Invalid selection."
done

TARGET_DEV=$(echo "${DEVICES[$((CHOICE-1))]}" | awk '{print $1}')

# Select filesystem
echo ""
echo "  Filesystem options:"
echo "    [1] ext4  — stable, proven (default)"
echo "    [2] btrfs — snapshots, compression"
echo "    [3] xfs   — high performance"
echo ""
read -rp "  Filesystem [1]: " FS_CHOICE
case "${FS_CHOICE:-1}" in
  2) FILESYSTEM="btrfs" ;;
  3) FILESYSTEM="xfs" ;;
  *) FILESYSTEM="ext4" ;;
esac

# Encryption option
echo ""
read -rp "  Enable disk encryption (TPM2-LUKS)? [y/N]: " ENCRYPT
if [[ "$ENCRYPT" =~ ^[yY]$ ]]; then
  BLOCK_SETUP="tpm2-luks"
  ENCRYPT_MSG="YES (TPM2-LUKS)"
else
  BLOCK_SETUP="direct"
  ENCRYPT_MSG="No"
fi

# Get the current image reference
CURRENT_IMAGE=$(bootc status --format json 2>/dev/null | grep -o '"image":{"image":{[^}]*}' | grep -o '"transport":"[^"]*","image":"[^"]*"' | head -1 | sed 's/"transport":"registry","image":"//' | sed 's/"$//' 2>/dev/null || echo "")

if [[ -z "$CURRENT_IMAGE" ]]; then
  # Fallback: try to get from bootc status text output
  CURRENT_IMAGE=$(bootc status 2>/dev/null | grep -oP 'image: \K.*' | head -1 || echo "ghcr.io/crashbit666/archbit-bootc:latest")
fi

# Show current partitions on target
echo ""
echo "  Current partitions on $TARGET_DEV:"
echo ""
lsblk -po NAME,SIZE,FSTYPE,MOUNTPOINT "$TARGET_DEV" 2>/dev/null | sed 's/^/    /'
echo ""

# Confirmation
echo "  ┌──────────────────────────────────────────────┐"
echo "  │  INSTALLATION SUMMARY                        │"
echo "  │                                              │"
echo "  │  Target:     $TARGET_DEV"
echo "  │  Filesystem: $FILESYSTEM"
echo "  │  Encryption: $ENCRYPT_MSG"
echo "  │  Image:      $CURRENT_IMAGE"
echo "  │                                              │"
echo "  │  WARNING: ALL DATA ON THE DISK WILL BE LOST  │"
echo "  └──────────────────────────────────────────────┘"
echo ""
read -rp "  Type 'YES' to install: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "  Aborted."
  exit 0
fi

# Unmount any partitions from target device
echo ""
echo "  Unmounting target partitions..."
for part in "${TARGET_DEV}"*; do
  umount "$part" 2>/dev/null || true
done

# Build bootc install command
BOOTC_ARGS=(
  bootc install to-disk
  --filesystem "$FILESYSTEM"
  --block-setup "$BLOCK_SETUP"
  --wipe
)

if [[ -n "$CURRENT_IMAGE" ]]; then
  BOOTC_ARGS+=(--source-imgref "containers-storage:$CURRENT_IMAGE")
fi

BOOTC_ARGS+=("$TARGET_DEV")

# Run installation
echo ""
echo "  Installing Archbit Bootc to $TARGET_DEV..."
echo "  This will take several minutes..."
echo ""

if "${BOOTC_ARGS[@]}"; then
  echo ""
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║          INSTALLATION COMPLETE!              ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo ""
  echo "  Archbit Bootc has been installed to $TARGET_DEV"
  echo ""
  echo "  Partitions created:"
  lsblk -po NAME,SIZE,FSTYPE "$TARGET_DEV" 2>/dev/null | sed 's/^/    /'
  echo ""
  echo "  Next steps:"
  echo "    1. Remove the USB drive"
  echo "    2. Reboot: sudo reboot"
  echo "    3. Boot from $TARGET_DEV (UEFI mode)"
  echo "    4. Complete the first-boot setup"
  echo ""
  echo "  Future updates:"
  echo "    sudo bootc upgrade && sudo reboot"
  echo ""
else
  echo ""
  echo "  ERROR: Installation failed."
  echo "  Check the output above for details."
  exit 1
fi
