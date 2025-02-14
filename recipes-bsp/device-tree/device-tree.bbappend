FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:kv260 = " \
	file://0001-zynqmp-2022.1-optee-firmware-node.patch \
	file://0001-zynqmp-sm-k26-reva-enable-pwm-fan-for-fancontrol.patch \
"

# From xilinx-kv260-starterkit-xsct-2024.2/project-spec/dts_dir
EXTRA_DT_FILES:kv260 = " \
	zynqmp-sck-kv-g-revB.dtso \
"

inherit xilinx-platform-init

PROVIDES:append:zynqmp = " virtual/xilinx-platform-init"

SRC_URI:append:uz = " \
	file://system-bsp.dtsi \
	file://system-conf.dtsi \
"

# Use #include as these files have includes of their own
do_configure:append:uz () {
	echo '#include "system-bsp.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
	echo '#include "system-conf.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
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
