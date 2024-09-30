FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:lmp = " file://simplify_init.patch"

do_install:append() {
	# Fix behavior for usrmerge
	if echo ${MACHINE} | grep -q -e "qcs6490" -e "qcm6490"; then
		rm -f ${D}/lib/firmware/updates/qca6490
		rmdir ${D}/lib/firmware/updates ${D}/lib/firmware ${D}/lib
		install -d  ${D}${nonarch_base_libdir}/firmware/updates/
		ln -sf ${nonarch_base_libdir}/firmware/qcacld/WCN6855/hw2.1 ${D}${nonarch_base_libdir}/firmware/updates/qca6490
	fi
}
