FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

SRC_URI:append:i350-evk = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
SRC_URI:append:i350-pumpkin = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
SRC_URI:append:i1200-demo = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
