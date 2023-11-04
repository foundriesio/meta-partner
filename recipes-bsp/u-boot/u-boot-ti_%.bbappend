FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

SRC_URI:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'file://0003-HACK-lib-lmb-Allow-re-reserving-post-relocation-U-Bo.patch', '', d)} \
"

SRC_URI:append:phyboard-lyra = " \
    file://fw_env.config \
    file://lmp.cfg \
"

# fix prototype DTB used
SRC_URI:append:phyboard-lyra-am62xx-1 = " \
    file://dtb.cfg \
"

PACKAGECONFIG[optee] = "TEE=${STAGING_DIR_HOST}${nonarch_base_libdir}/firmware/tee-pager_v2.bin,,optee-os-fio"
