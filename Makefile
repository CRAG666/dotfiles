export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

HYPR_PKGS := hyprland xdg-desktop-portal-hyprland hyprland-guiutils \
	     hyprland-qt-support hyprsunset hyprtoolkit hyprutils

WAYLAND_PKGS := wl-kbptr wlrctl wtype wl-clipboard swaylock-effects swayidle rofi qt6-wayland \
                kitty egl-wayland cliphist greetd-regreet \
                xdg-desktop-portal-termfilechooser-hunkyburrito-git \
                xdg-desktop-portal-gtk dunst awww quickshell \
		rofi-polkit-agent-git pinentry-rofi nwg-look

SCROLL_PKGS := sway-scroll xdg-desktop-portal-wlr

NVIDIA_PKGS := nvidia nvidia-prime nvidia-settings nvidia-utils cuda nvtop \
               libva-nvidia-driver opencl-nvidia nvtop nvidia-container-toolkit

LAPTOP_PKGS_INTEL := intel-gpu-tools intel-media-driver \
		     intel-ucode vulkan-intel

# auto-cpufreq
LAPTOP_PKGS_AMD := amd-ucode vulkan-radeon libva-mesa-driver radeontop

LAPTOP_PKGS := thermald

# zcfan
THINKPAD_PKGS := acpi_call throttled

THINKPAD_PKGS_AMD := acpi_call

# systemd commands
SYSTEMD_ENABLE := sudo systemctl --now enable
SYSTEMD_ENABLE_USER := systemctl --user --now enable

define install_pkgs
	@failed=""; \
	for pkg in $(1); do \
		echo "==> Installing $$pkg..."; \
		if ! paru -S --needed --noconfirm "$$pkg"; then \
			echo "  ✗ Failed: $$pkg"; \
			failed="$$failed $$pkg"; \
		fi; \
	done; \
	if [ -n "$$failed" ]; then \
		echo "==> WARNING: packages that failed:$$failed"; \
	else \
		echo "==> All packages installed successfully."; \
	fi
endef

.DEFAULT_GOAL := help
.PHONY: help install init theme bin makepkg systemd-user wayland hypr scroll \
        suspend laptop laptop-intel laptop-amd thinkpad thinkpad-amd nvidia inaoe unbound \
        networkmanager dns podman_image test testpath clean p53 l14

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: makepkg ## Install Arch Linux packages using paru
	@echo "==> Installing paru if necessary..."
	@sudo pacman -S --needed --noconfirm paru || { echo "Error installing paru"; exit 1; }
	@echo "==> Installing packages from pkglist.txt (one by one)..."
	$(call install_pkgs,$$(grep -v '^#' ${PWD}/pkglist.txt | grep -v '^$$'))
	@echo "==> Enabling services..."
	$(SYSTEMD_ENABLE) ananicy-cpp
	@echo "==> Configuring keyd..."
	@if [ -L /etc/keyd ]; then sudo rm /etc/keyd; fi
	@if [ -d /etc/keyd ] && [ ! -L /etc/keyd ]; then sudo rm -rf /etc/keyd; fi
	sudo cp -r ${PWD}/etc/keyd /etc/
	@echo "==> Configuring nftables..."
	@if [ -L /etc/nftables.conf ]; then sudo rm /etc/nftables.conf; fi
	sudo cp ${PWD}/etc/nftables.conf /etc/
	@echo "==> Configuring sysctl..."
	sudo cp ${PWD}/etc/sysctl.d/99-sysctl.conf /etc/sysctl.d/
	$(SYSTEMD_ENABLE) keyd nftables
	@echo "==> Configuring bob (neovim version manager)..."
	@command -v bob >/dev/null 2>&1 && bob use nightly || echo "bob not installed, skipping..."

init: theme systemd-user bin ## Deploy the initial dotfiles
	@echo "==> Creating symlinks in the HOME directory"
	@SRC_DIR=${PWD}; \
	DOTFILES=$$(find $$SRC_DIR -mindepth 1 -maxdepth 1 -name ".*" \
		! -name .git ! -name .gitignore ! -name .gitattributes \
		! -name .gitmodules ! -name .claude ! -name .a5c ! -name .crush \
		-exec basename {} \;); \
	CONFIGS=$$(find $$SRC_DIR/config -mindepth 1 -maxdepth 1 \
		! -name .gitignore ! -name systemd -exec basename {} \;); \
	echo "==> Processing dotfiles..."; \
	for file in $$DOTFILES; do \
		if [ -L "${HOME}/$$file" ]; then \
			echo "Link $$file already exists, skipping..."; \
		elif [ -e "${HOME}/$$file" ]; then \
			echo "WARNING: $$file exists but is not a symlink. Back it up manually."; \
		else \
			ln -vfs "$$SRC_DIR/$$file" "${HOME}/$$file"; \
		fi; \
	done; \
	echo "==> Processing configs..."; \
	mkdir -p "${HOME}/.config"; \
	for config in $$CONFIGS; do \
		if [ -L "${HOME}/.config/$$config" ]; then \
			echo "Link $$config already exists, skipping..."; \
		elif [ -e "${HOME}/.config/$$config" ]; then \
			echo "WARNING: $$config exists but is not a symlink. Back it up manually."; \
		else \
			ln -vfs "$$SRC_DIR/config/$$config" "${HOME}/.config/$$config"; \
		fi; \
	done

theme: ## Apply the eyes theme (active symlinks + claude/opencode themes)
	@echo "==> Applying eyes theme (creates the gitignored active symlinks)..."
	@${PWD}/.scripts/eyes-theme auto

bin: ## Link the local/bin scripts into ~/.local/bin
	@echo "==> Linking scripts into ~/.local/bin..."
	@mkdir -p ${HOME}/.local/bin
	@for script in $$(find ${PWD}/local/bin -mindepth 1 -maxdepth 1 ! -name ".*" -exec basename {} \;); do \
		ln -vsfn "${PWD}/local/bin/$$script" "${HOME}/.local/bin/$$script"; \
	done

makepkg: ## Install makepkg.conf in /etc (optimized compilation)
	sudo install -m 644 ${PWD}/etc/makepkg.conf /etc/makepkg.conf

systemd-user: ## Link the user unit files (eyes-theme*) and enable timers/boot
	@echo "==> Linking systemd --user units..."
	@mkdir -p ${HOME}/.config/systemd/user
	@for unit in $$(find ${PWD}/config/systemd/user -maxdepth 1 -type f \
	                \( -name '*.service' -o -name '*.timer' -o -name '*.target' \) -exec basename {} \;); do \
		dst="${HOME}/.config/systemd/user/$$unit"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
			echo "WARNING: $$dst exists but is not a symlink. Back it up manually."; \
		else \
			ln -vsfn "${PWD}/config/systemd/user/$$unit" "$$dst"; \
		fi; \
	done
	systemctl --user daemon-reload
	$(SYSTEMD_ENABLE_USER) eyes-theme-boot.service eyes-theme-light.timer eyes-theme-dark.timer

wayland: ## Install packages required for Wayland
	@echo "==> Configuring greetd..."
	sudo cp -r ${PWD}/etc/greetd /etc/
	@echo "==> Enabling Electron/Chromium flags for Wayland..."
	@${PWD}/wayland/enable-electron-flags.sh
	@echo "==> Installing Wayland packages..."
	$(call install_pkgs,$(WAYLAND_PKGS))
	$(SYSTEMD_ENABLE) greetd

hypr: wayland ## Configure Hyprland (Wayland)
	@echo "==> Installing hypr-run script..."
	sudo install -m 755 ${PWD}/wayland/scripts/hypr-run.sh /usr/local/bin/
	@echo "==> Installing Hyprland sessions..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/hyprland-crag.desktop \
		/usr/share/wayland-sessions/hyprland-crag.desktop
	@echo "==> Installing Hyprland packages..."
	$(call install_pkgs,$(HYPR_PKGS))

scroll: wayland ## Configure Scroll (Wayland)
	@echo "==> Installing scroll-run script..."
	sudo install -m 755 ${PWD}/wayland/scripts/scroll-run.sh /usr/local/bin/
	@echo "==> Installing Scroll session..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/scroll-auto.desktop \
		/usr/share/wayland-sessions/scroll-auto.desktop
	@echo "==> Installing Scroll packages..."
	$(call install_pkgs,$(SCROLL_PKGS))

suspend: ## Configure suspend-on-lid (battery only); idle lock/DPMS via swayidle
	@echo "==> Installing power-profile auto-switch udev rule..."
	sudo install -Dm 644 ${PWD}/etc/udev/rules.d/99-power-profile.rules \
		/etc/udev/rules.d/99-power-profile.rules
	@sudo udevadm control --reload || true
	@echo "==> Configuring logind (suspend on lid, battery only)..."
	sudo install -Dm 644 ${PWD}/etc/systemd/logind.conf.d/10-lid-battery.conf \
		/etc/systemd/logind.conf.d/10-lid-battery.conf
	@echo "==> Restarting systemd-logind to apply..."
	@sudo systemctl restart systemd-logind || true

laptop: suspend ## Configure laptop (power management)
	@echo "==> Installing power management tools..."
	$(call install_pkgs,$(LAPTOP_PKGS))
	$(SYSTEMD_ENABLE) thermald

laptop-intel: laptop ## Configure Intel laptop (power management + Intel GPU)
	@echo "==> Installing Intel GPU tools..."
	$(call install_pkgs,$(LAPTOP_PKGS_INTEL))

laptop-amd: suspend ## Configure AMD laptop (power management + Radeon GPU)
	@echo "==> Installing microcode, Radeon GPU and AMD power management..."
	$(call install_pkgs,$(LAPTOP_PKGS_AMD))

thinkpad: laptop ## ThinkPad-specific configuration (Intel)
	@echo "==> Installing ThinkPad-specific tools..."
	$(call install_pkgs,$(THINKPAD_PKGS))
	@echo "==> Installing P53-specific sysctl..."
	sudo install -m 644 ${PWD}/etc/sysctl.d/99-p53.conf /etc/sysctl.d/
	sudo sysctl --system
	$(SYSTEMD_ENABLE) throttled

thinkpad-amd: laptop-amd ## AMD ThinkPad configuration (e.g. L14 Gen 4)
	@echo "==> Installing ThinkPad-specific tools (AMD)..."
	$(call install_pkgs,$(THINKPAD_PKGS_AMD))
	@echo "==> Installing L14-specific sysctl..."
	sudo install -m 644 ${PWD}/etc/sysctl.d/99-l14.conf /etc/sysctl.d/
	sudo sysctl --system

nvidia: ## Configure NVIDIA drivers (+ NVIDIA-only Scroll session)
	@echo "==> Installing NVIDIA packages..."
	$(call install_pkgs,$(NVIDIA_PKGS))
	@echo "==> Installing NVIDIA-only Scroll session..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/scroll-nvidia.desktop \
		/usr/share/wayland-sessions/scroll-nvidia.desktop

inaoe: ## Create the zen-browser "Inaoe" profile + install its .desktop launcher
	@echo "==> Creating zen-browser profile 'Inaoe' (if missing)..."
	@if grep -qs '^Name=Inaoe$$' ${HOME}/.config/zen/profiles.ini 2>/dev/null; then \
		echo "    Profile 'Inaoe' already exists, skipping..."; \
	else \
		zen-browser -CreateProfile "Inaoe"; \
	fi
	@echo "==> Configuring proxy for profile 'Inaoe'..."
	@${PWD}/.scripts/configure_proxy.sh "Inaoe"
	@echo "==> Installing Inaoe icon + .desktop launcher..."
	install -Dm 644 ${PWD}/local/applications/Inaoe.png ${HOME}/.local/share/icons/hicolor/256x256/apps/Inaoe.png
	@mkdir -p ${HOME}/.local/share/applications
	ln -vsfn ${PWD}/local/applications/Inaoe.desktop ${HOME}/.local/share/applications/Inaoe.desktop
	@gtk-update-icon-cache -q ${HOME}/.local/share/icons/hicolor 2>/dev/null || true

unbound: ## Configure unbound (local DNS resolver) + resolv.conf
	@echo "==> Installing unbound..."
	$(call install_pkgs,unbound)
	@echo "==> Disabling systemd-resolved..."
	@sudo systemctl disable --now systemd-resolved 2>/dev/null || true
	@echo "==> Configuring resolv.conf..."
	@if [ -L /etc/resolv.conf ]; then sudo rm -f /etc/resolv.conf; fi
	sudo install -m 644 ${PWD}/etc/resolv.conf /etc/resolv.conf
	@echo "==> Configuring unbound.conf..."
	sudo install -Dm 644 ${PWD}/etc/unbound/unbound.conf /etc/unbound/unbound.conf
	@echo "==> Fixing /etc/unbound ownership (unbound must write the trust anchor)..."
	sudo chown -R unbound:unbound /etc/unbound
	$(SYSTEMD_ENABLE) unbound

networkmanager: ## Configure NetworkManager (DNS + wifi backend)
	@echo "==> Configuring NetworkManager/conf.d..."
	sudo install -d -m 755 /etc/NetworkManager/conf.d
	sudo install -m 644 ${PWD}/etc/NetworkManager/conf.d/*.conf /etc/NetworkManager/conf.d/
	@echo "==> Reloading NetworkManager (skipped over SSH to avoid disconnection)..."
	@if [ -z "$$SSH_CONNECTION" ]; then sudo systemctl reload NetworkManager || true; else echo "    SSH detected: reload manually with 'sudo systemctl reload NetworkManager'"; fi

dns: unbound networkmanager ## Configure the whole local DNS stack (unbound + NM)

podman_image: ## Build the Podman image for testing
	podman build -t dotfiles ${PWD}

test: podman_image ## Test the Makefile with Podman
	@echo "==> Starting test container..."
	podman run -it --name maketest -d dotfiles:latest /bin/bash || true
	@for target in install init wayland hypr thinkpad; do \
		echo "==> Testing target: $$target"; \
		podman exec -it maketest sh -c "cd ${PWD}; make $$target"; \
	done
	@echo "==> Cleaning up test container..."
	@podman stop maketest && podman rm maketest || true

testpath: ## Show the PATH and GOPATH variables
	@echo "PATH: $$PATH"
	@echo "GOPATH: $(GOPATH)"

clean: ## Clean up test containers
	@podman stop maketest 2>/dev/null || true
	@podman rm maketest 2>/dev/null || true

# Combined targets
p53: install init thinkpad nvidia ## Install for ThinkPad P53 with NVIDIA
l14: install init thinkpad-amd ## Install for ThinkPad L14 Gen 4 (Ryzen 5)
