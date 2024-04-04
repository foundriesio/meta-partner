FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:qcom = " \
    file://utilities-terminal.png \
    file://background.jpg \
"

FILES:${PN}:append:qcom = " \
    ${datadir}/weston \
"

PACKAGECONFIG:append:qcom = " wayland ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)}"
PACKAGECONFIG[xwayland] = "-Dxwayland=true,-Dxwayland=false,libxcursor xwayland"

# Needed due FILES related changes from meta-qcom-hwe
ALLOW_EMPTY:${PN}-examples = "1"

do_compile:append:qcom() {
    if [ "${@bb.utils.contains('PACKAGECONFIG', 'xwayland', 'yes', 'no', d)}" = "yes" ]; then
        sed -i -e "s/^#xwayland=true/xwayland=true/g" ${WORKDIR}/weston.ini
    fi
}

do_install:append:qcom() {
    install -d ${D}${datadir}/weston/backgrounds
    install -d ${D}${datadir}/weston/icon

    install -m 0644 ${WORKDIR}/utilities-terminal.png ${D}${datadir}/weston/icon/utilities-terminal.png
    install -m 0644 ${WORKDIR}/background.jpg ${D}${datadir}/weston/backgrounds/background.jpg
}
