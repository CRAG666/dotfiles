# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel ${_JAVA_OPTIONS}"
# export QT_QPA_PLATFORMTHEME=qt6ct
# export RIDER_JDK=/usr/share/rider/jbr
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# LS_COLORS — eyes (light) palette, truecolor SGR codes
# Used by GNU ls, tree, fd, nushell, etc. (eza/exa uses its own eyes.yml)
export LS_COLORS="\
di=1;38;2;106;148;168:\
ln=38;2;90;184;168:\
or=1;38;2;200;120;104:\
ex=1;38;2;122;171;114:\
fi=38;2;208;220;200:\
pi=38;2;184;154;106:\
so=38;2;184;144;176:\
bd=38;2;200;168;112:\
cd=38;2;212;184;90:\
do=38;2;144;144;184:\
su=1;38;2;214;136;120:\
sg=1;38;2;214;136;120:\
tw=38;2;208;220;200;48;2;108;144;96:\
ow=38;2;106;148;168;48;2;32;40;32:\
*.tar=38;2;184;144;176:*.tgz=38;2;184;144;176:*.gz=38;2;184;144;176:\
*.zip=38;2;184;144;176:*.7z=38;2;184;144;176:*.xz=38;2;184;144;176:\
*.zst=38;2;184;144;176:*.bz2=38;2;184;144;176:*.rar=38;2;184;144;176:\
*.jpg=38;2;184;154;106:*.jpeg=38;2;184;154;106:*.png=38;2;184;154;106:\
*.gif=38;2;184;154;106:*.webp=38;2;184;154;106:*.svg=38;2;184;154;106:\
*.mp4=38;2;200;120;104:*.mkv=38;2;200;120;104:*.webm=38;2;200;120;104:\
*.mov=38;2;200;120;104:*.avi=38;2;200;120;104:\
*.mp3=38;2;122;171;114:*.flac=38;2;122;171;114:*.wav=38;2;122;171;114:\
*.ogg=38;2;122;171;114:*.opus=38;2;122;171;114:\
*.pdf=38;2;90;184;168:*.epub=38;2;90;184;168:*.djvu=38;2;90;184;168:\
*.md=38;2;106;184;176:*.txt=38;2;208;220;200\
"
