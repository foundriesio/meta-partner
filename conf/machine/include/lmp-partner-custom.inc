# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

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
OSTREE_KERNEL_ARGS:apalis-imx6 ?= "console=tty1 console=ttymxc0,115200 rootfstype=ext4"
PREFERRED_PROVIDER_virtual/kernel:apalis-imx6 ?= "linux-lmp"
KERNEL_DEVICETREE:remove:apalis-imx6 = "imx6q-apalis-ixora-v1.2.dtb"
IMX_DEFAULT_BOOTLOADER:apalis-imx6 ?= "u-boot-fio"
SOTA_CLIENT_FEATURES:append:apalis-imx6 = " ubootenv"
UBOOT_CONFIG:apalis-imx6 = ""
UBOOT_SUFFIX:apalis-imx6 = "bin"
UBOOT_MACHINE:apalis-imx6 = "apalis_imx6_defconfig"
UBOOT_CLASSES:apalis-imx6 = "uboot-fitimage"
UBOOT_DTB_LOADADDRESS:apalis-imx6 = "0x15800000"
UBOOT_RD_LOADADDRESS:apalis-imx6 = "0x14000000"
WKS_FILE:apalis-imx6 = "sdimage-imx6dq-spl-fit.wks"
WKS_FILES:sota:apalis-imx6 = "sdimage-imx6dq-spl-fit-sota.wks"
MACHINE_FEATURES:append:apalis-imx6 = " optee"
BOOTSCR_LOAD_ADDR:apalis-imx6 = "0x15000000"

## Toradex Apalis iMX8QM
OSTREE_KERNEL_ARGS:apalis-imx8 ?= "pci=nomsi console=tty1 console=ttyLP1,115200 earlycon ${OSTREE_KERNEL_ARGS_COMMON}"
PREFERRED_PROVIDER_virtual/kernel:apalis-imx8 ?= "linux-lmp-toradex-imx"
UBOOT_CONFIG:apalis-imx8 = ""
UBOOT_SUFFIX:apalis-imx8 = "bin"
UBOOT_MACHINE:apalis-imx8 = "apalis-imx8_defconfig"

# Toradex Apalis iMX6 with secure boot support
SOTA_CLIENT_FEATURES:remove:sota:apalis-imx6-sec = "ubootenv"

# Toradex Apalis iMX8 with secure boot support
SOTA_CLIENT_FEATURES:remove:sota:apalis-imx8-sec = "ubootenv"
