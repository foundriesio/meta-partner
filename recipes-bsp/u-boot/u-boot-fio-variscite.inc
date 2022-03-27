SRC_URI_append_mx8m-var = " \
    file://0001-imx8m-drivers-ddr-Add-support-for-specifying-DDR-PHY.patch \
    file://0002-imx8m-drivers-ddr-Change-padding-of-DDR4-and-LPDDR4-.patch \
    file://0003-pmic-bd71837-Produce-less-verbose-output.patch \
    file://0004-usb-ehci-mx6-Fix-USB-type-detection.patch \
    file://0005-serial-mxc-Make-mxc_base-modifiable-by-external-code.patch \
    file://0006-imx8m-dram-Allow-overriding-DRAM-init-routines-in-bo.patch \
    file://0007-imx8m-dram-Use-maximum-possible-DRAM-bank-sizes.patch \
    file://0008-variscite-Add-common-MMC-code.patch \
    file://0009-variscite-Add-common-video-code.patch \
    file://0010-variscite-Add-common-ethernet-code.patch \
    file://0011-variscite-Add-common-EEPROM-code.patch \
    file://0012-variscite-Add-common-DRAM-code.patch \
    file://0013-variscite-imx8-Allow-overriding-DRAM-init-routines-i.patch \
    file://0014-variscite-imx8-Add-common-dram-code.patch \
    file://0015-variscite-imx8_eeprom-exposed-var_scu_eeprom_read_he.patch \
    file://0016-variscite-eeprom-Remove-redundant-extern-function-de.patch \
    file://0017-eeprom-Add-support-for-carrier-board-EEPROM.patch \
    file://0018-usb-gadget-Fix-ethernet-gadget-compilation-failure.patch \
"

SRC_URI_append_imx8mm-var-som-symphony = " \
    file://0001-imx8mm_var_dart-Add-Variscite-DART-MX8M-MINI-and.patch \
    file://0002-imx8mm-var-dart-Separate-som-and-carrier-device-tree.patch \
    file://0003-imx8mm-var-som-Separate-som-and-carrier-device-tree-.patch \
    file://0004-imx8mm-var-dart-Remove-support-for-VAR-SOM-MX8M-MINI.patch \
    file://0005-imx8mm-var-dart-Enable-PMIC-LDO5.patch \
    file://0006-imx8mm-var-dart-Add-support-for-VAR-SOM-MX8M-MINI-on.patch \
    file://0007-imx8mm-var-dart-Disable-SD-card-detect-pin-on-DART-M.patch \
    file://0008-imx8mm-var-dart-Add-support-for-DT8MCustomBoard-V2.0.patch \
    file://0009-imx8mm-var-dart-Recognize-VAR-SOM-MX8M-MINI-revision.patch \
    file://0010-imx8mm_var_dart-Set-console-environment-variable-in-.patch \
    file://0011-imx8-soms-Add-USE_EMMC_BOOT_PART-config-to-use-user.patch \
    file://0012-imx8mm-var-som-Use-default-DDR4-QoS-settings.patch \
    file://0051-board-variscite-imx8mm_var_dar-drop-do_reset-func.patch \
    file://0052-configs-imx8mm_var_dart-avoid-config-fallback-error.patch \
    file://0053-imx8mm_var_dart-force-to-use-the-uart-entry-for-the-.patch \
    file://0054-include-configs-imx8mm_var_dart-allow-setting-CONFIG.patch \
    file://0055-imx8mm_var_dart-define-CONFIG_SYS_BOOTM_LEN.patch \
    file://0056-imx8mm_var_dart-handle-CONFIG_SECONDARY_BOOT_RUNTIME.patch \
"
