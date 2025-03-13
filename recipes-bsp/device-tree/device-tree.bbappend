FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit xilinx-platform-init

PROVIDES:append:zynqmp = " virtual/xilinx-platform-init"

# Early setup of OP-TEE memory regions fixes a u-boot hang
SRC_URI:append:zynqmp = " \
	file://system-optee-memory.dtsi \
"
do_configure:append:zynqmp () {
	echo '#include "system-optee-memory.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
}

SRC_URI:append:kv260 = " \
        file://system-pwm-fan-enable.dtsi \
        file://system-fix-sd-wp.dtsi \
"
do_configure:append:kv260 () {
	echo '#include "system-pwm-fan-enable.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
	echo '#include "system-fix-sd-wp.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
}

SRC_URI:append:uz = " \
	file://system-bsp.dtsi \
        file://system-fix-sd-wp.dtsi \
"
do_configure:append:uz () {
	echo '#include "system-bsp.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
	echo '#include "system-fix-sd-wp.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
}

do_install:append:zynqmp () {
	# Fix psu_init_gpl.c function definition issue for serdes_rst_seq and serdes_illcalib_pcie_gen1
	sed -i "s|^static int serdes_rst_seq (u32 lane3_protocol|//static int serdes_rst_seq (u32 lane3_protocol|g" ${B}/device-tree/psu_init_gpl.c
	sed -i "s|^static int serdes_illcalib_pcie_gen1 (u32 lane3_protocol|//static int serdes_illcalib_pcie_gen1 (u32 lane3_protocol|g" ${B}/device-tree/psu_init_gpl.c
	sed -i "s|^//static int serdes_rst_seq (u32 pllsel|static int serdes_rst_seq (u32 pllsel|g" ${B}/device-tree/psu_init_gpl.c
	sed -i "s|^//static int serdes_illcalib_pcie_gen1 (u32 pllsel|static int serdes_illcalib_pcie_gen1 (u32 pllsel|g" ${B}/device-tree/psu_init_gpl.c
	install -d ${D}${PLATFORM_INIT_DIR}
	for i in ${PLATFORM_INIT_FILES}; do
		install -m 0644 ${B}/device-tree/$i ${D}${PLATFORM_INIT_DIR}/
	done
}

SYSROOT_PREPROCESS_FUNCS += "dtb_sysroot_preprocess"
dtb_sysroot_preprocess () {
	if [ -n "${PLATFORM_INIT_DIR}" ] && [ -d ${D}${PLATFORM_INIT_DIR} ]; then
		install -d ${SYSROOT_DESTDIR}${PLATFORM_INIT_DIR}
		for i in ${PLATFORM_INIT_FILES}; do
			install -m 0644 ${D}${PLATFORM_INIT_DIR}/$i ${SYSROOT_DESTDIR}${PLATFORM_INIT_DIR}/
		done
	fi
}

PACKAGES:append:zynqmp = " ${PN}-platform-init"
FILES:${PN}-platform-init = "${PLATFORM_INIT_DIR}/*"
