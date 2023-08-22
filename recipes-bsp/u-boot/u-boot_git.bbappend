FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

inherit fio-u-boot-localversion

DEPENDS += "gnutls-native"

SRC_URI:append = " \
    file://0001-GENIO-mt8195-board-define-dfu_alt_info-for-capsule-u.patch \
    file://0002-GENIO-arm-mediatek-mt8195-support-CONFIG_SYSRESET.patch \
    file://0003-GENIO-arm-dts-mt8195-demo-add-psci-node.patch \
    file://0004-GENIO-mt8195-board-use-fixed-fw_images-definition.patch \
"

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
