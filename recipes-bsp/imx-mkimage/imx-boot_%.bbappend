FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_mx8m = " \
    file://0001-imx-mkimage-imx8m-soc.mak-add-variscite-support-for-.patch \
"
