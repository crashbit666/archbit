#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ghcr.io/crashbit666/archbit-bootc:latest}"
VM_NAME="archbit-bootc"
DISK_SIZE="20G"
RAM_KB="4194304"  # 4GB
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
echo "  RAM:    $((RAM_KB / 1024))MB / CPUs: $CPUS"
echo ""

# Check dependencies
for cmd in podman virsh; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "  ERROR: '$cmd' not found. Install it first."
    exit 1
  fi
done

# Find UEFI firmware
OVMF=""
for path in \
  /usr/share/edk2/ovmf/OVMF_CODE.fd \
  /usr/share/OVMF/OVMF_CODE.fd \
  /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
  /usr/share/qemu/OVMF_CODE.fd; do
  if [[ -f "$path" ]]; then
    OVMF="$path"
    break
  fi
done

if [[ -z "$OVMF" ]]; then
  echo "  ERROR: UEFI firmware (OVMF) not found."
  echo "  Install it: sudo dnf install edk2-ovmf  OR  sudo pacman -S edk2-ovmf"
  exit 1
fi

OVMF_VARS=""
for path in \
  /usr/share/edk2/ovmf/OVMF_VARS.fd \
  /usr/share/OVMF/OVMF_VARS.fd \
  /usr/share/edk2-ovmf/x64/OVMF_VARS.fd \
  /usr/share/qemu/OVMF_VARS.fd; do
  if [[ -f "$path" ]]; then
    OVMF_VARS="$path"
    break
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
rm -f "$DISK_PATH"
fallocate -l "$DISK_SIZE" "$DISK_PATH"

sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  -v "$(dirname "$DISK_PATH"):/data" \
  "$IMAGE" \
  bootc install to-disk \
    --via-loopback "/data/$(basename "$DISK_PATH")" \
    --filesystem ext4 \
    --wipe \
    --composefs-backend \
    --bootloader systemd

# Create NVRAM copy for this VM
NVRAM_PATH="/var/lib/libvirt/qemu/nvram/${VM_NAME}_VARS.fd"
sudo cp "$OVMF_VARS" "$NVRAM_PATH"
sudo chmod 644 "$NVRAM_PATH"

# Create VM via virsh XML
echo ""
echo "  [3/3] Creating VM '$VM_NAME'..."

virsh --connect qemu:///system define /dev/stdin <<XMLEOF
<domain type='kvm'>
  <name>${VM_NAME}</name>
  <memory unit='KiB'>${RAM_KB}</memory>
  <vcpu placement='static'>${CPUS}</vcpu>
  <os firmware='efi'>
    <type arch='x86_64' machine='q35'>hvm</type>
    <loader readonly='yes' type='pflash'>${OVMF}</loader>
    <nvram>${NVRAM_PATH}</nvram>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-passthrough' check='none'/>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='${DISK_PATH}'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
    <graphics type='spice' autoport='yes'/>
    <video>
      <model type='virtio' heads='1'/>
    </video>
    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>
    <input type='tablet' bus='usb'/>
    <input type='keyboard' bus='usb'/>
  </devices>
</domain>
XMLEOF

virsh --connect qemu:///system start "$VM_NAME"

echo ""
echo "  ✓ VM '$VM_NAME' created and started!"
echo ""
echo "  Open virt-manager to see the first-boot setup."
echo "  Or connect with: virt-viewer --connect qemu:///system $VM_NAME"
echo ""
