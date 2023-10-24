FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

inherit fio-u-boot-localversion

DEPENDS += "gnutls-native"

SRC_URI:append:i1200-demo-ebbr = " \
    file://capsule_key.patch \
"

SRC_URI:append:i350-evk = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
SRC_URI:append:i350-pumpkin = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
SRC_URI:append:i1200-demo = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"

do_compile:prepend() {
    # UEFI Capsule Authentication
    if [ -f "${UEFI_SIGN_KEYDIR}/CRT.esl" ]; then
        cp ${UEFI_SIGN_KEYDIR}/CRT.esl ${B}
    fi
}
