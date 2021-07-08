FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8mm-var-dart = " \
    file://imx8mm-var-som-symphony.dts \
"

COMPATIBLE_MACHINE_imx8mm-var-dart = ".*"
