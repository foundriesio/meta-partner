# Add deployment of bit.bin format used with u-boot and lib/firmware handling

DEPENDS += "bootgen-native"

unset do_compile[noexec]

BITSTREAM_NAME ?= "bitstream"

SYSROOT_DIRS += "${nonarch_base_libdir}/firmware"

generate_bin() {
    BITPATH=${XSCTH_WS}/${XSCTH_PROJ}_hwproj/*.bit
    bitname=`basename -s .bit ${BITPATH}`
    printf "all:\n{\n\t`ls ${BITPATH}`\n}" > ${bitname}.bif
    bootgen -image ${bitname}.bif -arch ${SOC_FAMILY} -o ${bitname}.bit.bin -w on \
        ${@bb.utils.contains('SOC_FAMILY','zynqmp','','-process_bitstream bin',d)}

    if [ ! -e "${bitname}.bit.bin" ]; then
        bbfatal "bootgen failed. Enable -log debug with bootgen and check logs"
    fi
}

do_compile:append() {
    if [ -e ${XSCTH_WS}/${XSCTH_PROJ}_hwproj/*.bit ]; then
        generate_bin
    fi
}

do_install:append() {
    if [ -e ${XSCTH_WS}/${XSCTH_PROJ}_hwproj/*.bit ]; then
        install -d ${D}/${nonarch_base_libdir}/firmware/
        ln -s /var/lib/firmware/bitstream ${D}/${nonarch_base_libdir}/firmware/bitstream
        install -Dm 0644 ${XSCTH_WS}/*.bit.bin ${D}/${nonarch_base_libdir}/firmware/bitstream.bit.bin
        install -Dm 0644 ${XSCTH_WS}/${XSCTH_PROJ}_hwproj/*.bit ${D}/${nonarch_base_libdir}/firmware/bitstream.bit
    fi
}

do_deploy:append() {
    if [ -e ${XSCTH_WS}/${XSCTH_PROJ}_hwproj/*.bit ]; then
        install -Dm 0644 ${XSCTH_WS}/*.bit.bin ${DEPLOYDIR}/${BITSTREAM_BASE_NAME}.bit.bin
        ln -sf ${BITSTREAM_BASE_NAME}.bit.bin ${DEPLOYDIR}/bitstream.bit.bin
        ln -sf ${BITSTREAM_BASE_NAME}.bit ${DEPLOYDIR}/bitstream.bit
    fi
}

FILES:${PN} += "${nonarch_base_libdir}/firmware"
