RDEPENDS:${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', '', 'xwayland', d)}"
