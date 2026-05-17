#!/bin/bash

MARKER="/var/lib/archbit/.firstboot-done"

if [[ -f "$MARKER" ]]; then
  exit 0
fi

exec > /dev/tty1 2>&1 < /dev/tty1

clear
echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║          ARCHBIT BOOTC — FIRST BOOT         ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# Keyboard layout
echo "  Available keyboard layouts (common):"
echo "    us, es, uk, fr, de, it, pt, br, ca, se, no, fi, dk, pl, cz, hu, ro"
echo ""
read -rp "  Keyboard layout [us]: " KB_LAYOUT
KB_LAYOUT="${KB_LAYOUT:-us}"

if loadkeys "$KB_LAYOUT" 2>/dev/null; then
  echo "  → Keyboard set to: $KB_LAYOUT"
else
  echo "  → Warning: layout '$KB_LAYOUT' not found, using 'us'"
  KB_LAYOUT="us"
  loadkeys us 2>/dev/null || true
fi

echo ""

# Username
while true; do
  read -rp "  Username: " USERNAME
  if [[ -z "$USERNAME" ]]; then
    echo "  → Username cannot be empty"
    continue
  fi
  if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "  → Invalid username (lowercase, no spaces)"
    continue
  fi
  break
done

echo ""

# Password
while true; do
  read -rsp "  Password: " PASSWORD
  echo ""
  read -rsp "  Confirm password: " PASSWORD2
  echo ""
  if [[ -z "$PASSWORD" ]]; then
    echo "  → Password cannot be empty"
    continue
  fi
  if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
    echo "  → Passwords do not match"
    continue
  fi
  break
done

echo ""
echo "  Creating user '$USERNAME'..."

if ! useradd -m -G wheel,seat "$USERNAME"; then
  echo "  ERROR: Failed to create user '$USERNAME'"
  sleep 10
  exit 1
fi
echo "$USERNAME:$PASSWORD" | chpasswd

# Persist keyboard layout
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/vconsole.conf << EOF
KEYMAP=$KB_LAYOUT
EOF

cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "$KB_LAYOUT"
EndSection
EOF

# Mark first boot as done
mkdir -p /var/lib/archbit
echo "user=$USERNAME" > "$MARKER"
echo "layout=$KB_LAYOUT" >> "$MARKER"
date >> "$MARKER"

echo ""
echo "  ✓ User '$USERNAME' created"
echo "  ✓ Keyboard layout '$KB_LAYOUT' configured"
echo "  ✓ Starting desktop..."
echo ""
sleep 2
