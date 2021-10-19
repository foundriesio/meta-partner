FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://fioconfig.conf \
"

do_install_append() {
    install -Dm 0644 ${WORKDIR}/fioconfig.conf ${D}${sysconfdir}/default/fioconfig
}