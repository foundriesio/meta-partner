FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include u-boot-fio-toradex.inc

PROVIDES:append = " u-boot-mfgtool"
