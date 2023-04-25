FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_mx8m-var = " \
    file://0001-imx8m-Adjust-struct-dram_timing_info-to-match-u-boot.patch \
"

SRC_URI_append_imx8mm-var-som-symphony = " \
    file://0001-imx8mm-Remove-uart2-and-uart4-domain-restrictions.patch \
    file://0001-imx8mm-set-IMX_BOOT_UART_BASE-to-use-UART4.patch \
"

SRC_URI_append_imx8mn-var-som = " \
    file://0001-imx8mn-Remove-uart2-and-uart4-domain-restrictions.patch \
    file://0002-imx8mn-set-IMX_BOOT_UART_BASE-to-use-UART4.patch \
"
