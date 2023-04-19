export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

WAYLAND_PKGS	:= greetd-tuigreet xdg-desktop-portal xdg-desktop-portal-wlr hyprpicker-git shotman-git waybar fnott
WAYLAND_PKGS	+= wl-screenrec-git wlrctl wtype avizo wlsunset wl-clipboard cliphist catapult rofi-lbonn-wayland slurp
CONFPATH        := ${HOME}/.config

SYSTEMD_ENABLE	:= sudo systemctl --now enable

.DEFAULT_GOAL := help
.PHONY: allinstall nextinstall

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install arch linux packages using yay
	sudo pacman -S --needed --noconfirm yay
	cat ${PWD}/pkglist.txt | grep -v "^#" | grep -v "^$" | xargs -L 1 yay -S --needed --noconfirm
	$(SYSTEMD_ENABLE) auto-cpufreq ananicy-cpp thermald
	bob use nightly

etc: ## Add system settings
	test -L /etc/keyd || rm -rf /etc/keyd
	ln -vsfn ${PWD}/etc/keyd /etc
	test -L /etc/nftables.conf|| rm -rf /etc/nftables.conf
	ln -vsfn ${PWD}/etc/nftables.conf /etc
	sudo cp ${PWD}/etc/makepkg.conf /etc
	sudo cp ${PWD}/etc/sysctl.d/99-sysctl.conf /etc/sysctl.d
	$(SYSTEMD_ENABLE) keyd nftables

init: ## Initial deploy dotfiles
	for item in gitconfig gtkrc-2 noderc pyrc tridactylrc zimrc zshrc zshfunc Xresources tmux.conf profile myclirc; do\
		ln -vsf {${PWD},${HOME}}/.$$item;\
	done
	for item in nvim btop ctpv lf mpv rofi starship.toml zathura; do\
		ln -vsfn {${PWD}/config,${CONFPATH}}/$$item;\
	done
	ln -vsfn {${PWD},${HOME}}/.scripts

wayland: ## Wayland packages needs
	for item in avizo fnott waybar $@; do\
		ln -vsf {${PWD}/config,${CONFPATH}}/$$item;\
	done
	yay -S --needed --noconfirm $(WAYLAND_PKGS)

newm: wayland ## config for newm(wayland)
	yay -S --needed --noconfirm python-pyfiglet python-pam python-thefuzz-git python-evdev newm-git
	sudo cp ${PWD}/wayland/scripts/{newm-run.sh,wayland_enablement.sh,open-wl} /usr/local/bin/
	sudo cp ${PWD}/etc/greetd /etc/
	$(SYSTEMD_ENABLE) greetd

thinkpad: ## Config for thinkpad(power management, battery thresholds and fan control)
	yay -S --needed --noconfirm tpacpi-bat zcfan acpi_call acpid
	sudo cp ${PWD}/$@/etc/zcfan.conf /etc/
	sudo cp ${PWD}/$@/etc/conf.d/tpacpi /etc/conf.d/
	sudo cp ${PWD}/$@/etc/acpi/events/battery_event /etc/acpi/events
	sudo cp ${PWD}/$@/etc/acpi/actions /etc/acpi/
	$(SYSTEMD_ENABLE) zcfan tpacpi-bat acpid

self-tools: ## Add cli tools to local bin
	ln -vsf ${PWD}/local/bin/* ${HOME}/.local/bin/

Code: ## Install and configure VScode
	mkdir -p ${HOME}/.config/$@/
	ln -vsf ${PWD}/$@/* ${HOME}/.config/$@/
	yay -S --needed --noconfirm visual-studio-code-bin
	bash ${PWD}/$@/my_vscode_extensions.sh
	sudo npm install -g vsce
	cd ${PWD}/$@/miramare/ && vsce package .
	code --install-extension ${PWD}/$@/miramare/miramare-0.0.2.vsix

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

newminstall: install etc init newm
tnewminstall: install etc init newm thinkpad

nextinstall: docker
