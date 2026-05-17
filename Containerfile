FROM docker.io/archlinux/archlinux:latest

# Move pacman mutable data into /usr/lib/sysimage
RUN grep "= */var" /etc/pacman.conf | \
    sed "/= *\/var/s/.*=// ; s/ //" | \
    xargs -n1 sh -c 'mkdir -p "/usr/lib/sysimage/$(dirname $(echo $1 | sed "s@/var/@@"))" && mv -v "$1" "/usr/lib/sysimage/$(echo "$1" | sed "s@/var/@@")"' '' && \
    sed -i \
      -e "/= *\/var/ s/^#//" \
      -e "s@= */var@= /usr/lib/sysimage@g" \
      -e "/DownloadUser/d" \
      /etc/pacman.conf

# Re-enable docs/locales
RUN sed -i 's/^[[:space:]]*NoExtract/#&/' /etc/pacman.conf

# Fix locales missing from container image
RUN --mount=type=tmpfs,dst=/tmp \
    --mount=type=cache,dst=/usr/lib/sysimage/cache/pacman \
    pacman -Sy glibc --noconfirm

# Base immutable system
RUN pacman -Syu --noconfirm \
    base \
    cpio \
    dracut \
    linux \
    linux-firmware \
    ostree \
    btrfs-progs \
    e2fsprogs \
    xfsprogs \
    dosfstools \
    skopeo \
    podman \
    dbus \
    dbus-glib \
    glib2 \
    shadow \
    && pacman -S --clean --noconfirm

# Install bootc
RUN --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/root \
    pacman -S --noconfirm make git rust go-md2man && \
    git clone https://github.com/bootc-dev/bootc.git /tmp/bootc && \
    make -C /tmp/bootc bin install-all && \
    git clone https://github.com/coreos/bootupd.git /tmp/bootupd && \
    cd /tmp/bootupd && cargo build --release && \
    install -Dm755 target/release/bootupd /usr/bin/bootupd && \
    ln -sf bootupd /usr/bin/bootupctl && \
    cd / && \
    printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | \
      tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf && \
    printf 'reproducible=yes\nhostonly=no\ncompress=zstd\nadd_dracutmodules+=" ostree bootc "' | \
      tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-container-build.conf && \
    dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img" && \
    pacman -Rns --noconfirm make git rust go-md2man && \
    pacman -S --clean --noconfirm

# Immutable filesystem layout
RUN sed -i 's|^HOME=.*|HOME=/var/home|' /etc/default/useradd && \
    rm -rf \
      /boot \
      /home \
      /root \
      /usr/local \
      /srv \
      /opt \
      /mnt \
      /var \
      /usr/lib/sysimage/log \
      /usr/lib/sysimage/cache/pacman/pkg && \
    mkdir -p /sysroot /boot /usr/lib/ostree /var && \
    ln -sT sysroot/ostree /ostree && \
    ln -sT var/roothome /root && \
    ln -sT var/srv /srv && \
    ln -sT var/opt /opt && \
    ln -sT var/mnt /mnt && \
    ln -sT var/home /home && \
    ln -sT ../var/usrlocal /usr/local && \
    echo "$(for dir in opt home srv mnt usrlocal ; do echo "d /var/$dir 0755 root root -" ; done)" | \
      tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    printf "d /var/roothome 0700 root root -\nd /run/media 0755 root root -\nd /var/usrlocal/bin 0755 root root -\n" | \
      tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' | \
      tee /usr/lib/ostree/prepare-root.conf

# Desktop + tooling
RUN pacman -Syu --noconfirm \
    sudo \
    networkmanager \
    flatpak \
    podman \
    distrobox \
    toolbox \
    git \
    curl \
    wget \
    nano \
    vim \
    neovim \
    fastfetch \
    bash-completion \
    openssh \
    ca-certificates \
    man-db \
    man-pages \
    xdg-user-dirs \
    hyprland \
    hyprlock \
    hypridle \
    hyprsunset \
    hyprpicker \
    waybar \
    alacritty \
    kitty \
    foot \
    mako \
    swaybg \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    pipewire \
    pipewire-pulse \
    wireplumber \
    polkit \
    polkit-gnome \
    seatd \
    sddm \
    qt6-wayland \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-liberation \
    mesa \
    mesa-utils \
    vulkan-virtio \
    qemu-guest-agent \
    xorg-xwayland \
    grim \
    slurp \
    wl-clipboard \
    uwsm \
    fcitx5 \
    gum \
    jq \
    socat \
    starship \
    zoxide \
    btop \
    bat \
    eza \
    fd \
    fzf \
    ripgrep \
    imagemagick \
    playerctl \
    otf-font-awesome \
    && pacman -S --clean --noconfirm

# Omarchy
ARG OMARCHY_COMMIT=dev

RUN git clone https://github.com/basecamp/omarchy.git /usr/share/omarchy && \
    cd /usr/share/omarchy && \
    git checkout "$OMARCHY_COMMIT" && \
    rm -rf .git

# Install Omarchy configs (Lua-based Hyprland configuration)
RUN mkdir -p \
      /etc/skel/.config \
      /etc/skel/.local/share/omarchy \
      /usr/share/wayland-sessions && \
    cp -a /usr/share/omarchy/config/. /etc/skel/.config/ && \
    cp -a /usr/share/omarchy/default /etc/skel/.local/share/omarchy/default && \
    cp -a /usr/share/omarchy/themes /etc/skel/.local/share/omarchy/themes && \
    cp -a /usr/share/omarchy/bin /etc/skel/.local/share/omarchy/bin && \
    cp -a /usr/share/omarchy/default/wayland-sessions/. /usr/share/wayland-sessions/ && \
    find /usr/share/omarchy/bin -type f -executable -exec ln -sf {} /usr/bin/ \; && \
    cp -a /usr/share/omarchy/default/sddm/omarchy /usr/share/sddm/themes/omarchy && \
    mkdir -p /etc/skel/.local/share/fonts && \
    cp /usr/share/omarchy/config/omarchy.ttf /etc/skel/.local/share/fonts/

# Set default Omarchy theme (generates waybar.css, foot.ini, etc.)
RUN HOME=/etc/skel \
    OMARCHY_PATH=/etc/skel/.local/share/omarchy \
    PATH="/etc/skel/.local/share/omarchy/bin:$PATH" \
    OMARCHY_THEME_SKIP_BACKGROUND=1 \
    omarchy-theme-set hackerman && \
    ln -sf /etc/skel/.local/share/omarchy/themes/hackerman/backgrounds/omarchy.png \
      /etc/skel/.config/omarchy/current/background

# First boot setup (user creation, keyboard layout)
# Pre-configure locale/timezone to prevent systemd-firstboot from triggering
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "KEYMAP=us" > /etc/vconsole.conf && \
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    ln -sf /dev/null /usr/lib/systemd/system/systemd-firstboot.service

# First boot setup (user creation, keyboard layout, timezone)
COPY archbit-firstboot.sh /usr/bin/archbit-firstboot
COPY archbit-firstboot.service /usr/lib/systemd/system/archbit-firstboot.service
RUN chmod +x /usr/bin/archbit-firstboot

# Disk installer (for installing from live USB to internal disk)
COPY archbit-install.sh /usr/bin/archbit-install
RUN chmod +x /usr/bin/archbit-install

# Sudo and root
RUN mkdir -p /etc/sudoers.d && \
    passwd -l root && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

# Fix sddm user
RUN groupadd -f sddm && \
    id -u sddm >/dev/null 2>&1 || \
    useradd -r \
      -g sddm \
      -d /var/lib/sddm \
      -s /usr/bin/nologin \
      sddm && \
    mkdir -p /var/lib/sddm && \
    chown -R sddm:sddm /var/lib/sddm

RUN mkdir -p /usr/lib/sysusers.d /usr/lib/tmpfiles.d && \
    printf 'g sddm - - -\nu sddm - "SDDM greeter user" /var/lib/sddm /usr/bin/nologin\n' > /usr/lib/sysusers.d/archbit-sddm.conf && \
    printf 'd /var/lib/sddm 0755 sddm sddm -\n' > /usr/lib/tmpfiles.d/archbit-sddm.conf

# Enable services and set graphical target
# Use /usr/lib symlinks instead of systemctl enable — /etc symlinks
# are lost during ostree/bootc deployment
RUN mkdir -p \
      /usr/lib/systemd/system/multi-user.target.wants \
      /usr/lib/systemd/system/network-online.target.wants \
      /usr/lib/systemd/system/sockets.target.wants && \
    ln -sf ../NetworkManager.service /usr/lib/systemd/system/multi-user.target.wants/ && \
    ln -sf ../NetworkManager-dispatcher.service /usr/lib/systemd/system/dbus-org.freedesktop.nm-dispatcher.service && \
    ln -sf ../NetworkManager-wait-online.service /usr/lib/systemd/system/network-online.target.wants/ && \
    ln -sf ../seatd.service /usr/lib/systemd/system/multi-user.target.wants/ && \
    ln -sf ../archbit-firstboot.service /usr/lib/systemd/system/multi-user.target.wants/ && \
    ln -sf sddm.service /usr/lib/systemd/system/display-manager.service && \
    ln -sf graphical.target /usr/lib/systemd/system/default.target

# bootc metadata
LABEL containers.bootc=1

# Validate image
RUN bootc container lint
