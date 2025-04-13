#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Quick Links

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Quick Links'
mesg="Using '$BROWSER' as web browser"

if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
	list_col='1'
	list_row='6'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
	list_col='6'
	list_row='1'
fi

if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-5'*) ]]; then
	efonts="JetBrains Mono Nerd Font 10"
else
	efonts="JetBrains Mono Nerd Font 28"
fi

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1=" Science"
	option_2=" Whatsapp"
	option_3=" Youtube"
	option_4=" Github"
	option_5=" IA"
	option_6="󰝆 Streaming"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6="󰝆"
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-theme-str "element-text {font: \"$efonts\";}" \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		zen-browser -P inaoe 'https://dblp.org/search'
		zen-browser -P inaoe 'https://ieeexplore.ieee.org/Xplore/home.jsp'
		zen-browser -P inaoe 'https://www.sciencedirect.com/'
		zen-browser -P inaoe 'https://www.scopus.com/search/form.uri?display=basic#basic'
		zen-browser -P inaoe 'https://www.webofscience.com/wos/woscc/basic-search'
		zen-browser -P inaoe 'https://www.researchgate.net/'
		zen-browser -P inaoe 'https://onlinelibrary.wiley.com/'
	elif [[ "$1" == '--opt2' ]]; then
		xdg-open 'https://web.whatsapp.com/'
	elif [[ "$1" == '--opt3' ]]; then
		xdg-open 'https://www.youtube.com/'
	elif [[ "$1" == '--opt4' ]]; then
		xdg-open 'https://www.github.com/'
	elif [[ "$1" == '--opt5' ]]; then
		xdg-open 'https://chat.qwen.ai/'
		xdg-open 'https://chat.deepseek.com'
		xdg-open 'https://claude.ai/new'
		xdg-open 'https://grok.com/'
		xdg-open 'https://chat.openai.com/'
		xdg-open 'https://gemini.google.com/app?hl=es'
		xdg-open 'https://www.doubao.com/chat'
		xdg-open 'https://copilot.cloud.microsoft/'
		xdg-open 'https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat&duckai=1'
	elif [[ "$1" == '--opt6' ]]; then
		xdg-open 'https://entrepeliculasyseries.nz/'
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$option_1)
	run_cmd --opt1
	;;
$option_2)
	run_cmd --opt2
	;;
$option_3)
	run_cmd --opt3
	;;
$option_4)
	run_cmd --opt4
	;;
$option_5)
	run_cmd --opt5
	;;
$option_6)
	run_cmd --opt6
	;;
esac
