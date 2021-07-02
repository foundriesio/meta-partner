FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-imx-mkimage-imx8m-soc.mak-add-variscite-imx8mm-suppo.patch \
    file://0001-test.patch \
"
