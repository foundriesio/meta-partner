FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${THISDIR}/u-boot-fio:"

include u-boot-fio-toradex.inc

PROVIDES:append = " u-boot-mfgtool"
