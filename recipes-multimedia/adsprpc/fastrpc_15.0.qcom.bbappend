# Drop executable flag on udev rules
fix_udev_rules() {
    chmod -x ${D}${sysconfdir}/udev/rules.d/*.rules
}

do_install[postfuncs] += "fix_udev_rules"
