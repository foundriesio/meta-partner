FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://tmpfiles.conf \
"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -D -m 0644 ${WORKDIR}/tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/property-vault.conf
        (cd ${D}${localstatedir}; rm -v leutils/build.prop; rmdir -v --parents leutils)
    fi
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d/property-vault.conf"
