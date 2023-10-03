FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

SRC_URI:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'file://0003-HACK-lib-lmb-Allow-re-reserving-post-relocation-U-Bo.patch', '', d)} \
    file://0001-phycore_am62x-set-bootm-len-to-64M.patch \
    file://0001-phytec_am6-enable-DFU-RAM-env-settings.patch \
    file://0002-arm-dts-k3-am62-phycore-enable-usb0-for-DFU.patch \
"

SRC_URI:append:phyboard-lyra-am62xx-1 = " \
    file://fw_env.config \
    file://lmp.cfg \
"

SRC_URI:append:phyboard-lyra-am62xx-2 = " \
    file://fw_env.config \
    file://lmp.cfg \
"

SRC_URI:append:phyboard-lyra-am62xx-3 = " \
    file://fw_env.config \
    file://lmp.cfg \
"

SRC_URI:append:lmp-mfgtool:k3r5 = " file://dfu.cfg"

PACKAGECONFIG[optee] = "TEE=${STAGING_DIR_HOST}${nonarch_base_libdir}/firmware/tee-pager_v2.bin.signed,,optee-os-fio"
