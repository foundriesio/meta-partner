# Replicate settings from oe-core in order to align the available pkgconfig options
PACKAGECONFIG:qcom = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms wayland egl clients', '', d)} \
                      ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                      ${@bb.utils.filter('DISTRO_FEATURES', 'systemd x11', d)} \
                      ${@bb.utils.contains_any('DISTRO_FEATURES', 'wayland x11', '', 'headless', d)} \
                      image-jpeg \
                      screenshare \
                      shell-desktop \
                      shell-fullscreen \
                      shell-ivi \
                      shell-kiosk \
"

# Replace with value from oe-core as weston-init is used instead
RRECOMMENDS:${PN} = "weston-init liberation-fonts"

## weston.init should be provided by weston-init instead
do_install:append() {
	rm -f ${D}${sysconfdir}/xdg/weston/weston.ini || true
}

# Replace with value from oe-core
FILES:${PN}:qcom = "${sysconfdir} ${bindir}/weston ${bindir}/weston-terminal ${bindir}/weston-info ${bindir}/weston-launch ${bindir}/wcap-decode ${libexecdir} ${libdir}/${BPN}/*.so* ${datadir}"
