FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:mx8m-var = " \
    file://0001-imx8m-Adjust-struct-dram_timing_info-to-match-u-boot.patch \
"

SRC_URI:append:imx8mm-var-som-symphony = " \
    file://0001-imx8mm-Remove-uart2-and-uart4-domain-restrictions.patch \
"

SRC_URI:append:imx8mn-var-som = " \
    file://0001-imx8mn-Remove-uart2-and-uart4-domain-restrictions.patch \
"

EXTRA_OEMAKE:append = " \
    IMX_BOOT_UART_BASE="0x30a60000" \
"
