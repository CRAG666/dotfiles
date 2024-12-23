export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

HYPR_PKGS	    := hyprland grimblast-git xdg-desktop-portal-gtk xdg-desktop-portal-hyprland dunst swww
WAYLAND_PKGS	:= wl-clipboard wluma swaylock-effects polkit-gnome rofi-wayland qt6-wayland imv foot egl-wayland cliphist greetd-regreet
NVIDIA_PKGS	    := nvidia nvidia-prime nvidia-settings nvidia-utils cuda libva-nvidia-driver opencl-nvidia nvtop
SYSTEMD_ENABLE	:= sudo systemctl --now enable
SYSTEMD_ENABLE_USER	:= systemctl --user --now enable

.DEFAULT_GOAL := help
.PHONY: allinstall nextinstall

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install arch linux packages using yay
	sudo pacman -S --needed --noconfirm yay
	cat ${PWD}/pkglist.txt | grep -v "^#" | grep -v "^$" | xargs -L 1 yay -S --needed --noconfirm
	$(SYSTEMD_ENABLE) ananicy-cpp
	bob use nightly

etc: ## Add system settings
	yay -S --needed --noconfirm keyd nftables
	test -L /etc/keyd || rm -rf /etc/keyd
	ln -vsfn ${PWD}/etc/keyd /etc
	test -L /etc/nftables.conf|| rm -rf /etc/nftables.conf
	ln -vsfn ${PWD}/etc/nftables.conf /etc
	sudo cp ${PWD}/etc/makepkg.conf /etc
	sudo cp ${PWD}/etc/sysctl.d/99-sysctl.conf /etc/sysctl.d
	$(SYSTEMD_ENABLE) keyd nftables

init: ## Initial deploy dotfiles
	@echo "Creating symbolic links in the HOME directory"
	@SRC_DIR=$$PWD; \
	DOTFILES=$$(find $$SRC_DIR -maxdepth 1 -type f -name ".*" -exec basename {} \;); \
	CONFIGS=$$(find $$SRC_DIR/config -mindepth 1 -maxdepth 1 -exec basename {} \;); \
	for file in $$DOTFILES; do \
		if [ ! -e "$$GOPATH/$$file" ]; then \
			ln -vfs "$$SRC_DIR/$$file" "$$GOPATH/$$file"; \
		else \
			echo "The file $$file already exists in $$GOPATH, skipping"; \
		fi; \
	done; \
	for config in $$CONFIGS; do \
		if [ ! -e "$$GOPATH/.config/$$config" ]; then \
			mkdir -p "$$GOPATH/.config"; \
			ln -vfs "$$SRC_DIR/config/$$config" "$$GOPATH/.config/$$config"; \
		else \
			echo "The file $$config already exists in $$GOPATH/.config, skipping"; \
		fi; \
	done

wayland: ## Wayland packages needs
	sudo cp ${PWD}/etc/greetd /etc/
	yay -S --needed --noconfirm $(WAYLAND_PKGS)
	$(SYSTEMD_ENABLE) greetd
	$(SYSTEMD_ENABLE_USER) xdg-desktop-portal-gtk

hypr: wayland ## config for hyprland(wayland)
	sudo cp ${PWD}/wayland/scripts/hypr-run.sh /usr/local/bin/
	yay -S --needed --noconfirm $(HYPR_PKGS)

thinkpad: ## Config for thinkpad(power management, battery thresholds and fan control)
	yay -S --needed --noconfirm zcfan acpi_call throttled
	sudo cp ${PWD}/$@/etc/zcfan.conf /etc/
	$(SYSTEMD_ENABLE) zcfan throttled
	$(SYSTEMD_ENABLE_USER) xdg-desktop-portal-hyprland

nvidia: ## Nvidia config
	yay -S --needed --noconfirm $(NVIDIA_PKGS)

dnscrypt-proxy:
	ln -vsf ${PWD}/etc/resolv.conf /etc/
	yay -S --needed --noconfirm $@
	ln -vsf ${PWD}/etc/$@/* /etc/$@/

podman_image:
	podman build -t dotfiles ${PWD}

test: podman_image ## Test this Makefile with docker without backup directory
	# podman run -it --name make$@ -d dotfiles:latest /bin/bash
	# for target in install etc init wayland newm thinkpad dnscrypt-proxy; do\
	for target in thinkpad; do\
		podman exec -it make$@ sh -c "cd ${PWD}; make $${target}";\
	done

testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH
	GOPATH=$$GOPATH
	@echo $$GOPATH

hyprinstall: install etc init hypr
nextinstall: docker
thinkpadnvidia: nvidia thinkpad
