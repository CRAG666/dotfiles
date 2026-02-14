export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

# Paquetes organizados por categoría
HYPR_PKGS := hyprland grimblast-git xdg-desktop-portal-hyprland dunst awww-git \
             hyprland-guiutils hyprland-qt-support hyprpolkitagent hyprshot \
             hyprsunset hyprtoolkit hyprutils

WAYLAND_PKGS := wl-kbptr wlrctl wl-clipboard swaylock-effects rofi qt6-wayland \
                imv kitty egl-wayland cliphist greetd-regreet \
                xdg-desktop-portal-termfilechooser-hunkyburrito-git \
                xdg-desktop-portal-gtk xdg-desktop-portal-hyprland

NVIDIA_PKGS := nvidia nvidia-prime nvidia-settings nvidia-utils cuda \
               libva-nvidia-driver opencl-nvidia nvtop nvidia-container-toolkit

LAPTOP_PKGS := thermald auto-cpufreq

THINKPAD_PKGS := zcfan acpi_call throttled

# Comandos systemd
SYSTEMD_ENABLE := sudo systemctl --now enable
SYSTEMD_ENABLE_USER := systemctl --user --now enable

.DEFAULT_GOAL := help
.PHONY: help install init wayland hypr laptop thinkpad nvidia dnscrypt-proxy \
        podman_image test testpath hyprinstall p53 p53nvidia clean

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Instala paquetes de Arch Linux usando yay
	@echo "==> Instalando yay si es necesario..."
	@sudo pacman -S --needed --noconfirm yay || { echo "Error instalando yay"; exit 1; }
	@echo "==> Instalando paquetes desde pkglist.txt..."
	@cat ${PWD}/pkglist.txt | grep -v "^#" | grep -v "^$$" | xargs -r yay -S --needed --noconfirm
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

init: ## Despliega los dotfiles iniciales
	@echo "==> Creando enlaces simbólicos en el directorio HOME"
	@SRC_DIR=${PWD}; \
	DOTFILES=$$(find $$SRC_DIR -maxdepth 1 -type f -name ".*" -exec basename {} \;); \
	CONFIGS=$$(find $$SRC_DIR/config -mindepth 1 -maxdepth 1 -exec basename {} \;); \
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

wayland: ## Instala paquetes necesarios para Wayland
	@echo "==> Configurando greetd..."
	sudo cp -r ${PWD}/etc/greetd /etc/
	@echo "==> Instalando paquetes Wayland..."
	yay -S --needed --noconfirm $(WAYLAND_PKGS)
	$(SYSTEMD_ENABLE) greetd

hypr: wayland ## Configura Hyprland (Wayland)
	@echo "==> Instalando script hypr-run..."
	sudo install -m 755 ${PWD}/wayland/scripts/hypr-run.sh /usr/local/bin/
	@echo "==> Instalando paquetes Hyprland..."
	yay -S --needed --noconfirm $(HYPR_PKGS)

laptop: ## Configura laptop (gestión de energía)
	@echo "==> Instalando herramientas de gestión de energía..."
	yay -S --needed --noconfirm $(LAPTOP_PKGS)
	sudo cp ${PWD}/etc/auto-cpufreq.conf /etc/
	$(SYSTEMD_ENABLE) thermald auto-cpufreq

thinkpad: laptop ## Configuración específica para ThinkPad
	@echo "==> Instalando herramientas específicas de ThinkPad..."
	yay -S --needed --noconfirm $(THINKPAD_PKGS)
	sudo cp ${PWD}/thinkpad/etc/zcfan.conf /etc/
	$(SYSTEMD_ENABLE) zcfan throttled

nvidia: ## Configura drivers NVIDIA
	@echo "==> Instalando paquetes NVIDIA..."
	yay -S --needed --noconfirm $(NVIDIA_PKGS)

dnscrypt-proxy: ## Configura dnscrypt-proxy
	@echo "==> Configurando dnscrypt-proxy..."
	sudo ln -vsf ${PWD}/etc/resolv.conf /etc/resolv.conf
	yay -S --needed --noconfirm dnscrypt-proxy
	sudo ln -vsf ${PWD}/etc/dnscrypt-proxy/* /etc/dnscrypt-proxy/
	$(SYSTEMD_ENABLE) dnscrypt-proxy

podman_image: ## Construye imagen de Podman para testing
	podman build -t dotfiles ${PWD}

test: podman_image ## Prueba el Makefile con Podman
	@echo "==> Iniciando contenedor de prueba..."
	podman run -it --name maketest -d dotfiles:latest /bin/bash || true
	@for target in install init wayland hypr thinkpad; do \
		echo "==> Probando target: $$target"; \
		podman exec -it maketest sh -c "cd ${PWD}; make $$target"; \
	done
	@echo "==> Limpiando contenedor de prueba..."
	@podman stop maketest && podman rm maketest || true

testpath: ## Muestra las variables PATH y GOPATH
	@echo "PATH: $$PATH"
	@echo "GOPATH: $(GOPATH)"

clean: ## Limpia contenedores de prueba
	@podman stop maketest 2>/dev/null || true
	@podman rm maketest 2>/dev/null || true

# Targets combinados
hyprinstall: install init hypr ## Instalación completa de Hyprland

p53: install init thinkpad hypr ## Instalación para ThinkPad P53

p53nvidia: p53 nvidia ## Instalación para ThinkPad P53 con NVIDIA
