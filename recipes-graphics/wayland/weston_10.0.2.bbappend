# Replicate settings from oe-core in order to align the available pkgconfig options
PACKAGECONFIG:qcom = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms wayland egl clients', '', d)} \
                      ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                      ${@bb.utils.filter('DISTRO_FEATURES', 'systemd x11', d)} \
                      ${@bb.utils.contains_any('DISTRO_FEATURES', 'wayland x11', '', 'headless', d)} \
                      ${@oe.utils.conditional('VIRTUAL-RUNTIME_init_manager', 'sysvinit', 'launcher-libseat', '', d)} \
                      image-jpeg \
                      screenshare \
                      shell-desktop \
                      shell-fullscreen \
                      shell-ivi \
"

PACKAGECONFIG:remove:qcm6490 = "kms"

# Override (extra dependencies)
PACKAGECONFIG[xwayland] = "-Dxwayland=true,-Dxwayland=false,libxcursor xwayland"

# Replace with value from oe-core as weston-init is used instead
RRECOMMENDS:${PN} = "weston-init liberation-fonts"

# weston.ini should be provided by the standard weston-init recipe
do_install:append:qcm6490() {
    rm -rfv ${D}${sysconfdir}
}

# Replace with value from oe-core
FILES:${PN}:qcom = "${bindir}/weston ${bindir}/weston-terminal ${bindir}/weston-info ${bindir}/weston-launch ${bindir}/wcap-decode ${libexecdir} ${libdir}/${BPN}/*.so* ${datadir}"
