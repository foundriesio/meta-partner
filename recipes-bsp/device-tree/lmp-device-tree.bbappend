FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:imx8mm-var-som-symphony = " \
    file://imx8mm-var-som-symphony.dts \
    file://imx8mm-var-som.dtsi \
"

SRC_URI:append:imx8mn-var-som = " \
    file://imx8mn-var-som.dtsi \
    file://variscite_imx8mn-var-som-symphony.dts \
    file://variscite_imx8mn-var-som-symphony-legacy.dts \
"

COMPATIBLE_MACHINE:imx8mm-var-som-symphony = ".*"
COMPATIBLE_MACHINE:imx8mn-var-som = ".*"
