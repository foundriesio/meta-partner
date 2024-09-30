do_install() {
	install -m 0644 ${S}/audio-node.rules -D ${D}${nonarch_base_libdir}/udev/rules.d/audio-node.rules
}

FILES_${PN} += "${nonarch_base_libdir}/udev"
