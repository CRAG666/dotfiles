export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

# Packages organized by category
HYPR_PKGS := hyprland xdg-desktop-portal-hyprland hyprland-guiutils \
	     hyprland-qt-support hyprsunset hyprtoolkit hyprutils

WAYLAND_PKGS := wl-kbptr wlrctl wtype wl-clipboard swaylock-effects rofi qt6-wayland \
                imv kitty egl-wayland cliphist greetd-regreet \
                xdg-desktop-portal-termfilechooser-hunkyburrito-git \
                xdg-desktop-portal-gtk dunst awww quickshell \
		rofi-polkit-agent-git pinentry-rofi nwg-look

SCROLL_PKGS := sway-scroll xdg-desktop-portal-wlr

NVIDIA_PKGS := nvidia nvidia-prime nvidia-settings nvidia-utils cuda nvtop \
               libva-nvidia-driver opencl-nvidia nvtop nvidia-container-toolkit

LAPTOP_PKGS_INTEL := intel-gpu-tools intel-media-driver \
		     intel-ucode vulkan-intel
# AMD laptops: microcode, Radeon Vulkan/VA-API and GPU monitoring (auto-cpufreq
# works on AMD; thermald is excluded since it is Intel-only)
LAPTOP_PKGS_AMD := amd-ucode vulkan-radeon libva-mesa-driver radeontop \
		   auto-cpufreq
LAPTOP_PKGS := thermald auto-cpufreq

# Intel ThinkPads (throttled is the Intel-only Lenovo throttling fix)
THINKPAD_PKGS := zcfan acpi_call throttled
# AMD ThinkPads: no throttled (Intel-only)
THINKPAD_PKGS_AMD := zcfan acpi_call

# systemd commands
SYSTEMD_ENABLE := sudo systemctl --now enable
SYSTEMD_ENABLE_USER := systemctl --user --now enable

.DEFAULT_GOAL := help
.PHONY: help install init theme bin makepkg systemd-user wayland hypr scroll \
        laptop laptop-intel laptop-amd thinkpad thinkpad-amd nvidia unbound \
        networkmanager dns podman_image test testpath clean p53 l14

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install Arch Linux packages using paru
	@echo "==> Instalando paru si es necesario..."
	@sudo pacman -S --needed --noconfirm paru || { echo "Error instalando paru"; exit 1; }
	@echo "==> Instalando paquetes desde pkglist.txt..."
	@cat ${PWD}/pkglist.txt | grep -v "^#" | grep -v "^$$" | xargs -r paru -S --needed --noconfirm
	@echo "==> Habilitando servicios..."
	$(SYSTEMD_ENABLE) ananicy-cpp gopreload
	@echo "==> Configurando keyd..."
	@if [ -L /etc/keyd ]; then sudo rm /etc/keyd; fi
	@if [ -d /etc/keyd ] && [ ! -L /etc/keyd ]; then sudo rm -rf /etc/keyd; fi
	sudo cp -r ${PWD}/etc/keyd /etc/
	@echo "==> Configurando nftables..."
	@if [ -L /etc/nftables.conf ]; then sudo rm /etc/nftables.conf; fi
	sudo cp ${PWD}/etc/nftables.conf /etc/
	@echo "==> Configurando sysctl..."
	sudo cp ${PWD}/etc/sysctl.d/99-sysctl.conf /etc/sysctl.d/
	$(SYSTEMD_ENABLE) keyd nftables
	@echo "==> Configurando bob (neovim version manager)..."
	@command -v bob >/dev/null 2>&1 && bob use nightly || echo "bob no instalado, saltando..."

init: theme systemd-user bin ## Deploy the initial dotfiles
	@echo "==> Creando enlaces simbólicos en el directorio HOME"
	@SRC_DIR=${PWD}; \
	DOTFILES=$$(find $$SRC_DIR -mindepth 1 -maxdepth 1 -name ".*" \
		! -name .git ! -name .gitignore ! -name .gitattributes \
		! -name .gitmodules ! -name .claude ! -name .a5c ! -name .crush \
		-exec basename {} \;); \
	CONFIGS=$$(find $$SRC_DIR/config -mindepth 1 -maxdepth 1 \
		! -name .gitignore ! -name systemd -exec basename {} \;); \
	echo "==> Procesando dotfiles..."; \
	for file in $$DOTFILES; do \
		if [ -L "${HOME}/$$file" ]; then \
			echo "El enlace $$file ya existe, saltando..."; \
		elif [ -e "${HOME}/$$file" ]; then \
			echo "ADVERTENCIA: $$file existe pero no es un enlace simbólico. Haz backup manualmente."; \
		else \
			ln -vfs "$$SRC_DIR/$$file" "${HOME}/$$file"; \
		fi; \
	done; \
	echo "==> Procesando configs..."; \
	mkdir -p "${HOME}/.config"; \
	for config in $$CONFIGS; do \
		if [ -L "${HOME}/.config/$$config" ]; then \
			echo "El enlace $$config ya existe, saltando..."; \
		elif [ -e "${HOME}/.config/$$config" ]; then \
			echo "ADVERTENCIA: $$config existe pero no es un enlace simbólico. Haz backup manualmente."; \
		else \
			ln -vfs "$$SRC_DIR/config/$$config" "${HOME}/.config/$$config"; \
		fi; \
	done

theme: ## Apply the eyes theme (active symlinks + claude/opencode themes)
	@echo "==> Aplicando tema eyes (crea los symlinks activos gitignorados)..."
	@${PWD}/.scripts/eyes-theme auto

bin: ## Link the local/bin scripts into ~/.local/bin
	@echo "==> Enlazando scripts en ~/.local/bin..."
	@mkdir -p ${HOME}/.local/bin
	@for script in $$(find ${PWD}/local/bin -mindepth 1 -maxdepth 1 ! -name ".*" -exec basename {} \;); do \
		ln -vsfn "${PWD}/local/bin/$$script" "${HOME}/.local/bin/$$script"; \
	done

makepkg: ## Install makepkg.conf in /etc (optimized compilation)
	sudo install -m 644 ${PWD}/etc/makepkg.conf /etc/makepkg.conf

systemd-user: ## Link the user unit files (eyes-theme*) and enable timers/boot
	@echo "==> Enlazando units de systemd --user..."
	@mkdir -p ${HOME}/.config/systemd/user
	@for unit in $$(find ${PWD}/config/systemd/user -maxdepth 1 -type f \
	                \( -name '*.service' -o -name '*.timer' \) -exec basename {} \;); do \
		dst="${HOME}/.config/systemd/user/$$unit"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
			echo "ADVERTENCIA: $$dst existe pero no es un symlink. Haz backup manualmente."; \
		else \
			ln -vsfn "${PWD}/config/systemd/user/$$unit" "$$dst"; \
		fi; \
	done
	systemctl --user daemon-reload
	$(SYSTEMD_ENABLE_USER) eyes-theme-boot.service eyes-theme-light.timer eyes-theme-dark.timer

wayland: ## Install packages required for Wayland
	@echo "==> Configurando greetd..."
	sudo cp -r ${PWD}/etc/greetd /etc/
	@echo "==> Habilitando flags de Electron/Chromium para Wayland..."
	@${PWD}/wayland/enable-electron-flags.sh
	@echo "==> Instalando paquetes Wayland..."
	paru -S --needed --noconfirm $(WAYLAND_PKGS)
	$(SYSTEMD_ENABLE) greetd

hypr: wayland ## Configure Hyprland (Wayland)
	@echo "==> Instalando script hypr-run..."
	sudo install -m 755 ${PWD}/wayland/scripts/hypr-run.sh /usr/local/bin/
	@echo "==> Instalando sesiones de Hyprland..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/hyprland-crag.desktop \
		/usr/share/wayland-sessions/hyprland-crag.desktop
	@echo "==> Instalando paquetes Hyprland..."
	paru -S --needed --noconfirm $(HYPR_PKGS)

scroll: wayland ## Configure Scroll (Wayland)
	@echo "==> Instalando script scroll-run..."
	sudo install -m 755 ${PWD}/wayland/scripts/scroll-run.sh /usr/local/bin/
	@echo "==> Instalando sesión de Scroll..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/scroll-auto.desktop \
		/usr/share/wayland-sessions/scroll-auto.desktop
	@echo "==> Instalando paquetes Scroll..."
	paru -S --needed --noconfirm $(SCROLL_PKGS)

laptop: ## Configure laptop (power management)
	@echo "==> Instalando herramientas de gestión de energía..."
	paru -S --needed --noconfirm $(LAPTOP_PKGS)
	sudo cp ${PWD}/etc/auto-cpufreq.conf /etc/
	$(SYSTEMD_ENABLE) thermald auto-cpufreq

laptop-intel: laptop ## Configure Intel laptop (power management + Intel GPU)
	@echo "==> Instalando herramientas de gestión de energía..."
	paru -S --needed --noconfirm $(LAPTOP_PKGS_INTEL)

laptop-amd: ## Configure AMD laptop (power management + Radeon GPU)
	@echo "==> Instalando microcódigo, GPU Radeon y gestión de energía AMD..."
	paru -S --needed --noconfirm $(LAPTOP_PKGS_AMD)
	sudo cp ${PWD}/etc/auto-cpufreq.conf /etc/
	$(SYSTEMD_ENABLE) auto-cpufreq

thinkpad: laptop ## ThinkPad-specific configuration (Intel)
	@echo "==> Instalando herramientas específicas de ThinkPad..."
	paru -S --needed --noconfirm $(THINKPAD_PKGS)
	sudo install -m 644 ${PWD}/thinkpad/etc/zcfan.conf.p53 /etc/zcfan.conf
	@echo "==> Instalando sysctl específico de la P53..."
	sudo install -m 644 ${PWD}/etc/sysctl.d/99-p53.conf /etc/sysctl.d/
	sudo sysctl --system
	$(SYSTEMD_ENABLE) zcfan throttled

thinkpad-amd: laptop-amd ## AMD ThinkPad configuration (e.g. L14 Gen 4)
	@echo "==> Instalando herramientas específicas de ThinkPad (AMD)..."
	paru -S --needed --noconfirm $(THINKPAD_PKGS_AMD)
	sudo install -m 644 ${PWD}/thinkpad/etc/zcfan.conf.l14 /etc/zcfan.conf
	@echo "==> Instalando sysctl específico de la L14..."
	sudo install -m 644 ${PWD}/etc/sysctl.d/99-l14.conf /etc/sysctl.d/
	sudo sysctl --system
	$(SYSTEMD_ENABLE) zcfan

nvidia: ## Configure NVIDIA drivers (+ NVIDIA-only Scroll session)
	@echo "==> Instalando paquetes NVIDIA..."
	paru -S --needed --noconfirm $(NVIDIA_PKGS)
	@echo "==> Instalando sesión Scroll NVIDIA-only..."
	sudo install -Dm 644 ${PWD}/wayland/sessions/scroll-nvidia.desktop \
		/usr/share/wayland-sessions/scroll-nvidia.desktop

unbound: ## Configure unbound (local DNS resolver) + resolv.conf
	@echo "==> Instalando unbound..."
	paru -S --needed --noconfirm unbound
	@echo "==> Configurando resolv.conf..."
	@if [ -e /etc/resolv.conf ] || [ -L /etc/resolv.conf ]; then sudo rm -f /etc/resolv.conf; fi
	sudo ln -vsf ${PWD}/etc/resolv.conf /etc/resolv.conf
	@echo "==> Configurando unbound.conf..."
	sudo install -Dm 644 ${PWD}/etc/unbound/unbound.conf /etc/unbound/unbound.conf
	$(SYSTEMD_ENABLE) unbound

networkmanager: ## Configure NetworkManager (DNS + wifi backend)
	@echo "==> Configurando NetworkManager/conf.d..."
	sudo install -d -m 755 /etc/NetworkManager/conf.d
	sudo install -m 644 ${PWD}/etc/NetworkManager/conf.d/*.conf /etc/NetworkManager/conf.d/
	@echo "==> Recargando NetworkManager (omitido en SSH para evitar desconexión)..."
	@if [ -z "$$SSH_CONNECTION" ]; then sudo systemctl reload NetworkManager || true; else echo "    SSH detectado: recarga manualmente con 'sudo systemctl reload NetworkManager'"; fi

dns: unbound networkmanager ## Configure the whole local DNS stack (unbound + NM)

podman_image: ## Build the Podman image for testing
	podman build -t dotfiles ${PWD}

test: podman_image ## Test the Makefile with Podman
	@echo "==> Iniciando contenedor de prueba..."
	podman run -it --name maketest -d dotfiles:latest /bin/bash || true
	@for target in install init wayland hypr thinkpad; do \
		echo "==> Probando target: $$target"; \
		podman exec -it maketest sh -c "cd ${PWD}; make $$target"; \
	done
	@echo "==> Limpiando contenedor de prueba..."
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
