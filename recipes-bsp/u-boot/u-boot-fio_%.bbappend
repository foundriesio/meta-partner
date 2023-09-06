FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include u-boot-fio-phytec.inc

SRC_URI:append:phyboard-pollux-imx8mp-3 = " \
    file://lmp.cfg \
    file://fw_env.config \
"
