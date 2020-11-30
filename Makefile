export PATH := ${HOME}/.cargo/bin:/bin:/usr/local/bin:/usr/local/sbin:${HOME}/.config/nvim:${HOME}.config/Typora/themes
export GOPATH := ${HOME}

cli-tools: ## Add cli tools
	sudo ln -sf ${PWD}/commands/* /usr/local/bin/

init: ## Initial deploy dotfiles
	mkdir -p ${HOME}/.config/nvim
	mkdir -p ${HOME}/.config/nvim/plugged
	mkdir -p ${HOME}/.config/alacritty
	ln -vsf ${PWD}/.zshrc ${HOME}/.zshrc
	ln -vsf ${PWD}/.zsh_history ${HOME}/.zsh_history
	ln -vsf ${PWD}/.myclirc ${HOME}/.myclirc
	ln -vsf ${PWD}/.tmux.conf ${HOME}/.tmux.conf
	ln -vsf ${PWD}/.gitconfig ${HOME}/.gitconfig
	ln -vsf ${PWD}/.pyrc ${HOME}/.pyrc
	ln -vsf ${PWD}/nodeprompt/noderc ${HOME}/.noderc
	ln -vsf ${PWD}/.vim/init ${HOME}/.config/nvim/
	ln -vsf ${PWD}/.vim/init.vim ${HOME}/.config/nvim/init.vim
	ln -vsf ${PWD}/.vim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
	ln -vsf ${PWD}/starship.toml ${HOME}/.config/starship.toml
	ln -vsf ${PWD}/alacritty.yml ${HOME}/.config/alacritty/alacritty.yml

text-editors-config: ## config noty and typora
	ln -vsf ${PWD}/typora-theme/* ${HOME}/.config/Typora/themes/
	ln -vsf ${PWD}/config.json ${HOME}/.config/Noty/

zsh: ## install oh my zsh
	yay -S --needed --noconfirm oh-my-zsh-git zh-autosuggestions \
		zsh-completions zsh-history-substring-search \
		zsh-sintax-highlighting
	chsh -s $(which zsh)

vim-plug: ## Install vim plug
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

yay: ## Install yay
	sudo pacman -S --needed --noconfirm yay

install: ## Install arch linux packages using yay
	cat ${PWD}/pkglist.txt | xargs -L 1 yay -S --needed --noconfirm


npm-cli-tools: ## Install fx and speedtest-net
	sudo npm install -g fx speedtest-net

code: ## Install and configure VScode
	yay -S --needed --noconfirm visual-studio-code-bin
	cat ${PWD}/vscode/vscode-extensions.list | xargs -L 1 code --install-extension
	ln -vsf ${PWD}/vscode/settings.json ${HOME}/.config/Code/User/settings.json
	ln -vsf ${PWD}/vscode/snippets ${HOME}/.config/Code/User/
	ln -vsf ${PWD}/vscode/keybindings.json ${HOME}/.config/Code/User/keybindings.json
	sudo npm install -g vsce
	cd ${PWD}/vscode/miramare/ && vsce package .
	code --install-extension ${PWD}/vscode/miramare/miramare-0.0.2.vsix

android-studio: ## Install and configure Android Studio
	yay -S --noconfirm android-studio

pycharm: ## Install and configure pycharm
	sudo pacman -S --noconfirm pycharm-community-edition

intellij-idea: ## Install and configure IDEA
	sudo pacman -S --noconfirm intellij-idea-community-edition

rustinstall: ## Install rust and rust language server
	sudo pacman -S rustup
	rustup default stable
	rustup component add rls rust-analysis rust-src

docker: ## Docker initial setup
	sudo pacman -S docker
	sudo usermod -aG docker ${USER}

maria-db: ## Mariadb initial setup
	sudo ln -vsf ${PWD}/etc/sysctl.d/40-max-user-watches.conf /etc/sysctl.d/40-max-user-watches.conf
	sudo pacman -S --noconfirm mariadb mariadb-clients mycli
	sudo ln -vsf ${PWD}/etc/my.cnf /etc/my.cnf
	sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	sudo systemctl start mariadb.service
	sudo mysql -u root < ${PWD}/mariadb/init.sql
	mysql_secure_installation
	mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

mongodb: ## Mongodb initial setup
	sudo pacman -S mongodb mongodb-tools

docker-compose: ## Set up docker-compose
	sudo pacman -S docker-compose

spotify: ## Install spotify
	gpg --keyserver hkp://keyserver.ubuntu.com --receive-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
	yay -S --noconfirm spotify spotify-adblock-linux

screenkey: ## Init screenkey
	yay -S screenkey
	mkdir -p ${HOME}/.config
	ln -vsf ${PWD}/screenkey.json ${HOME}/.config/screenkey.json

testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH
	GOPATH=$$GOPATH
	@echo $$GOPATH

allinstall: cli-tools yay install init text-editors-config zsh vim-plug npm-cli-tools screenkey spotify

nextinstall: rustinstall maria-db mongodb docker docker-compose

intellij: pycharm android-studio intellij-idea

ideinstall: code intellij

.PHONY: allinstall nextinstall ideinstall

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
