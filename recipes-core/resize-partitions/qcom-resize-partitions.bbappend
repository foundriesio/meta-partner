do_install:append() {
    # We don't use system partition
    rm -f ${D}${systemd_unitdir}/system/local-fs-pre.target.wants/resize-partition@system.service
}
