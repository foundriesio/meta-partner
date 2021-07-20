FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8mm-var-dart = " \
    file://imx8mm-var-som-symphony.dts \
    file://imx8mm-var-som.dtsi \
"

devicetree_do_deploy_append() {
    for DTB_FILE in `ls *.dtb *.dtbo`; do
        install -Dm 0644 ${B}/${DTB_FILE} ${DEPLOYDIR}/${DTB_FILE}
    done
}

COMPATIBLE_MACHINE_imx8mm-var-dart = ".*"
