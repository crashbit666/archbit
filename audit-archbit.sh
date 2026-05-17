#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-arch-bootc:latest}"

echo "== Imatge =="
sudo podman image exists "$IMAGE"
sudo podman images "$IMAGE"

echo
echo "== Capes OCI =="
sudo podman history "$IMAGE"

echo
echo "== Labels bootc =="
sudo podman inspect "$IMAGE" \
  --format 'containers.bootc={{ index .Config.Labels "containers.bootc" }}'

echo
echo "== bootc lint =="
sudo podman run --rm --privileged "$IMAGE" bootc container lint

echo
echo "== Paquets explícits =="
sudo podman run --rm "$IMAGE" pacman -Qqe | sort

echo
echo "== Comprovació composefs / readonly =="
sudo podman run --rm "$IMAGE" sh -c '
  echo "--- /usr/lib/ostree/prepare-root.conf ---"
  cat /usr/lib/ostree/prepare-root.conf || true
  echo
  echo "--- binaris clau ---"
  command -v bootc || true
  command -v flatpak || true
  command -v podman || true
  command -v distrobox || true
  command -v toolbox || true
'
