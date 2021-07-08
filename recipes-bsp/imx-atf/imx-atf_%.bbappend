FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8mm-var-dart = " \
    file://0001-imx8m-Adjust-struct-dram_timing_info-to-match-u-boot.patch \
    file://0001-imx8mm-Remove-uart2-and-uart4-domain-restrictions.patch \
    file://0001-imx8mm-set-IMX_BOOT_UART_BASE-to-use-UART4.patch \
"
