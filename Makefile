export PATH := ${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin
export GOPATH := ${HOME}


.DEFAULT_GOAL := help
.PHONY: allinstall nextinstall

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install arch linux packages using yay
	sudo pacman -S --needed --noconfirm yay
	cat ${PWD}/pkglist.txt | xargs -L 1 yay -S --needed --noconfirm

cli-tools: ## Add cli tools to local bin
	ln -vsf ${PWD}/commands/* ${HOME}/.local/bin/

init: ## Initial deploy dotfiles
	for item in kitty mpv nvim ranger rofi starship.toml zathura; do
		test -L ${HOME}/.config/$$item || rm -rf ${HOME}/.config/$$item
		ln -vsf {${PWD}/config,${HOME}/.config}/$$item
	done
	chsh -s $(which zsh)
	for item in gitconfig gtkrc-2 myclirc noderc profile pyrc tmux.conf tridactylrc Xresources zimrc zshrc zshfunc scripts; do
		ln -vsf {${PWD},${HOME}}/.$$item
	done

newm: ## config for newm(wayland)
	sudo cp ${PWD}/wayland/scripts/* /usr/local/bin/
	yay -S --needed --noconfirm greetd-tuigreet
	sudo cp ${PWD}/etc/greetd /etc/
	yay -S --needed --noconfirm $@-git waybar avizo wlsunset wl-clipboard cliphist catapult
	for item in avizo fnott waybar $@; do
		test -L ${HOME}/.config/$$item || rm -rf ${HOME}/.config/$$item
		ln -vsf {${PWD}/config,${HOME}/.config}/$$item
	done

swaywm: ## config sway
	ln -vsf ${PWD}/$@/* ${HOME}/.config/
	yay -S --needed --noconfirm sworkstyle \
		waybar eww-git clipman gestures

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
