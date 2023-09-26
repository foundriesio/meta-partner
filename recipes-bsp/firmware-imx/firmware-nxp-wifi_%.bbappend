### LMP CHANGES

do_install:append () {
    # Use MRVL firmware for NXP Connectivity PCIE8997 (USB Bluetooth) firmware
    ln -frs ${D}${nonarch_base_libdir}/firmware/mrvl/pcieusb8997_combo_v4.bin ${D}${nonarch_base_libdir}/firmware/nxp/pcieusb8997_combo_v4.bin
    sed -i -e "s/pcieuart8997_combo_v4.bin/pcieusb8997_combo_v4.bin/g" ${D}${nonarch_base_libdir}/firmware/nxp//wifi_mod_para.conf
}

FILES:${PN}-nxp8997-pcie += " \
       ${nonarch_base_libdir}/firmware/nxp/pcieusb8997* \
"
