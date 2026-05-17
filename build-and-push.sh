#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$SCRIPT_DIR}"

LOCAL_IMAGE="${LOCAL_IMAGE:-arch-bootc:latest}"
REGISTRY_IMAGE="${REGISTRY_IMAGE:-ghcr.io/crashbit666/archbit:latest}"
DEST_DIR="${DEST_DIR:-$HOME/Baixades/isos}"
STATE_DIR="${STATE_DIR:-$PROJECT_DIR/.state}"

mkdir -p "$DEST_DIR" "$STATE_DIR"
cd "$PROJECT_DIR"

echo "==> Project dir: $PROJECT_DIR"
echo "==> Local image: $LOCAL_IMAGE"
echo "==> Registry image: $REGISTRY_IMAGE"

echo
echo "==> Pull base Arch image"
podman pull docker.io/archlinux/archlinux:latest

BASE_DIGEST="$(podman image inspect docker.io/archlinux/archlinux:latest --format '{{.Digest}}')"
CONFIG_HASH="$(sha256sum "$PROJECT_DIR/Containerfile" "$PROJECT_DIR/Justfile" | sha256sum | awk '{print $1}')"
CURRENT_STATE="${BASE_DIGEST}-${CONFIG_HASH}"

STATE_FILE="$STATE_DIR/last-build.state"
LAST_STATE="$(cat "$STATE_FILE" 2>/dev/null || true)"

if [[ "$CURRENT_STATE" == "$LAST_STATE" ]]; then
  echo "==> No hi ha canvis. No faig rebuild."
  exit 0
fi

echo
echo "==> Canvis detectats. Build necessari."

echo
echo "==> Build local image: $LOCAL_IMAGE"
podman build --pull=always -f "$PROJECT_DIR/Containerfile" -t "$LOCAL_IMAGE" "$PROJECT_DIR"

echo
echo "==> bootc lint"
podman run --rm --privileged "$LOCAL_IMAGE" bootc container lint

echo
echo "==> Tag GHCR image: $REGISTRY_IMAGE"
podman tag "$LOCAL_IMAGE" "$REGISTRY_IMAGE"

echo
echo "==> Push to GHCR"
podman push "$REGISTRY_IMAGE"

echo "$CURRENT_STATE" >"$STATE_FILE"

echo
echo "==> Generate bootable .img"
if just generate-bootable-image; then
  IMG_FILE="$(find "$PROJECT_DIR" -maxdepth 5 -type f -iname "*.img" -printf "%T@ %p\n" | sort -nr | head -n1 | cut -d' ' -f2-)"

  if [[ -n "$IMG_FILE" ]]; then
    STAMP="$(date +%Y%m%d-%H%M%S)"
    DEST_FILE="$DEST_DIR/archbit-${STAMP}.img"

    echo
    echo "==> Copy image to $DEST_FILE"
    cp -v "$IMG_FILE" "$DEST_FILE"

    echo
    echo "==> Checksum"
    sha256sum "$DEST_FILE" | tee "$DEST_FILE.sha256"
  fi
else
  echo "==> WARN: Bootable .img generation skipped (needs interactive terminal)"
fi

echo
echo "==> Fet"
