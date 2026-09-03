home := env_var("HOME")
src := justfile_directory()

export PATH := home + "/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl:" + home + "/.local/share/mise/shims"
export GOPATH := home

hypr_pkgs := "hyprland xdg-desktop-portal-hyprland hyprland-guiutils hyprland-qt-support hyprsunset hyprtoolkit hyprutils"

# AUR: xdg-desktop-portal-termfilechooser-hunkyburrito-git
wayland_pkgs := "wtype wl-clipboard swaylock-effects swayidle rofi qt6-wayland kitty egl-wayland cliphist greetd-regreet xdg-desktop-portal-termfilechooser-hunkyburrito-git xdg-desktop-portal-gtk dunst awww quickshell mate-polkit nwg-look"

# AUR: sway-scroll
scroll_pkgs := "sway-scroll xdg-desktop-portal-wlr"

nvidia_pkgs := "nvidia nvidia-prime nvidia-settings nvidia-utils cuda nvtop libva-nvidia-driver opencl-nvidia nvidia-container-toolkit"

laptop_intel_pkgs := "intel-gpu-tools intel-media-driver intel-ucode vulkan-intel"

# auto-cpufreq
laptop_amd_pkgs := "amd-ucode vulkan-radeon libva-mesa-driver radeontop"

laptop_pkgs := "thermald"

# zcfan
thinkpad_pkgs := "acpi_call throttled"

thinkpad_amd_pkgs := "acpi_call"

systemd_enable := "sudo systemctl --now enable"
systemd_enable_user := "systemctl --user --now enable"

# List available recipes
[private]
default:
    @just --list

# Install packages, routing each to pacman (repo) or paru (AUR)
[private]
install-pkgs *pkgs:
    #!/usr/bin/env bash
    set -eu
    pkgs="{{ pkgs }}"
    if [ -z "$pkgs" ]; then exit 0; fi
    sync_pkgs=$(pacman -Slq)
    repo_pkgs=""
    aur_pkgs=""
    for pkg in $pkgs; do
        if grep -qx "$pkg" <<<"$sync_pkgs"; then
            repo_pkgs="$repo_pkgs $pkg"
        else
            aur_pkgs="$aur_pkgs $pkg"
        fi
    done
    failed=""
    if [ -n "$repo_pkgs" ]; then
        echo "==> pacman:$repo_pkgs"
        if ! sudo pacman -S --needed --noconfirm $repo_pkgs; then
            echo "  ✗ Failed repo install"
            failed="$failed$repo_pkgs"
        fi
    fi
    for pkg in $aur_pkgs; do
        echo "==> paru (AUR): $pkg"
        if ! paru -S --needed --noconfirm "$pkg"; then
            echo "  ✗ Failed: $pkg"
            failed="$failed $pkg"
        fi
    done
    if [ -n "$failed" ]; then
        echo "==> WARNING: packages that failed:$failed"
    else
        echo "==> All packages installed successfully."
    fi

# Install makepkg.conf in /etc (optimized compilation)
[private]
makepkg-conf:
    sudo install -m 644 "{{ src }}/etc/makepkg.conf" /etc/makepkg.conf

# Ensure paru is installed and sync databases are fresh
[private]
bootstrap-paru:
    #!/usr/bin/env bash
    set -eu
    echo "==> Refreshing package databases..."
    sudo pacman -Sy
    echo "==> Installing paru if necessary..."
    sudo pacman -S --needed --noconfirm paru || { echo "Error installing paru"; exit 1; }

# Install official-repo packages from pkglist.txt
[private]
install-repo:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing official-repo packages from pkglist.txt..."
    pkgs=$(grep -v '^#' "{{ src }}/pkglist.txt" | grep -v '^$' || true)
    if [ -n "$pkgs" ]; then just install-pkgs $pkgs; fi

# Install AUR packages from pkglist-aur.txt
[private]
install-aur:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing AUR packages from pkglist-aur.txt..."
    pkgs=$(grep -v '^#' "{{ src }}/pkglist-aur.txt" | grep -v '^$' || true)
    if [ -n "$pkgs" ]; then just install-pkgs $pkgs; fi

# Apply base system configuration (keyd, sysctl, services)
[private]
system-config:
    #!/usr/bin/env bash
    set -eu
    echo "==> Enabling services..."
    {{ systemd_enable }} ananicy-cpp
    echo "==> Configuring keyd..."
    if [ -L /etc/keyd ]; then sudo rm /etc/keyd; fi
    if [ -d /etc/keyd ] && [ ! -L /etc/keyd ]; then sudo rm -rf /etc/keyd; fi
    sudo cp -r "{{ src }}/etc/keyd" /etc/
    echo "==> Configuring sysctl..."
    sudo cp "{{ src }}/etc/sysctl.d/99-sysctl.conf" /etc/sysctl.d/
    {{ systemd_enable }} keyd
    echo "==> Configuring bob (neovim version manager)..."
    command -v bob >/dev/null 2>&1 && bob use nightly || echo "bob not installed, skipping..."

# Install Arch Linux packages and apply base system configuration
install: makepkg-conf bootstrap-paru install-repo install-aur system-config nftables

# Deploy the initial dotfiles
init: theme systemd-user bin user-tools harness
    #!/usr/bin/env bash
    set -eu
    src_dir="{{ src }}"
    echo "==> Creating symlinks in the HOME directory"
    dotfiles=$(find "$src_dir" -mindepth 1 -maxdepth 1 -name ".*" \
        ! -name .git ! -name .gitignore ! -name .gitattributes \
        ! -name .gitmodules ! -name .claude ! -name .a5c ! -name .crush \
        -exec basename {} \;)
    configs=$(find "$src_dir/config" -mindepth 1 -maxdepth 1 \
        ! -name .gitignore ! -name systemd -exec basename {} \;)
    echo "==> Processing dotfiles..."
    for file in $dotfiles; do
        dst="$HOME/$file"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "WARNING: $file exists but is not a symlink. Back it up manually."
        else
            ln -vsfn "$src_dir/$file" "$dst"
        fi
    done
    echo "==> Processing configs..."
    mkdir -p "$HOME/.config"
    for config in $configs; do
        dst="$HOME/.config/$config"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "WARNING: $config exists but is not a symlink. Back it up manually."
        else
            ln -vsfn "$src_dir/config/$config" "$dst"
        fi
    done

# Remove symlinks created by init/bin/systemd-user/harness (only if they point into this repo)
rollback:
    #!/usr/bin/env bash
    set -eu
    src_dir="{{ src }}"
    echo "==> Removing home dotfile symlinks..."
    for file in $(find "$src_dir" -mindepth 1 -maxdepth 1 -name ".*" \
        ! -name .git ! -name .gitignore ! -name .gitattributes \
        ! -name .gitmodules ! -name .claude ! -name .a5c ! -name .crush \
        -exec basename {} \;); do
        dst="$HOME/$file"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then
            rm -v "$dst"
        fi
    done
    echo "==> Removing config symlinks..."
    for config in $(find "$src_dir/config" -mindepth 1 -maxdepth 1 \
        ! -name .gitignore ! -name systemd -exec basename {} \;); do
        dst="$HOME/.config/$config"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then
            rm -v "$dst"
        fi
    done
    echo "==> Removing local/bin symlinks..."
    for script in $(find "$src_dir/local/bin" -mindepth 1 -maxdepth 1 ! -name ".*" -exec basename {} \;); do
        dst="$HOME/.local/bin/$script"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then
            rm -v "$dst"
        fi
    done
    echo "==> Removing systemd user unit symlinks..."
    for unit in $(find "$src_dir/config/systemd/user" -maxdepth 1 -type f \
                    \( -name '*.service' -o -name '*.timer' -o -name '*.target' \) -exec basename {} \;); do
        dst="$HOME/.config/systemd/user/$unit"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then
            rm -v "$dst"
        fi
    done
    systemctl --user daemon-reload || true
    echo "==> Removing harness symlinks..."
    for f in APPEND_SYSTEM.md web-search.json zentui.json settings.json; do
        dst="$HOME/.pi/agent/$f"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then rm -v "$dst"; fi
    done
    for f in eyes-light.json eyes-dark.json; do
        dst="$HOME/.pi/agent/themes/$f"
        if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then rm -v "$dst"; fi
    done
    dst="$HOME/.claude/CLAUDE.md"
    if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then rm -v "$dst"; fi
    dst="$HOME/.config/opencode/opencode.json"
    if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then rm -v "$dst"; fi
    dst="$HOME/.config/opencode/themes/eyes.json"
    if [ -L "$dst" ] && readlink "$dst" | grep -q "^$src_dir"; then rm -v "$dst"; fi
    echo "==> Rollback complete."

# Apply the eyes theme (active symlinks + claude/opencode themes)
theme:
    @echo "==> Applying eyes theme (creates the gitignored active symlinks)..."
    @{{ src }}/.scripts/eyes-theme auto

# Link the local/bin scripts into ~/.local/bin
bin:
    #!/usr/bin/env bash
    set -eu
    echo "==> Linking scripts into ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    for script in $(find "{{ src }}/local/bin" -mindepth 1 -maxdepth 1 ! -name ".*" -exec basename {} \;); do
        ln -vsfn "{{ src }}/local/bin/$script" "$HOME/.local/bin/$script"
    done

# Install user-level tools sin AUR (cht.sh + tridactyl native messenger)
user-tools:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing cht.sh into ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://cht.sh/:cht.sh -o "$HOME/.local/bin/cht.sh"
    chmod +x "$HOME/.local/bin/cht.sh"
    echo "==> Installing Tridactyl native messenger (user-level, sin root)..."
    curl -fsSL https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh | sh

# Install the AI harness configs (pi, claude, opencode) + shared skills
harness:
    #!/usr/bin/env bash
    set -eu
    echo "==> pi (~/.pi/agent)..."
    mkdir -p "$HOME/.pi/agent"
    for f in APPEND_SYSTEM.md web-search.json zentui.json settings.json; do
        ln -vsfn "{{ src }}/harness/pi/$f" "$HOME/.pi/agent/$f"
    done
    mkdir -p "$HOME/.pi/agent/themes"
    for f in eyes-light.json eyes-dark.json; do
        ln -vsfn "{{ src }}/harness/pi/themes/$f" "$HOME/.pi/agent/themes/$f"
    done
    echo "==> claude (~/.claude)..."
    ln -vsfn "{{ src }}/harness/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    # eyes-theme rewrites settings.json on every theme switch (jq + mv): install a copy
    if [ -f "$HOME/.claude/settings.json" ] && [ ! -f "$HOME/.claude/settings.json.bak" ]; then
        cp -v "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
    fi
    install -m 644 "{{ src }}/harness/claude/settings.json" "$HOME/.claude/settings.json"
    if [ ! -f "$HOME/.claude/settings.local.json" ]; then
        cp -v "{{ src }}/harness/claude/settings.local.json.example" "$HOME/.claude/settings.local.json"
        echo "    WARNING: set your ANTHROPIC_AUTH_TOKEN in ~/.claude/settings.local.json"
    fi
    mkdir -p "$HOME/.claude/themes"
    for f in eyes.json eyes-dark.json; do
        ln -vsfn "{{ src }}/harness/claude/themes/$f" "$HOME/.claude/themes/$f"
    done
    echo "==> opencode (~/.config/opencode, enlaces por archivo)..."
    mkdir -p "$HOME/.config/opencode/themes"
    ln -vsfn "{{ src }}/harness/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
    ln -vsfn "{{ src }}/harness/opencode/themes/eyes.json" "$HOME/.config/opencode/themes/eyes.json"
    echo "==> herdr integrations (self-installed, skipped if herdr is absent)..."
    if command -v herdr >/dev/null 2>&1; then
        for agent in claude pi opencode; do
            herdr integration install "$agent"
        done
    fi

# Link the user unit files (eyes-theme*) and enable timers/boot
systemd-user:
    #!/usr/bin/env bash
    set -eu
    echo "==> Linking systemd --user units..."
    mkdir -p "$HOME/.config/systemd/user"
    for unit in $(find "{{ src }}/config/systemd/user" -maxdepth 1 -type f \
                    \( -name '*.service' -o -name '*.timer' -o -name '*.target' \) -exec basename {} \;); do
        dst="$HOME/.config/systemd/user/$unit"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "WARNING: $dst exists but is not a symlink. Back it up manually."
        else
            ln -vsfn "{{ src }}/config/systemd/user/$unit" "$dst"
        fi
    done
    systemctl --user daemon-reload
    {{ systemd_enable_user }} eyes-theme-boot.service eyes-theme-light.timer eyes-theme-dark.timer

# Install packages required for Wayland
wayland:
    #!/usr/bin/env bash
    set -eu
    echo "==> Configuring greetd..."
    sudo cp -r "{{ src }}/etc/greetd" /etc/
    echo "==> Enabling Electron/Chromium flags for Wayland..."
    "{{ src }}/wayland/enable-electron-flags.sh"
    echo "==> Installing Wayland packages..."
    just install-pkgs {{ wayland_pkgs }}
    {{ systemd_enable }} greetd

# Configure Hyprland (Wayland)
hypr: wayland
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing hypr-run script..."
    sudo install -m 755 "{{ src }}/wayland/scripts/hypr-run.sh" /usr/local/bin/
    echo "==> Installing Hyprland sessions..."
    sudo install -Dm 644 "{{ src }}/wayland/sessions/hyprland-crag.desktop" \
        /usr/share/wayland-sessions/hyprland-crag.desktop
    echo "==> Installing Hyprland packages..."
    just install-pkgs {{ hypr_pkgs }}

# Configure Scroll (Wayland)
scroll: wayland
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing scroll-run script..."
    sudo install -m 755 "{{ src }}/wayland/scripts/scroll-run.sh" /usr/local/bin/
    echo "==> Installing Scroll session..."
    sudo install -Dm 644 "{{ src }}/wayland/sessions/scroll-auto.desktop" \
        /usr/share/wayland-sessions/scroll-auto.desktop
    echo "==> Installing Scroll packages..."
    just install-pkgs {{ scroll_pkgs }}

# Configure suspend-on-lid (skipped when docked); idle lock/DPMS via swayidle
suspend:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing power-profile auto-switch udev rule..."
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-power-profile.rules" \
        /etc/udev/rules.d/99-power-profile.rules
    sudo udevadm control --reload || true
    echo "==> Configuring logind (suspend on lid, skipped when docked)..."
    sudo rm -f /etc/systemd/logind.conf.d/10-lid-battery.conf
    sudo install -Dm 644 "{{ src }}/etc/systemd/logind.conf.d/10-lid.conf" \
        /etc/systemd/logind.conf.d/10-lid.conf
    echo "==> Restarting systemd-logind to apply..."
    sudo systemctl restart systemd-logind || true

# Configure laptop (power management)
laptop: suspend
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing power management tools..."
    just install-pkgs {{ laptop_pkgs }}
    {{ systemd_enable }} thermald

# Configure Intel laptop (power management + Intel GPU)
laptop-intel: laptop
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing Intel GPU tools..."
    just install-pkgs {{ laptop_intel_pkgs }}

# Configure AMD laptop (power management + Radeon GPU)
laptop-amd: suspend
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing microcode, Radeon GPU and AMD power management..."
    just install-pkgs {{ laptop_amd_pkgs }}

# ThinkPad-specific configuration (Intel)
thinkpad: laptop
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing ThinkPad-specific tools..."
    just install-pkgs {{ thinkpad_pkgs }}
    echo "==> Installing P53-specific sysctl..."
    sudo install -m 644 "{{ src }}/etc/sysctl.d/99-p53.conf" /etc/sysctl.d/
    sudo sysctl --system
    echo "==> Installing battery charge threshold udev rule..."
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-battery-threshold.rules" \
        /etc/udev/rules.d/99-battery-threshold.rules
    sudo udevadm control --reload || true
    {{ systemd_enable }} throttled

# AMD ThinkPad configuration (e.g. L14 Gen 4)
thinkpad-amd: laptop-amd
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing ThinkPad-specific tools (AMD)..."
    just install-pkgs {{ thinkpad_amd_pkgs }}
    echo "==> Installing L14-specific sysctl..."
    sudo install -m 644 "{{ src }}/etc/sysctl.d/99-l14.conf" /etc/sysctl.d/
    sudo sysctl --system
    echo "==> Installing battery charge threshold udev rule..."
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-battery-threshold.rules" \
        /etc/udev/rules.d/99-battery-threshold.rules
    sudo udevadm control --reload || true

# Configure NVIDIA drivers (+ NVIDIA-only Scroll session)
nvidia:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing NVIDIA packages..."
    just install-pkgs {{ nvidia_pkgs }}
    echo "==> Installing NVIDIA-only Scroll session..."
    sudo install -Dm 644 "{{ src }}/wayland/sessions/scroll-nvidia.desktop" \
        /usr/share/wayland-sessions/scroll-nvidia.desktop

# Create the zen-browser "Inaoe" profile + install its .desktop launcher
inaoe:
    #!/usr/bin/env bash
    set -eu
    echo "==> Creating zen-browser profile 'Inaoe' (if missing)..."
    if grep -qs '^Name=Inaoe$' "$HOME/.config/zen/profiles.ini" 2>/dev/null; then
        echo "    Profile 'Inaoe' already exists, skipping..."
    else
        zen-browser -CreateProfile "Inaoe"
    fi
    echo "==> Configuring proxy for profile 'Inaoe'..."
    "{{ src }}/.scripts/configure_proxy.sh" "Inaoe"
    echo "==> Installing Inaoe icon + .desktop launcher..."
    install -Dm 644 "{{ src }}/local/applications/Inaoe.png" \
        "$HOME/.local/share/icons/hicolor/256x256/apps/Inaoe.png"
    mkdir -p "$HOME/.local/share/applications"
    ln -vsfn "{{ src }}/local/applications/Inaoe.desktop" "$HOME/.local/share/applications/Inaoe.desktop"
    gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# Configure unbound (local DNS resolver) + resolv.conf
unbound:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing unbound..."
    just install-pkgs unbound
    echo "==> Disabling systemd-resolved..."
    sudo systemctl disable --now systemd-resolved 2>/dev/null || true
    echo "==> Configuring resolv.conf..."
    if [ -L /etc/resolv.conf ]; then sudo rm -f /etc/resolv.conf; fi
    sudo install -m 644 "{{ src }}/etc/resolv.conf" /etc/resolv.conf
    echo "==> Configuring unbound.conf..."
    sudo install -Dm 644 "{{ src }}/etc/unbound/unbound.conf" /etc/unbound/unbound.conf
    echo "==> Fixing /etc/unbound ownership (unbound must write the trust anchor)..."
    sudo chown -R unbound:unbound /etc/unbound
    {{ systemd_enable }} unbound

# Configure NetworkManager (DNS + wifi backend)
networkmanager:
    #!/usr/bin/env bash
    set -eu
    echo "==> Configuring NetworkManager/conf.d..."
    sudo install -d -m 755 /etc/NetworkManager/conf.d
    sudo install -m 644 "{{ src }}/etc/NetworkManager/conf.d/"*.conf /etc/NetworkManager/conf.d/
    echo "==> Installing dynamic unbound-forward dispatcher hook..."
    sudo install -d -m 755 /etc/NetworkManager/dispatcher.d
    sudo install -o root -g root -m 755 "{{ src }}/etc/NetworkManager/dispatcher.d/90-unbound-forward" \
        /etc/NetworkManager/dispatcher.d/90-unbound-forward
    sudo install -d -o unbound -g unbound -m 755 /etc/unbound/forward.d
    echo "==> Probing the network now to pick DNS mode (recursión vs DoH) sin esperar a NM..."
    sudo /etc/NetworkManager/dispatcher.d/90-unbound-forward "" up || true
    echo "==> Reloading NetworkManager (skipped over SSH to avoid disconnection)..."
    if [ -z "${SSH_CONNECTION:-}" ]; then
        sudo systemctl reload NetworkManager || true
    else
        echo "    SSH detected: reload manually with 'sudo systemctl reload NetworkManager'"
    fi

# Install AND (re)load the nftables firewall (evita el config drift)
nftables:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing + (re)loading nftables..."
    sudo install -m 644 "{{ src }}/etc/nftables.conf" /etc/nftables.conf
    sudo nft -f /etc/nftables.conf
    {{ systemd_enable }} nftables

# P53: servidor SSH accesible solo por el tailnet (aplica firewall + habilita sshd)
ssh: nftables
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing openssh + habilitando sshd..."
    just install-pkgs openssh
    {{ systemd_enable }} sshd

# P53: servidor VNC del escritorio Wayland, solo por el tailnet (wayvnc <ip-tailscale>)
wayvnc: nftables
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing wayvnc..."
    just install-pkgs wayvnc

# L14: cliente VNC nativo Wayland para ver la P53 (AUR: wlvncc-git)
vncviewer:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing wlvncc (AUR)..."
    just install-pkgs wlvncc-git

# Configure dnscrypt-proxy (DoH/443 egress for networks that block 53)
dnscrypt:
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing dnscrypt-proxy..."
    just install-pkgs dnscrypt-proxy
    echo "==> Configuring dnscrypt-proxy.toml..."
    sudo install -Dm 644 "{{ src }}/etc/dnscrypt-proxy/dnscrypt-proxy.toml" \
        /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    echo "==> Enabling dnscrypt-proxy (first start should be at home to cache the resolver list)..."
    {{ systemd_enable }} dnscrypt-proxy

# Configure the whole local DNS stack (unbound + dnscrypt + NM)
dns: unbound dnscrypt networkmanager

# Install Tailscale + unirse al tailnet (base para P53 y L14)
tailscale: nftables
    #!/usr/bin/env bash
    set -eu
    echo "==> Installing tailscale..."
    just install-pkgs tailscale
    {{ systemd_enable }} tailscaled
    echo "==> Uniendo al tailnet (--accept-dns=false: NO tocar resolv.conf, usamos unbound local)..."
    sudo tailscale up --accept-dns=false

# Build the Podman image for testing
podman-image:
    podman build -t dotfiles "{{ src }}"

# Test the justfile with Podman
test: podman-image
    #!/usr/bin/env bash
    set -eu
    echo "==> Starting test container..."
    podman run -it --name maketest -d dotfiles:latest /bin/bash || true
    for target in install init wayland hypr thinkpad; do
        echo "==> Testing recipe: $target"
        podman exec -it maketest sh -c "cd {{ src }}; just $target"
    done
    echo "==> Cleaning up test container..."
    podman stop maketest && podman rm maketest || true

# Show the PATH and GOPATH variables
testpath:
    @echo "PATH: $PATH"
    @echo "GOPATH: {{ GOPATH }}"

# Clean up test containers
clean:
    @podman stop maketest 2>/dev/null || true
    @podman rm maketest 2>/dev/null || true

# Install for ThinkPad P53 with NVIDIA (server SSH + wayvnc)
p53: install init thinkpad nvidia ssh wayvnc

# Install for ThinkPad L14 Gen 4 (Ryzen 5, + client VNC)
l14: install init thinkpad-amd vncviewer
