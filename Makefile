export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/bin/core_perl
export GOPATH := ${HOME}

WAYLAND_PKGS	:= greetd-tuigreet xdg-desktop-portal xdg-desktop-portal-wlr hyprpicker-git shotman-git waybar fnott
WAYLAND_PKGS	+= wl-screenrec-git wlrctl wtype avizo wlsunset wl-clipboard cliphist catapult rofi-lbonn-wayland slurp

SYSTEMD_ENABLE	:= sudo systemctl --now enable

.DEFAULT_GOAL := help
.PHONY: allinstall nextinstall


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install arch linux packages using yay
	sudo pacman -S --needed --noconfirm yay
	cat ${PWD}/pkglist.txt | xargs -L 1 yay -S --needed --noconfirm
	$(SYSTEMD_ENABLE) auto-cpufreq ananicy-cpp thermald
	bob use nightly

init: ## Initial deploy dotfiles
	for item in gitconfig gtkrc-2 noderc pyrc tridactylrc zimrc zshrc zshfunc Xresources tmux.conf profile myclirc; do\
		ln -vsf {${PWD},${HOME}}/.$$item;\
	done
	test -L ${HOME}/.scripts || rmdir ${HOME}/.scripts
	ln -vsfn ${PWD}/.scripts ${HOME}/.scripts
	$(SYSTEMD_ENABLE) keyd nftables

wayland: ## Wayland packages needs
	yay -S --needed --noconfirm $(WAYLAND_PKGS)


newm: ## config for newm(wayland)
	sudo cp ${PWD}/wayland/scripts/{newm-run.sh,wayland_enablement.sh,open-wl} /usr/local/bin/
	sudo cp ${PWD}/etc/greetd /etc/
	$(SYSTEMD_ENABLE) greetd
	for item in avizo fnott waybar $@; do\
		test -L ${HOME}/.config/$$item || rm -rf ${HOME}/.config/$$item;\
		ln -vsf {${PWD}/config,${HOME}/.config}/$$item;\
	done

swaywm: ## config sway
	ln -vsf ${PWD}/$@/* ${HOME}/.config/
	yay -S --needed --noconfirm sworkstyle \
		waybar eww-git clipman gestures

thinkpad: ## Config for thinkpad
	yay -S --needed --noconfirm tpacpi-bat zcfan acpi_call
	$(SYSTEMD_ENABLE) zcfan tpacpi-bat

cli-tools: ## Add cli tools to local bin
	ln -vsf ${PWD}/commands/* ${HOME}/.local/bin/

Code: ## Install and configure VScode
	mkdir -p ${HOME}/.config/$@/
	ln -vsf ${PWD}/$@/* ${HOME}/.config/$@/
	yay -S --needed --noconfirm visual-studio-code-bin
	bash ${PWD}/$@/my_vscode_extensions.sh
	sudo npm install -g vsce
	cd ${PWD}/$@/miramare/ && vsce package .
	code --install-extension ${PWD}/$@/miramare/miramare-0.0.2.vsix

dnscrypt-proxy:
	ln -vsf ${PWD}/etc/$@/* /etc/$@/
	ln -vsf ${PWD}/etc/resolv.conf /etc/
	yay -S --needed --noconfirm $@

nftables:
	ln -vsf ${PWD}/etc/$@.conf /etc/
	# ln -vsf ${PWD}/etc/$@-docker.conf /etc/
	yay -S --needed --noconfirm $@

podman_image: podman
	podman build -t dotfiles ${PWD}

test: podman_image ## Test this Makefile with docker without backup directory
	podman run -it --name make$@ -d dotfiles:latest /bin/bash
	for target in install init neomutt aur pipinstall goinstall nodeinstall; do
		podman exec -it make$@ sh -c "cd ${PWD}; make $${target}"
	done

testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH
	GOPATH=$$GOPATH
	@echo $$GOPATH

allinstall: install init cli-tools

nextinstall: docker
