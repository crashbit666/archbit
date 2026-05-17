FROM docker.io/archlinux/archlinux:latest

RUN grep "= */var" /etc/pacman.conf | sed "/= *\/var/s/.*=// ; s/ //" | xargs -n1 sh -c 'mkdir -p "/usr/lib/sysimage/$(dirname $(echo $1 | sed "s@/var/@@"))" && mv -v "$1" "/usr/lib/sysimage/$(echo "$1" | sed "s@/var/@@")"' '' && \
    sed -i -e "/= *\/var/ s/^#//" -e "s@= */var@= /usr/lib/sysimage@g" -e "/DownloadUser/d" /etc/pacman.conf

RUN sed -i 's/^[[:space:]]*NoExtract/#&/' /etc/pacman.conf

RUN --mount=type=tmpfs,dst=/tmp --mount=type=cache,dst=/usr/lib/sysimage/cache/pacman \
    pacman -Sy glibc --noconfirm

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

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    pacman -S --noconfirm make git rust go-md2man && \
    git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc && \
    make -C /tmp/bootc bin install-all && \
    printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf && \
    printf 'reproducible=yes\nhostonly=no\ncompress=zstd\nadd_dracutmodules+=" ostree bootc "' | tee "/usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-container-build.conf" && \
    dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img" && \
    pacman -Rns --noconfirm make git rust go-md2man && \
    pacman -S --clean --noconfirm

RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
    rm -rf /boot /home /root /usr/local /srv /opt /mnt /var /usr/lib/sysimage/log /usr/lib/sysimage/cache/pacman/pkg && \
    mkdir -p /sysroot /boot /usr/lib/ostree /var && \
    ln -sT sysroot/ostree /ostree && \
    ln -sT var/roothome /root && \
    ln -sT var/srv /srv && \
    ln -sT var/opt /opt && \
    ln -sT var/mnt /mnt && \
    ln -sT var/home /home && \
    ln -sT ../var/usrlocal /usr/local && \
    echo "$(for dir in opt home srv mnt usrlocal ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
    printf "d /var/roothome 0700 root root -\nd /run/media 0755 root root -" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
    printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' | tee "/usr/lib/ostree/prepare-root.conf"

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
    waybar \
    alacritty \
    kitty \
    foot \
    wofi \
    mako \
    swaybg \
    swaylock \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    pipewire \
    pipewire-pulse \
    wireplumber \
    polkit \
    polkit-gnome \
    seatd \
    sddm \
    qt5-wayland \
    qt6-wayland \
    noto-fonts \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-liberation \
    mesa \
    mesa-utils \
    vulkan-virtio \
    xorg-xwayland \
    grim \
    slurp \
    wl-clipboard \
    # walker és AUR, no repo oficial \
    uwsm \
    && pacman -S --clean --noconfirm

ARG OMARCHY_COMMIT=82f99928d06eb9cbae37641f77f75c59c1459404

RUN git clone https://github.com/basecamp/omarchy.git /usr/share/omarchy && \
    cd /usr/share/omarchy && \
    git checkout "$OMARCHY_COMMIT" && \
    rm -rf .git

RUN mkdir -p /etc/skel/.config /usr/local/bin /usr/share/wayland-sessions && \
    cp -a /usr/share/omarchy/config/. /etc/skel/.config/ && \
    cp -a /usr/share/omarchy/default/hypr /etc/skel/.config/ && \
    cp -a /usr/share/omarchy/default/waybar /etc/skel/.config/ && \
    cp -a /usr/share/omarchy/default/mako /etc/skel/.config/ && \
    cp -a /usr/share/omarchy/default/alacritty /etc/skel/.config/ || true && \
    cp -a /usr/share/omarchy/default/kitty /etc/skel/.config/ || true && \
    cp -a /usr/share/omarchy/default/foot /etc/skel/.config/ || true && \
    cp -a /usr/share/omarchy/default/walker /etc/skel/.config/ || true && \
    cp -a /usr/share/omarchy/default/wayland-sessions/. /usr/share/wayland-sessions/ || true && \
    cp -a /usr/share/omarchy/themes /usr/share/omarchy-themes && \
    find /usr/share/omarchy/bin -type f -executable -exec ln -sf {} /usr/local/bin/ \;

RUN mkdir -p /etc/sudoers.d && \
    useradd -m -G wheel,seat crashbit && \
    echo 'crashbit:changeme' | chpasswd && \
    passwd -l root && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

RUN getent group sddm || groupadd -r sddm && \
    getent passwd sddm || useradd -r -g sddm -d /var/lib/sddm -s /usr/bin/nologin sddm && \
    mkdir -p /var/lib/sddm && \
    chown -R sddm:sddm /var/lib/sddm

RUN systemctl enable NetworkManager && \
    systemctl enable sddm

LABEL containers.bootc=1

RUN bootc container lint
