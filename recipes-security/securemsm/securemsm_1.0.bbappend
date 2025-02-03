fix_install_sota() {
    mkdir -p ${D}${datadir}/qwes
    mv ${D}/var/local/qwes/QWESAttestationCert.pfm ${D}${datadir}/qwes

    rmdir -v \
        ${D}/var/local/qwes \
        ${D}/var/local
}

do_install[postfuncs] += "fix_install_sota"

FILES:${PN} += "${datadir}/qwes"
