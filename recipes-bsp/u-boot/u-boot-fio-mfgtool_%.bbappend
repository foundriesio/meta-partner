FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include u-boot-fio-phytec.inc

SRC_URI:append:phyboard-pollux-imx8mp-3 = " \
    file://0001-FIO-internal-arch-arm-spl-align-board_spl_fit_post_l.patch \
"
