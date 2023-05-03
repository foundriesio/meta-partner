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
    file://0019-imx8m-soc.c-fixed-duplicate-definition-of-get_effect.patch \
    file://0020-imx8m-dram-Add-an-empty-entry-for-OPTEE-at-MMU-table.patch \
    file://0021-variscite-extcon-ptn5150-add-ptn5150-driver.patch \
"

SRC_URI:append:imx8mm-var-som-symphony = " \
    file://0001-imx8mm_var_dart-Add-support-for-Variscite-DART-MX8M-.patch \
    file://0002-imx8mm_var_dart-align-with-the-reference-NXP-EVK.patch \
    file://0003-imx8mm_var_dart-add-cma_name.patch \
    file://0004-imx8mm_var_dart-set-CONFIG_SYS_LOAD_ADDR-as-in-lf_v2.patch \
    file://0005-imx8mm_var_dart-align-with-the-nxp-defconfig-to-fix-.patch \
    file://0006-imx8mm_var_dart-disable-CONFIG_EFI_MM_COMM_TEE.patch \
    file://0007-imx8mm_var_dart-disable-EFI-flags.patch \
    file://0008-imx8mm_var_dart-allow-cma-address-to-be-dynamically-.patch \
    file://0009-imx8mm_var_dart-reduce-cma-size-for-1GB-SOM.patch \
    file://0010-imx8mm_var_dart-adjust-ddrc_opp_table-for-DDR4-on-VA.patch \
    file://0011-imx8mm_var_dart-Drop-redundant-legacy-DT-file.patch \
    file://0012-imx8mm_var_dart-disable-OPTEE-lib-by-default.patch \
"

SRC_URI:append:imx8mn-var-som = " \
    file://0001-Revert-imx8mn_var_som-Add-support-for-Variscite-VAR-.patch \
    file://0002-Add-support-for-Variscite-s-VAR-SOM-MX8M-NANO.patch \
    file://0003-imx8mn_var_som-align-with-the-reference-NXP-EVK.patch \
    file://0004-mach-imx8m-imx8mn_var_som-select-IMX_REDUCE_DMEM_PAD.patch \
"
