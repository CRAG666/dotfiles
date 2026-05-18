# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel ${_JAVA_OPTIONS}"
# export QT_QPA_PLATFORMTHEME=qt6ct
# export RIDER_JDK=/usr/share/rider/jbr
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# WebKitGTK + Wayland workaround — bug #280210 (Error 71 dispatching)
# Afecta a luakit, nyxt, vimb, chawan, surf, epiphany, etc.
# Quitar cuando WebKitGTK arregle el bug del DMA-BUF renderer.
export WEBKIT_DISABLE_DMABUF_RENDERER=1

# LS_COLORS — eyes (light) palette, truecolor SGR codes
# Used by GNU ls, tree, fd, nushell, etc. (eza/exa uses its own eyes.yml)
export LS_COLORS="\
di=1;38;2;30;72;104:\
ln=38;2;20;88;80:\
or=1;38;2;122;30;24:\
ex=1;38;2;42;92;34:\
fi=38;2;26;26;26:\
pi=38;2;106;60;16:\
so=38;2;90;40;88:\
bd=38;2;122;74;24:\
cd=38;2;90;72;8:\
do=38;2;58;40;96:\
su=1;38;2;138;40;32:\
sg=1;38;2;138;40;32:\
tw=38;2;26;26;26;48;2;108;144;96:\
ow=38;2;30;72;104;48;2;164;204;152:\
*.tar=38;2;90;40;88:*.tgz=38;2;90;40;88:*.gz=38;2;90;40;88:\
*.zip=38;2;90;40;88:*.7z=38;2;90;40;88:*.xz=38;2;90;40;88:\
*.zst=38;2;90;40;88:*.bz2=38;2;90;40;88:*.rar=38;2;90;40;88:\
*.jpg=38;2;106;60;16:*.jpeg=38;2;106;60;16:*.png=38;2;106;60;16:\
*.gif=38;2;106;60;16:*.webp=38;2;106;60;16:*.svg=38;2;106;60;16:\
*.mp4=38;2;122;30;24:*.mkv=38;2;122;30;24:*.webm=38;2;122;30;24:\
*.mov=38;2;122;30;24:*.avi=38;2;122;30;24:\
*.mp3=38;2;42;92;34:*.flac=38;2;42;92;34:*.wav=38;2;42;92;34:\
*.ogg=38;2;42;92;34:*.opus=38;2;42;92;34:\
*.pdf=38;2;20;88;80:*.epub=38;2;20;88;80:*.djvu=38;2;20;88;80:\
*.md=38;2;26;88;88:*.txt=38;2;26;26;26\
"
export CCACHE_MAXSIZE=25G
export CCACHE_COMPRESS=true
export CCACHE_COMPRESSLEVEL=1
export CCACHE_SLOPPINESS=file_macro,locale,time_macros,include_file_mtime,include_file_ctime
export CCACHE_NOHASHDIR=true
