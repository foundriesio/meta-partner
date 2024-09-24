# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask missing / broken recipes
BBMASK += " \
    /meta-toradex-bsp-common/recipes-bsp/u-boot/libubootenv_%.bbappend \
    /meta-toradex-nxp/recipes-kernel/linux-firmware/linux-firmware_%.bbappend \
"


# non-clangable settings
OBJCOPY:pn-linux-toradex-mainline:toolchain-clang = "${HOST_PREFIX}objcopy"
STRIP:pn-linux-toradex-mainline:toolchain-clang = "${HOST_PREFIX}strip"

# Toradex Apalis iMX6
UBOOT_SIGN_ENABLE:sota:apalis-imx6 = "1"
PREFERRED_PROVIDER_u-boot-default-script:apalis-imx6 = "u-boot-base-scr"
PREFERRED_PROVIDER_u-boot-default-script:sota:apalis-imx6 = "u-boot-ostree-scr-fit"
LMP_BOOT_FIRMWARE_FILES:apalis-imx6 = "SPL u-boot.itb"
IMAGE_BOOT_FILES:apalis-imx6 = "boot.scr uEnv.txt SPL u-boot.itb ${KERNEL_IMAGETYPE} ${@make_dtb_boot_files(d)}"
IMAGE_BOOT_FILES:remove:apalis-imx6 = "boot.scr-${MACHINE};boot.scr"
IMAGE_BOOT_FILES:sota:apalis-imx6 = "boot.itb"
KERNEL_IMAGETYPE:sota:apalis-imx6 = "fitImage"
KERNEL_CLASSES:sota:apalis-imx6 = " kernel-lmp-fitimage "
OSTREE_KERNEL_ARGS:apalis-imx6 ?= " \
    enable_wait_mode=off vmalloc=400M mxc_hdmi.only_cea=1 fbmem=32M \
    consoleblank=0 no_console_suspend=1 console=tty1 console=ttymxc0,115200 rootfstype=ext4 \
"
PREFERRED_PROVIDER_virtual/kernel:apalis-imx6 ?= "linux-toradex-mainline"
KERNEL_DEVICETREE:remove:apalis-imx6 = "imx6q-apalis-ixora-v1.2.dtb"
IMX_DEFAULT_BOOTLOADER:apalis-imx6 ?= "u-boot-fio"
SOTA_CLIENT_FEATURES:append:apalis-imx6 = " ubootenv"
UBOOT_SUFFIX:apalis-imx6 = "bin"
UBOOT_CLASSES:apalis-imx6 = "uboot-fitimage"
UBOOT_DTB_LOADADDRESS:apalis-imx6 = "0x15800000"
UBOOT_RD_LOADADDRESS:apalis-imx6 = "0x14000000"
UBOOT_DTB_NAME:apalis-imx6 ?= "imx6-apalis.dtb"
WKS_FILE:apalis-imx6 = "sdimage-imx6dq-spl-fit.wks"
WKS_FILES:sota:apalis-imx6 = "sdimage-imx6dq-spl-fit-sota.wks"
MACHINE_FEATURES:append:apalis-imx6 = " optee"
BOOTSCR_LOAD_ADDR:apalis-imx6 = "0x15000000"
PREFERRED_PROVIDER_virtual/dtb:use-mainline-bsp:apalis-imx6 ?= "device-tree-overlays-mainline"
EXTERNAL_KERNEL_DEVICETREE:sota:apalis-imx6 = "${DEPLOY_DIR_IMAGE}/overlays/"
MACHINE_FIRMWARE:remove:apalis-imx6 = "firmware-imx-epdc"
IMX_DEFAULT_BSP:apalis-imx6 = "mainline"
TORADEX_PRODUCT_IDS:apalis-imx6 = "0027 0028 0029 0035"

## Toradex Apalis iMX8QM
OSTREE_KERNEL_ARGS:apalis-imx8 ?= "pci=nomsi console=tty1 console=ttyLP1,115200 earlycon ${OSTREE_KERNEL_ARGS_COMMON}"
PREFERRED_PROVIDER_virtual/kernel:apalis-imx8 ?= "linux-lmp-toradex-imx"
PREFERRED_PROVIDER_virtual/bootloader:apalis-imx8 ?= "u-boot-fio"
PREFERRED_PROVIDER_u-boot:apalis-imx8 ?= "u-boot-fio"
UBOOT_SUFFIX:apalis-imx8 = "bin"
UBOOT_DTB_NAME:apalis-imx8 ?= "fsl-imx8qm-apalis.dtb"
SPL_BINARY:apalis-imx8 = "spl/u-boot-spl.bin"
IMAGE_FSTYPES:remove:apalis-imx8 = "teziimg"
IMAGE_CLASSES:remove:apalis-imx8 = "image_type_tezi"
MACHINE_FEATURES:append:apalis-imx8 = " optee"
IMAGE_BOOT_FILES:remove:apalis-imx8 = "boot.scr-${MACHINE};boot.scr"
PREFERRED_PROVIDER_virtual/dtb:apalis-imx8 ?= "device-tree-overlays"
EXTERNAL_KERNEL_DEVICETREE:sota:apalis-imx8 = "${DEPLOY_DIR_IMAGE}/overlays/"
MACHINE_FEATURES:append:apalis-imx8 = " nxp8997-pcie mxm-mwifiex-load"

# Toradex Apalis iMX6 with secure boot support
SOTA_CLIENT_FEATURES:remove:sota:apalis-imx6-sec = "ubootenv"

# Toradex Apalis iMX8 with secure boot support
SOTA_CLIENT_FEATURES:remove:sota:apalis-imx8-sec = "ubootenv"
# Set correct machine name for device-tree-overlays
MACHINE_PREFIX:apalis-imx8-sec = "apalis-imx8"
