SRC_URI:append:mx8m-var = " \
    file://0001-imx8m-drivers-ddr-Add-support-for-specifying-DDR-PHY.patch \
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
    file://0014-variscite-imx8-Add-common-dram-code.patch \
    file://0018-usb-gadget-Fix-ethernet-gadget-compilation-failure.patch \
"

SRC_URI:append:imx8mm-var-som-symphony = " \
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

SRC_URI:append:imx8mn-var-som = " \
    file://0001-imx8mn_var_som-Add-support-for-Variscite-VAR-SOM-MX8.patch \
    file://0002-imx8mn_var_som-Add-support-for-Android-10.0.0_2.3.0.patch \
    file://0003-imx8mn-var-som-Separate-som-and-carrier-device-tree-.patch \
    file://0004-imx8mn-var-som-Remove-support-for-VAR-SOM-MX8M-NANO-.patch \
    file://0005-imx8mn-var-som-Enable-PMIC-LDO5.patch \
    file://0006-imx8mn-var-som-Add-support-for-VAR-SOM-MX8M-NANO-on-.patch \
    file://0007-imx8mn-var-som-Disable-SD-card-detect-pin.patch \
    file://0008-imx8mn_var_som-Update-device-default-device-tree-nam.patch \
    file://0009-imx8mn-var-som-Recognize-VAR-SOM-MX8M-NANO-revisions.patch \
    file://0010-imx8mn-var-som-Move-CONFIG_CSF_SIZE-to-imx8mn_var_so.patch \
    file://0011-imx8mn-var-som-Add-support-for-Analog-Devices-ADIN13.patch \
    file://0051-imx8mn-var-som-drop-do_reset-and-spl_mmc_get_uboot_r.patch \
    file://0052-imx8mn-var-som-sync-defconfig-and-include-header-wit.patch \
    file://0053-imx8mn-var-som-drop-dm-spl-from-all-nodes.patch \
    file://0054-imx8mn-var-som-raise-NR_DRAM_BANKS-to-2.patch \
    file://0055-imx8mn-var-som-adjust-emmc-and-sd-dev.patch \
"
