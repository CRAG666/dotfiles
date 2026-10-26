set default-list
set script-interpreter := ['bash', '-euo', 'pipefail']

home := home_directory()
src := justfile_directory()

export PATH := home + "/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl:" + home + "/.local/share/mise/shims:" + env("PREFIX", "/usr") + "/bin"
export GOPATH := home

hypr_pkgs := "hyprland xdg-desktop-portal-hyprland hyprland-guiutils hyprland-qt-support hyprsunset hyprtoolkit hyprutils"

# AUR: xdg-desktop-portal-termfilechooser-hunkyburrito-git
wayland_pkgs := "wtype wl-clipboard swayidle qt6-wayland ghostty cliphist xdg-desktop-portal-termfilechooser-hunkyburrito-git xdg-desktop-portal-gtk libnotify awww quickshell"

# AUR: sway-scroll
scroll_pkgs := "sway-scroll xdg-desktop-portal-wlr"

nvidia_pkgs := "nvidia egl-wayland nvidia-prime nvidia-settings nvidia-utils cuda nvtop libva-nvidia-driver opencl-nvidia nvidia-container-toolkit"

laptop_intel_pkgs := "intel-gpu-tools intel-media-driver intel-ucode vulkan-intel"

# auto-cpufreq
laptop_amd_pkgs := "amd-ucode vulkan-radeon libva-mesa-driver"

laptop_pkgs := "thermald"

# zcfan
p53_pkgs := "throttled"

p53_firmware := "linux-firmware-intel linux-firmware-nvidia linux-firmware-realtek linux-firmware-other linux-firmware-whence"

l14_firmware := "linux-firmware-amd linux-firmware-amdgpu linux-firmware-mediatek linux-firmware-realtek linux-firmware-other linux-firmware-whence"

systemd_enable := "sudo systemctl --now enable"
systemd_enable_user := "systemctl --user --now enable"

# Install packages, routing each to pacman (repo) or paru (AUR)
[private]
[script]
install-pkgs *pkgs:
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
        if sudo pacman -S --needed --noconfirm $repo_pkgs; then
            sudo pacman -D --asexplicit $repo_pkgs >/dev/null
        else
            echo "  ✗ Failed repo install"
            failed="$failed$repo_pkgs"
        fi
    fi
    for pkg in $aur_pkgs; do
        echo "==> paru (AUR): $pkg"
        if paru -S --needed --noconfirm "$pkg"; then
            sudo pacman -D --asexplicit "$pkg" >/dev/null
        else
            echo "  ✗ Failed: $pkg"
            failed="$failed $pkg"
        fi
    done
    if [ -n "$failed" ]; then
        echo "==> Packages that failed:$failed" >&2
        exit 1
    fi
    echo "==> All packages installed successfully."

# Install the makepkg drop-in that builds packages for the native CPU
[private]
makepkg-conf:
    sudo install -Dm 644 "{{ src }}/etc/makepkg.conf.d/zz-native.conf" /etc/makepkg.conf.d/zz-native.conf

# Install the fontconfig rule that repairs the Apple fonts' family names
[group('base')]
fonts:
    sudo install -Dm 644 "{{ src }}/etc/fonts/conf.d/50-apple-family-names.conf" /etc/fonts/conf.d/50-apple-family-names.conf
    sudo fc-cache -fs

# Ensure paru is installed and sync databases are fresh
[private]
[script]
bootstrap-paru:
    echo "==> Upgrading the system (Arch does not support partial upgrades)..."
    sudo pacman -Syu --noconfirm
    echo "==> Installing paru if necessary..."
    sudo pacman -S --needed --noconfirm paru || { echo "Error installing paru"; exit 1; }

# Install official-repo packages from pkglist.txt
[private]
[script]
install-repo:
    echo "==> Installing official-repo packages from pkglist.txt..."
    pkgs=$(grep -v '^#' "{{ src }}/pkglist.txt" | grep -v '^$' || true)
    if [ -n "$pkgs" ]; then just install-pkgs $pkgs; fi

# Install AUR packages from pkglist-aur.txt
[private]
[script]
install-aur:
    echo "==> Installing AUR packages from pkglist-aur.txt..."
    pkgs=$(grep -v '^#' "{{ src }}/pkglist-aur.txt" | grep -v '^$' || true)
    if [ -n "$pkgs" ]; then just install-pkgs $pkgs; fi

# Apply base system configuration (keyd, sysctl, services)
[private]
[script]
system-config:
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
[group('base')]
install: makepkg-conf bootstrap-paru install-repo install-aur fonts system-config nftables

# Run Stow with ACTION on link groups: home, config, bin, data, systemd, harness, termux
[private]
[script]
stow action +groups:
    pkg() { mkdir -p "$2"; stow {{ action }} --dir="$1" --target="$2" "${@:3}"; }
    for group in {{ groups }}; do
        echo "==> stow {{ action }} $group..."
        case "$group" in
            home) pkg "{{ src }}" "$HOME" home ;;
            config) pkg "{{ src }}" "$HOME/.config" config ;;
            bin) pkg "{{ src }}/local" "$HOME/.local/bin" bin ;;
            data) pkg "{{ src }}/local" "$HOME/.local/share" share ;;
            systemd) pkg "{{ src }}/config/systemd" "$HOME/.config/systemd/user" --no-folding user ;;
            harness)
                pkg "{{ src }}/harness" "$HOME/.pi/agent" --no-folding pi
                pkg "{{ src }}/harness" "$HOME/.config/opencode" --no-folding opencode
                pkg "{{ src }}/harness" "$HOME/.claude" --no-folding claude ;;
            termux) pkg "{{ src }}" "$HOME/.termux" termux ;;
            *)
                echo "Unknown link group: $group" >&2
                exit 1 ;;
        esac
    done

# Show the links Stow would add in every link group and any conflict, without touching HOME
[group('base')]
status: (stow "--simulate --verbose" "home config bin data systemd harness")

# Relink every group, e.g. after a git pull (Stow aborts without changes on a conflict), and reload the user units
[group('base')]
link: (stow "--restow" "home config bin data systemd harness")
    systemctl --user daemon-reload

# Deploy the initial dotfiles
[group('base')]
init: theme link systemd-user user-tools uosc mpv-assets harness

# Remove the links Stow created for link/init
[group('base')]
[script]
rollback: (stow "--delete" "home config bin data systemd harness")
    systemctl --user daemon-reload || true
    dst="$HOME/.pi/agent/themes/eyes.json"
    if [ -f "$dst" ]; then rm -v "$dst"; fi
    echo "==> Rollback complete."

# Apply the eyes theme (active symlinks + claude/opencode themes)
[group('base')]
theme:
    @echo "==> Applying eyes theme (creates the gitignored active symlinks)..."
    @{{ src }}/local/bin/eyes-theme auto

# Install user-level tools without AUR (cht.sh + tridactyl native messenger)
[group('base')]
[script]
user-tools:
    echo "==> Installing cht.sh into ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://raw.githubusercontent.com/chubin/cheat.sh/master/share/cht.sh.txt -o "$HOME/.local/bin/cht.sh"
    chmod +x "$HOME/.local/bin/cht.sh"
    echo "==> Installing Tridactyl native messenger (user-level, no root)..."
    curl -fsSL https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh | sh

# Install or update uosc (mpv UI) to its latest release in the gitignored config/mpv/{scripts/uosc,fonts}
[group('apps')]
[script]
uosc:
    main="{{ src }}/config/mpv/scripts/uosc/main.lua"
    release=$(curl -fsSL https://api.github.com/repos/tomasklaen/uosc/releases/latest)
    latest=$(jq -er .tag_name <<<"$release")
    installed=none
    if [ -f "$main" ]; then
        installed=$(sed -n "s/^local uosc_version = '\(.*\)'$/\1/p" "$main")
    fi
    if [ "$installed" = "$latest" ]; then
        echo "==> uosc $latest is already the latest release"
        exit 0
    fi
    echo "==> Installing uosc $latest (installed: $installed)..."
    asset=$(jq -ec '.assets[] | select(.name == "uosc.zip")' <<<"$release")
    url=$(jq -er .browser_download_url <<<"$asset")
    sha256=$(jq -er '.digest | ltrimstr("sha256:")' <<<"$asset")
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/uosc.zip" "$url"
    echo "$sha256  $tmp/uosc.zip" | sha256sum -c --quiet
    rm -rf "{{ src }}/config/mpv/scripts/uosc"
    bsdtar -xf "$tmp/uosc.zip" -C "{{ src }}/config/mpv" \
        --exclude 'scripts/uosc/bin/ziggy-darwin' --exclude 'scripts/uosc/bin/ziggy-windows.exe'

# Install or update the mpv shaders and thumbfast from upstream into the gitignored config/mpv/{shaders,scripts}
[group('apps')]
[script]
mpv-assets:
    mpv="{{ src }}/config/mpv"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    mkdir "$tmp/shaders"
    release_assets() {
        curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
            | jq -er --arg pattern "$2" '.assets[] | select(.name | test($pattern)) | .browser_download_url'
    }
    echo "==> Downloading Anime4K and FSRCNNX (latest releases)..."
    anime4k=$(release_assets bloc97/Anime4K '\.zip$')
    curl -fsSL -o "$tmp/anime4k.zip" "$anime4k"
    bsdtar -xf "$tmp/anime4k.zip" -C "$tmp/shaders"
    fsrcnnx=$(release_assets igv/FSRCNN-TensorFlow '^FSRCNNX_.*\.glsl$')
    for url in $fsrcnnx; do
        curl -fsSL -o "$tmp/shaders/${url##*/}" "$url"
    done
    echo "==> Downloading nnedi3, CAS, FSR, NVScaler, KrigBilateral and SSimDownscaler (default branches/gists)..."
    for url in \
        https://raw.githubusercontent.com/bjin/mpv-prescalers/master/nnedi3-nns{16,32,64,128,256}-win8x6.hook \
        https://gist.githubusercontent.com/agyild/bbb4e58298b2f86aa24da3032a0d2ee6/raw/CAS-scaled.glsl \
        https://gist.githubusercontent.com/agyild/82219c545228d70c5604f865ce0b0ce5/raw/FSR.glsl \
        https://gist.githubusercontent.com/agyild/7e8951915b2bf24526a9343d951db214/raw/NVScaler.glsl \
        https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/KrigBilateral.glsl \
        https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/SSimDownscaler.glsl; do
        curl -fsSL -o "$tmp/shaders/${url##*/}" "$url"
    done
    echo "==> Downloading thumbfast (default branch)..."
    curl -fsSL -o "$tmp/thumbfast.lua" https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua
    mkdir -p "$mpv/shaders" "$mpv/scripts"
    cp "$tmp"/shaders/* "$mpv/shaders/"
    cp "$tmp/thumbfast.lua" "$mpv/scripts/"

# Install the AI harness configs (pi, claude, opencode) + shared skills
[group('base')]
[script]
harness: (stow "--restow" "harness")
    # eyes-theme and pi rewrite settings.json with an atomic replace, which turns a link into a file: install copies
    for settings in "$HOME/.claude/settings.json" "$HOME/.pi/agent/settings.json"; do
        if [ -f "$settings" ] && [ ! -L "$settings" ] && [ ! -f "$settings.bak" ]; then
            cp -v "$settings" "$settings.bak"
        fi
    done
    install -m 644 "{{ src }}/harness/claude/settings.json" "$HOME/.claude/settings.json"
    install -m 644 "{{ src }}/harness/pi/settings.json" "$HOME/.pi/agent/settings.json"
    if [ ! -f "$HOME/.claude/settings.local.json" ]; then
        cp -v "{{ src }}/harness/claude/settings.local.json.example" "$HOME/.claude/settings.local.json"
        echo "    WARNING: set your ANTHROPIC_AUTH_TOKEN in ~/.claude/settings.local.json"
    fi
    echo "==> herdr integrations (self-installed, skipped if herdr is absent)..."
    if command -v herdr >/dev/null 2>&1; then
        for agent in claude pi opencode; do
            herdr integration install "$agent"
        done
    fi

# Link the user unit files (eyes-theme*) and enable timers/boot
[group('base')]
systemd-user: (stow "--restow" "systemd")
    systemctl --user daemon-reload
    {{ systemd_enable_user }} eyes-theme.service eyes-theme.timer

# Two-way sync ~/Documents/Org with Google Drive seconds after either side changes; Org is not shared over Syncthing; resyncs only on first run or after a critical error
[group('apps')]
org-bisync: (stow "--restow" "systemd bin") (install-pkgs "inotify-tools")
    test -e ~/.cache/rclone/bisync/*_Documents_Org..Drive_Org.path1.lst || rclone bisync "$HOME/Documents/Org" Drive:/Org --resync --resync-mode newer --check-access --check-filename .rclone-check --create-empty-src-dirs --disable ListR --drive-skip-gdocs --exclude ".st**" --exclude ".syncthing.*"
    systemctl --user daemon-reload
    {{ systemd_enable_user }} org-bisync.timer org-watch.service

# Install greetd and the Quickshell greeter from etc/greetd (applies on the next boot)
[group('desktop')]
[script]
greetd: (install-pkgs "greetd quickshell")
    echo "==> Configuring greetd..."
    sudo cp -r "{{ src }}/etc/greetd" /etc/
    sudo install -m 644 "{{ src }}"/config/quickshell/{Theme,WText,DateBlock}.qml /etc/greetd/quickshell/
    sudo install -d -o greeter -g greeter /var/lib/qs-greeter
    {{ systemd_enable }} greetd

# Install packages required for Wayland
[group('desktop')]
[script]
wayland: greetd (install-pkgs wayland_pkgs)
    echo "==> Enabling Electron/Chromium flags for Wayland..."
    "{{ src }}/wayland/enable-electron-flags.sh"
    {{ systemd_enable_user }} app-com.mitchellh.ghostty.service

# Configure Hyprland (Wayland)
[group('desktop')]
[script]
hypr: wayland (install-pkgs hypr_pkgs)
    echo "==> Installing hypr-run script..."
    sudo install -m 755 "{{ src }}/wayland/scripts/hypr-run.sh" /usr/local/bin/
    echo "==> Installing Hyprland sessions..."
    sudo install -Dm 644 "{{ src }}/wayland/sessions/hyprland-crag.desktop" \
        /usr/share/wayland-sessions/hyprland-crag.desktop

# Configure Scroll (Wayland)
[group('desktop')]
[script]
scroll: wayland (install-pkgs scroll_pkgs)
    echo "==> Installing scroll-run script..."
    sudo install -m 755 "{{ src }}/wayland/scripts/scroll-run.sh" /usr/local/bin/
    echo "==> Installing Scroll session..."
    sudo install -Dm 644 "{{ src }}/wayland/sessions/scroll-auto.desktop" \
        /usr/share/wayland-sessions/scroll-auto.desktop

# Configure suspend-on-lid (skipped when docked); idle lock/DPMS via swayidle
[group('hardware')]
[script]
suspend:
    echo "==> Installing power-profile auto-switch udev rule..."
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-power-profile.rules" \
        /etc/udev/rules.d/99-power-profile.rules
    sudo udevadm control --reload || true
    sudo udevadm trigger --subsystem-match=power_supply --action=change
    echo "==> Configuring logind (suspend on lid, skipped when docked)..."
    sudo rm -f /etc/systemd/logind.conf.d/10-lid-battery.conf
    sudo install -Dm 644 "{{ src }}/etc/systemd/logind.conf.d/10-lid.conf" \
        /etc/systemd/logind.conf.d/10-lid.conf
    echo "==> Restarting systemd-logind to apply..."
    sudo systemctl restart systemd-logind || true

# Configure laptop (power management)
[group('hardware')]
laptop: suspend (install-pkgs laptop_pkgs)
    {{ systemd_enable }} thermald

# Configure Intel laptop (power management + Intel GPU)
[group('hardware')]
laptop-intel: laptop (install-pkgs laptop_intel_pkgs)

# Configure AMD laptop (power management + Radeon GPU)
[group('hardware')]
laptop-amd: suspend (install-pkgs laptop_amd_pkgs)

# ThinkPad configuration shared by the P53 and the L14: battery charge threshold + mic-mute LED
[group('hardware')]
[script]
thinkpad:
    echo "==> Installing battery charge threshold and mic-mute LED udev rules..."
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-battery-threshold.rules" \
        /etc/udev/rules.d/99-battery-threshold.rules
    sudo install -Dm 644 "{{ src }}/etc/udev/rules.d/99-micmute-led.rules" \
        /etc/udev/rules.d/99-micmute-led.rules
    sudo udevadm control --reload || true
    sudo udevadm trigger --subsystem-match=leds --sysname-match=platform::micmute --action=add

# Configure NVIDIA drivers (+ NVIDIA-only Scroll session)
[group('hardware')]
nvidia: (install-pkgs nvidia_pkgs)
    sudo install -Dm 644 "{{ src }}/wayland/sessions/scroll-nvidia.desktop" /usr/share/wayland-sessions/scroll-nvidia.desktop

# Create the zen-browser "Inaoe" profile, apply zen/inaoe.json + install its .desktop launcher
[group('apps')]
[script]
inaoe:
    echo "==> Creating zen-browser profile 'Inaoe' (if missing)..."
    if grep -qs '^Name=Inaoe$' "$HOME/.config/zen/profiles.ini" 2>/dev/null; then
        echo "    Profile 'Inaoe' already exists, skipping..."
    else
        zen-browser -CreateProfile "Inaoe"
    fi
    echo "==> Configuring proxy for profile 'Inaoe'..."
    "{{ src }}/home/.scripts/configure_proxy.sh" "Inaoe"
    echo "==> Applying its essentials + pinned tabs..."
    just zen-layout Inaoe inaoe
    echo "==> Installing Inaoe icon + .desktop launcher..."
    install -Dm 644 "{{ src }}/local/applications/Inaoe.png" \
        "$HOME/.local/share/icons/hicolor/256x256/apps/Inaoe.png"
    mkdir -p "$HOME/.local/share/applications"
    ln -vsfn "{{ src }}/local/applications/Inaoe.desktop" "$HOME/.local/share/applications/Inaoe.desktop"
    gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# Apply zen/default.json (spaces, essentials, pinned tabs) + the eyes userChrome.css to the default Zen profile
[group('apps')]
zen: (zen-layout "Default (release)" "default")

# Apply zen/<layout>.json, zen/userChrome.css and its prefs to a Zen profile (Zen must be closed)
[private]
zen-layout profile layout:
    python3 -c "import lz4" 2>/dev/null || just install-pkgs python-lz4
    "{{ src }}/home/.scripts/zen_layout.py" "{{ profile }}" "{{ src }}/zen/{{ layout }}.json"

# Configure unbound (local DNS resolver) + resolv.conf
[group('network')]
[script]
unbound: (install-pkgs "unbound")
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

# Configure networking: iwd (wifi + DHCP) + systemd-networkd (cable) + DNS egress probe
[group('network')]
[script]
network: (install-pkgs "iwd impala")
    echo "==> Configuring iwd (own DHCP, leaves resolv.conf alone)..."
    sudo install -Dm 644 "{{ src }}/etc/iwd/main.conf" /etc/iwd/main.conf
    echo "==> Configuring systemd-networkd for wired interfaces..."
    sudo install -Dm 644 "{{ src }}/etc/systemd/network/20-wired.network" /etc/systemd/network/20-wired.network
    echo "==> Masking systemd-networkd-wait-online (it blocks boot without a cable)..."
    sudo systemctl mask systemd-networkd-wait-online.service
    echo "==> Installing unbound-forward probe + service..."
    sudo install -Dm 755 "{{ src }}/etc/unbound/unbound-forward" /usr/local/bin/unbound-forward
    sudo install -m 644 "{{ src }}/etc/systemd/system/unbound-forward.service" /etc/systemd/system/
    sudo install -d -o unbound -g unbound -m 755 /etc/unbound/forward.d
    sudo rm -f /etc/NetworkManager/conf.d/{dns,wifi_backend}.conf /etc/NetworkManager/dispatcher.d/90-unbound-forward
    sudo systemctl daemon-reload
    {{ systemd_enable }} unbound-forward.service
    echo "==> Switching from NetworkManager to iwd + systemd-networkd (skipped over SSH)..."
    if [ -z "${SSH_CONNECTION:-}" ]; then
        sudo systemctl disable --now NetworkManager 2>/dev/null || true
        sudo pacman -Rns --noconfirm networkmanager
        sudo systemctl unmask NetworkManager-wait-online.service
        sudo systemctl enable systemd-networkd iwd
        sudo systemctl restart systemd-networkd iwd
    else
        echo "    SSH detected: run 'sudo systemctl disable --now NetworkManager && sudo systemctl enable --now systemd-networkd iwd' locally"
    fi

# Install AND (re)load the nftables firewall (avoids config drift)
[group('network')]
nftables:
    sudo install -m 644 "{{ src }}/etc/nftables.conf" /etc/nftables.conf
    sudo nft -f /etc/nftables.conf
    {{ systemd_enable }} nftables

# P53: SSH server reachable only over the tailnet (applies firewall + enables sshd)
[group('network')]
ssh: nftables (install-pkgs "openssh")
    {{ systemd_enable }} sshd

# P53: Sunshine stream host for the desktop, only over the tailnet (pair at https://<tailscale-ip>:47990)
[group('apps')]
[script]
sunshine: nftables (install-pkgs "sunshine")
    echo "==> Linking config/sunshine (replaces a ~/.config/sunshine that is not a symlink) and the drop-in that waits for /dev/uinput (else no mouse after boot)..."
    dst="$HOME/.config/sunshine"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        rm -rf "$dst"
    fi
    just stow --restow config systemd
    echo "==> Installing the sudoers rule that lets Sunshine lock the GPU clocks while streaming..."
    sudo visudo -cf "{{ src }}/etc/sudoers.d/sunshine-gpu-clocks"
    sudo install -m 440 "{{ src }}/etc/sudoers.d/sunshine-gpu-clocks" /etc/sudoers.d/
    systemctl --user daemon-reload
    echo "==> Enabling its user service (starts with graphical-session.target)..."
    {{ systemd_enable_user }} app-dev.lizardbyte.app.Sunshine.service

# L14: Moonlight client to stream the P53 desktop + its streaming settings
[group('apps')]
[script]
moonlight:
    if pgrep -x moonlight >/dev/null; then
        echo "Close Moonlight first: it rewrites its settings on exit" >&2
        exit 1
    fi
    just install-pkgs moonlight-qt
    # Moonlight.conf also holds the pairing key and certificate, so only the settings are merged in
    echo "==> Merging config/moonlight/Moonlight.conf into Moonlight's settings..."
    conf="$HOME/.config/Moonlight Game Streaming Project/Moonlight.conf"
    if [ ! -f "$conf" ]; then
        install -Dm 644 "{{ src }}/config/moonlight/Moonlight.conf" "$conf"
        exit 0
    fi
    grep -q '^\[General\]$' "$conf" || printf '[General]\n' >>"$conf"
    grep -v '^\[' "{{ src }}/config/moonlight/Moonlight.conf" | while IFS='=' read -r name value; do
        if grep -q "^$name=" "$conf"; then
            sed -i "s|^$name=.*|$name=$value|" "$conf"
        else
            sed -i "/^\[General\]$/a $name=$value" "$conf"
        fi
    done

# Configure dnscrypt-proxy (DoH/443 egress for networks that block 53)
[group('network')]
[script]
dnscrypt: (install-pkgs "dnscrypt-proxy")
    echo "==> Configuring dnscrypt-proxy.toml..."
    sudo install -Dm 644 "{{ src }}/etc/dnscrypt-proxy/dnscrypt-proxy.toml" \
        /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    echo "==> Enabling dnscrypt-proxy (first start should be at home to cache the resolver list)..."
    {{ systemd_enable }} dnscrypt-proxy

# Configure the whole local DNS stack (unbound + dnscrypt + network)
[group('network')]
dns: unbound dnscrypt network

# Install Tailscale + join the tailnet (base for P53 and L14)
[group('network')]
[script]
tailscale: nftables (install-pkgs "tailscale")
    {{ systemd_enable }} tailscaled
    echo "==> Joining the tailnet (--accept-dns=false: resolv.conf stays on the local unbound)..."
    sudo tailscale up --accept-dns=false

# Build the Podman image for testing
[group('test')]
podman-image:
    podman build -t dotfiles "{{ src }}"

# Test the justfile with Podman
[group('test')]
[script]
test: podman-image
    echo "==> Starting test container..."
    podman run -it --name maketest -d dotfiles:latest /bin/bash || true
    for target in install init wayland hypr thinkpad; do
        echo "==> Testing recipe: $target"
        podman exec -it maketest sh -c "cd {{ src }}; just $target"
    done
    echo "==> Cleaning up test container..."
    podman stop maketest && podman rm maketest || true

# Show the PATH and GOPATH variables
[group('test')]
testpath:
    @echo "PATH: $PATH"
    @echo "GOPATH: {{ GOPATH }}"

# Clean up test containers
[group('test')]
clean:
    @podman stop maketest 2>/dev/null || true
    @podman rm maketest 2>/dev/null || true

# Keep only the given firmware (marked explicit) and drop the linux-firmware meta with the rest
[private]
[script]
firmware *pkgs: (install-pkgs pkgs)
    if pacman -Q linux-firmware >/dev/null 2>&1; then
        echo "==> Removing the linux-firmware meta and the firmware this machine does not use..."
        sudo pacman -Rns --noconfirm linux-firmware
    fi

# Install for ThinkPad P53 with NVIDIA (server SSH + Sunshine)
[group('machine')]
p53: install init laptop-intel thinkpad nvidia dns tailscale ssh sunshine (install-pkgs p53_pkgs) (firmware p53_firmware)
    sudo install -m 644 "{{ src }}/etc/sysctl.d/99-p53.conf" /etc/sysctl.d/
    sudo sysctl --system
    {{ systemd_enable }} throttled
    sudo install -Dm 644 "{{ src }}/etc/greetd/P53.png" /etc/greetd/laptop.png

# Install for ThinkPad L14 Gen 4 (Ryzen 5, + client Moonlight)
[group('machine')]
l14: install init laptop-amd thinkpad dns tailscale moonlight (firmware l14_firmware)
    sudo install -m 644 "{{ src }}/etc/sysctl.d/99-l14.conf" /etc/sysctl.d/
    sudo sysctl --system
    sudo install -Dm 644 "{{ src }}/etc/greetd/L14_Gen4.png" /etc/greetd/laptop.png

# Configure Termux on the Android phones: eyes colors by the hour + underline cursor
[group('machine')]
[script]
phone:
    pkg install -y stow
    just stow --restow termux
    ln -sfn "{{ src }}/termux/eyes-theme.sh" "$PREFIX/etc/profile.d/eyes-theme.sh"
    sh "{{ src }}/termux/eyes-theme.sh"
    termux-reload-settings
