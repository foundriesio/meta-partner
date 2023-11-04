# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask stm32 tf-a recipe for now (LmP masks the original recipe)
# Mask the addition of fw_env.config, LmP uses u-boot-fw-tools
BBMASK += " \
    /meta-phytec/dynamic-layers/stm-st-stm32mp/recipes-bsp/trusted-firmware-a/tf-a-stm32mp_%.bbappend \
    /meta-phytec/recipes-bsp/u-boot/libubootenv_%.bbappend \
"

# REVERTME: Workaround for BBMASK reassignment in meta-phytec
include bbmask-fix.inc

# meta-clang:kirkstone: clang is not ready to be used for linux kernel:
# commit 299a5fd ("linux-yocto: Use binutils provided strip")
# We have to remove using clang tools objcopy and strip for all LmP linux
# kernel recipes to avoid building errors like:
# aarch64-lmp-linux-llvm-strip: error: Link field value 30 in section .rela.dyn is not a symbol table
# do_assemble_fitimage.520200: 841: arm-lmp-linux-gnueabi-llvm-objcopy: not found
OBJCOPY:pn-linux-lmp-ti:toolchain-clang = "${HOST_PREFIX}objcopy"
STRIP:pn-linux-lmp-ti:toolchain-clang = "${HOST_PREFIX}strip"
OBJCOPY:pn-linux-lmp-phytec-imx:toolchain-clang = "${HOST_PREFIX}objcopy"
STRIP:pn-linux-lmp-phytec-imx:toolchain-clang = "${HOST_PREFIX}strip"

# Phytec phyBOARD-Lyra TI AM62x
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-1-k3r5 = ""
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-2-k3r5 = ""
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-3-k3r5 = ""
BBMULTICONFIG:remove:phyboard-lyra = "k3r5"
BBMULTICONFIG:append:phyboard-lyra = " lmp-k3r5"
SOTA_CLIENT_FEATURES:append:phyboard-lyra = " ubootenv"
PREFERRED_PROVIDER_u-boot-fw-utils:phyboard-lyra = "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils:phyboard-lyra = "libubootenv"
# only need boot script for sota builds
WKS_FILE_DEPENDS:append:sota:phyboard-lyra = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:sota:phyboard-lyra = "u-boot-ostree-scr-fit"
IMAGE_BOOT_FILES:remove:phyboard-lyra = "oftree"
UBOOT_ENTRYPOINT:phyboard-lyra = "0x82000000"
UBOOT_LOADADDRESS:phyboard-lyra = "0x82000000"
UBOOT_DTB_LOADADDRESS:phyboard-lyra = "0x88000000"
EFI_PROVIDER:phyboard-lyra = ""
KERNEL_DEVICETREE:append:phyboard-lyra = " ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'ti/k3-am625-base-board-jailhouse.dtbo', '', d)}"
PREFERRED_PROVIDER_virtual/kernel:sota:phyboard-lyra = "linux-lmp-ti"
OSTREE_KERNEL_ARGS:phyboard-lyra ?= "console=ttyS2,115200n8 ${OSTREE_KERNEL_ARGS_COMMON}"

# Phytec phyBOARD-Pollux i.MX 8MPlus
MACHINE_FEATURES:append:phyboard-pollux-imx8mp-3 = " optee"
SOTA_CLIENT_FEATURES:append:phyboard-pollux-imx8mp-3 = " ubootenv"
PREFERRED_PROVIDER_u-boot-fw-utils:phyboard-pollux-imx8mp-3 = "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils:phyboard-pollux-imx8mp-3 = "libubootenv"
PREFERRED_PROVIDER_virtual/bootloader:phyboard-pollux-imx8mp-3 ?= "u-boot-fio"
UBOOT_MACHINE:phyboard-pollux-imx8mp-3 = "phycore-imx8mp_defconfig"
BOOTSCR_LOAD_ADDR:phyboard-pollux-imx8mp-3 = "0x44800000"
IMX_BOOT_SOC_TARGET:phyboard-pollux-imx8mp-3 = "iMX8MP"
IMX_BOOT_SEEK:phyboard-pollux-imx8mp-3 = "32"
IMAGE_BOOT_FILES:sota:phyboard-pollux-imx8mp-3 = "boot.itb"
PREFERRED_PROVIDER_u-boot-default-script:sota:phyboard-pollux-imx8mp-3 = "u-boot-ostree-scr-fit"
OPTEEMACHINE:phyboard-pollux-imx8mp-3 = "imx-mx8mpevk"
PREFERRED_PROVIDER_virtual/kernel:phyboard-pollux-imx8mp-3 = "linux-lmp-phytec-imx"
KERNEL_DEVICETREE:phyboard-pollux-imx8mp-3 = "freescale/imx8mp-phyboard-pollux-rdk.dtb"
KMACHINE:phyboard-pollux-imx8mp-3 = "phyboard-pollux-imx8mp-3"
WKS_FILES:sota:phyboard-pollux-imx8mp-3 = "sdimage-imx8-spl-sota.wks.in"
OSTREE_KERNEL_ARGS:phyboard-pollux-imx8mp-3 ?= "console=tty1 console=ttymxc0,115200 earlycon=ec_imx6q,0x30860000,115200 rootfstype=ext4"
# Phytec phyBOARD-Pollux i.MX 8MPlus with secure boot support
SOTA_CLIENT_FEATURES:remove:phyboard-pollux-imx8mp-3-sec = "ubootenv"
