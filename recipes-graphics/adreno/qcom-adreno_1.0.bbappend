RPROVIDES:${PN} += "libegl libgles1 libgles2"

fix_install_sota() {
    mkdir -p ${D}${datadir}
    mv ${D}/usr/local/share/vulkan ${D}${datadir}
}

do_install[postfuncs] += "fix_install_sota"
