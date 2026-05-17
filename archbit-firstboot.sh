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

# Timezone
echo "  Common timezones:"
echo "    Europe/Madrid, Europe/London, Europe/Berlin, Europe/Paris"
echo "    America/New_York, America/Chicago, America/Los_Angeles"
echo "    Asia/Tokyo, Australia/Sydney, UTC"
echo ""
read -rp "  Timezone [UTC]: " TZ_CHOICE
TZ_CHOICE="${TZ_CHOICE:-UTC}"

if [[ -f "/usr/share/zoneinfo/$TZ_CHOICE" ]]; then
  ln -sf "/usr/share/zoneinfo/$TZ_CHOICE" /etc/localtime
  echo "  → Timezone set to: $TZ_CHOICE"
else
  echo "  → Warning: timezone '$TZ_CHOICE' not found, using UTC"
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime
fi

echo ""

# Keyboard layout
echo "  Common keyboard layouts:"
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
echo "timezone=$TZ_CHOICE" >> "$MARKER"
date >> "$MARKER"

echo ""
echo "  ✓ User '$USERNAME' created"
echo "  ✓ Keyboard layout '$KB_LAYOUT' configured"
echo "  ✓ Timezone '$TZ_CHOICE' configured"
echo "  ✓ Starting desktop..."
echo ""
sleep 2
