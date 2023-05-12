FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://backlight.rules \
    file://set-backlight.sh \
"

do_install:append () {
	install -m 0644 ${WORKDIR}/backlight.rules ${D}${sysconfdir}/udev/rules.d/
	install -m 0755 ${WORKDIR}/set-backlight.sh ${D}${sysconfdir}/udev/rules.d/
}
