FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# replace DEPENDS to allow gtk+3 being added depending on pkgconfig
DEPENDS = "glib-2.0 libgudev libxslt-native dbus json-glib"

# conditional for gui/gtk+3 support
SRC_URI:append:qcom = " file://0001-Make-gui-build-optional.patch"

PACKAGECONFIG:append:qcom = " ${@bb.utils.contains_any('DISTRO_FEATURES', [ 'wayland', 'x11' ], 'gui', '', d)}"
PACKAGECONFIG[gui] = "-Dgui=true,-Dgui=false,gtk+3"
