# export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export ANDROID_HOME=/opt/android-sdk
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel ${_JAVA_OPTIONS}"
# export QT_QPA_PLATFORMTHEME=qt6ct
export GTK_THEME="$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"\'\")"
export XDG_SCREENSHOTS_DIR=$HOME/Screenshots
# export RIDER_JDK=/usr/share/rider/jbr
export DOTNET_CLI_TELEMETRY_OPTOUT=1
