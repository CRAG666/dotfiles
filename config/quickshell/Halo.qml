import QtQuick
import QtQuick.Effects

// The soft halo that keeps text legible over any wallpaper, as a layer effect:
// `dark` puts a dark halo behind light text, and vice versa. Desktop blocks
// take one each over all their texts, as one per text cost ~40 % of the
// widgets' CPU and drew each text resampled from a texture
MultiEffect {
    property bool dark: true
    shadowEnabled: true
    shadowColor: Theme.shadow(dark)
    shadowOpacity: 0.9
    shadowBlur: 0.85
    blurMax: 24
}
