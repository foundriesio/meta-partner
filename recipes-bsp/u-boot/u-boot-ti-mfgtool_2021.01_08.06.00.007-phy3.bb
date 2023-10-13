SUMMARY = "Produces a Manufacturing Tool compatible U-Boot"
DESCRIPTION = "U-Boot recipe that produces a Manufacturing Tool compatible \
binary to be used in updater environment"

require dynamic-layers/meta-ti-bsp/recipes-bsp/u-boot/u-boot-ti_2021.01_08.06.00.007-phy3.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-ti:"

include recipes-bsp/u-boot/u-boot-lmp-common.inc

PACKAGECONFIG[optee] = "TEE=${STAGING_DIR_HOST}${nonarch_base_libdir}/firmware/tee-pager_v2.bin.signed,,${PREFERRED_PROVIDER_virtual/optee-os}"

# Environment config is not required for mfgtool
SRC_URI:remove = "file://fw_env.config"
SRC_URI:remove = "file://lmp.cfg"

SRC_URI:append = " \
    file://0001-phycore_am62x-set-bootm-len-to-64M.patch \
    file://0001-phytec_am6-enable-DFU-RAM-env-settings.patch \
    file://0002-arm-dts-k3-am62-phycore-enable-usb0-for-DFU.patch \
    file://lmp-mfgtool.cfg \
    file://dfu.cfg \
"
