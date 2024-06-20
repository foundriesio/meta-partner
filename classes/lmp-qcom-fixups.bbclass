fix_usrmerge() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'usrmerge', 'true', 'false', d)}; then
        if [ -d ${D}/lib ]; then
            install -d ${D}${nonarch_base_libdir}
            mv ${D}/lib/* ${D}${nonarch_base_libdir}
            rmdir ${D}/lib
        fi
    fi
}

python __anonymous() {
    pn = d.getVar('PN')

    if bb.data.inherits_class('qprebuilt', d) or pn.startswith('firmware-qcom'):
        d.appendVarFlag('do_install', 'postfuncs', ' fix_usrmerge')
}
