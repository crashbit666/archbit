#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ghcr.io/crashbit666/archbit-bootc:latest}"
VM_NAME="archbit-bootc"
DISK_SIZE="20G"
RAM="4096"
CPUS="2"
DISK_PATH="${HOME}/archbit-bootc.img"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        ARCHBIT BOOTC — VM INSTALLER         ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  Image:  $IMAGE"
echo "  VM:     $VM_NAME"
echo "  Disk:   $DISK_PATH ($DISK_SIZE)"
echo "  RAM:    ${RAM}MB / CPUs: $CPUS"
echo ""

# Check dependencies
for cmd in podman virt-install virsh; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "  ERROR: '$cmd' not found. Install it first."
    exit 1
  fi
done

# Remove existing VM if present
if virsh --connect qemu:///system dominfo "$VM_NAME" &>/dev/null; then
  read -rp "  VM '$VM_NAME' already exists. Delete it? [y/N]: " CONFIRM
  if [[ "$CONFIRM" =~ ^[yY]$ ]]; then
    virsh --connect qemu:///system destroy "$VM_NAME" 2>/dev/null || true
    virsh --connect qemu:///system undefine "$VM_NAME" --nvram 2>/dev/null || true
    rm -f "$DISK_PATH"
    echo "  → Old VM removed"
  else
    echo "  Aborted."
    exit 0
  fi
fi

# Pull image
echo ""
echo "  [1/3] Pulling OCI image..."
podman pull "$IMAGE"

# Create bootable disk
echo ""
echo "  [2/3] Creating bootable disk ($DISK_SIZE)..."
if [[ -f "$DISK_PATH" ]]; then
  rm -f "$DISK_PATH"
fi
fallocate -l "$DISK_SIZE" "$DISK_PATH"

sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  -v "$(dirname "$DISK_PATH"):/data" \
  "$IMAGE" \
  bootc install to-disk \
    --via-loopback "/data/$(basename "$DISK_PATH")" \
    --filesystem ext4 \
    --wipe

# Create VM
echo ""
echo "  [3/3] Creating VM '$VM_NAME'..."
virt-install \
  --connect qemu:///system \
  --name "$VM_NAME" \
  --memory "$RAM" \
  --vcpus "$CPUS" \
  --import \
  --disk "path=$DISK_PATH,format=raw" \
  --os-variant archlinux \
  --boot uefi \
  --graphics spice \
  --video virtio \
  --network network=default \
  --noautoconsole

echo ""
echo "  ✓ VM '$VM_NAME' created and started!"
echo ""
echo "  Open virt-manager to see the first-boot setup."
echo "  Or connect with: virt-viewer --connect qemu:///system $VM_NAME"
echo ""
