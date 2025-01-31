FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://drop-etc-mount-service.patch \
    file://tmpfiles.conf \
"

fix_install_sota() {
    # clean patches and series due qprebuilt.bbclass
    rm -v ${D}/*.patch; rm -v ${D}/patches/*; rmdir -v ${D}/patches
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        # qprebuilt class moves all files from S on install
        mkdir -p ${D}${nonarch_libdir}/tmpfiles.d
        mv ${D}/tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/${PN}.conf
    fi
}
do_install[postfuncs] += "fix_install_sota"

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d/${PN}.conf"
