FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://tmpfiles.conf"

do_install:append:lmp() {
	install -D -m 0644 ${WORKDIR}/tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/${BPN}.conf
}
