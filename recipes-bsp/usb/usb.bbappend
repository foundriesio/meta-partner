do_install:append:qcm6490() {
	rm -rf ${D}${systemd_unitdir}/system/local-fs.target.wants ${D}/lib ${D}/var
}
