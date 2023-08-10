# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask stm32 tf-a recipe for now (LmP masks the original recipe)
# Mask the addition of fw_env.config, LmP uses u-boot-fw-tools
BBMASK += " \
    /meta-phytec/dynamic-layers/stm-st-stm32mp/recipes-bsp/trusted-firmware-a/tf-a-stm32mp_%.bbappend \
    /meta-phytec/recipes-bsp/u-boot/libubootenv_%.bbappend \
"

# meta-clang:kirkstone: clang is not ready to be used for linux kernel:
# commit 299a5fd ("linux-yocto: Use binutils provided strip")
# We have to remove using clang tools objcopy and strip for all LmP linux
# kernel recipes to avoid building errors like:
# aarch64-lmp-linux-llvm-strip: error: Link field value 30 in section .rela.dyn is not a symbol table
# do_assemble_fitimage.520200: 841: arm-lmp-linux-gnueabi-llvm-objcopy: not found
OBJCOPY:pn-linux-lmp-ti:toolchain-clang = "${HOST_PREFIX}objcopy"
STRIP:pn-linux-lmp-ti:toolchain-clang = "${HOST_PREFIX}strip"

# Phytec phyBOARD-Lyra TI AM62x (Rev1 GP)
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-1-k3r5 = ""
BBMULTICONFIG:remove:phyboard-lyra-am62xx-1 = "k3r5"
BBMULTICONFIG:append:phyboard-lyra-am62xx-1 = " lmp-k3r5"
MACHINE_FEATURES:append:phyboard-lyra-am62xx-1 = " optee"
SOTA_CLIENT_FEATURES:append:phyboard-lyra-am62xx-1 = " ubootenv"
PREFERRED_PROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-1 = "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-1 = "libubootenv"
# only need boot script for sota builds
WKS_FILE_DEPENDS:append:sota:phyboard-lyra-am62xx-1 = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:sota:phyboard-lyra-am62xx-1 = "u-boot-ostree-scr-fit"
KERNEL_CLASSES:sota:phyboard-lyra-am62xx-1 = " kernel-lmp-fitimage "
IMAGE_BOOT_FILES:append:phyboard-lyra-am62xx-1 = " boot.itb"
IMAGE_BOOT_FILES:remove:phyboard-lyra-am62xx-1 = "oftree"
UBOOT_ENTRYPOINT:phyboard-lyra-am62xx-1 = "0x82000000"
UBOOT_LOADADDRESS:phyboard-lyra-am62xx-1 = "0x82000000"
UBOOT_DTB_LOADADDRESS:phyboard-lyra-am62xx-1 = "0x88000000"
EFI_PROVIDER:phyboard-lyra-am62xx-1 = ""
KERNEL_DEVICETREE:append:phyboard-lyra-am62xx-1 = " ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'ti/k3-am625-base-board-jailhouse.dtbo', '', d)}"
LMP_BOOT_FIRMWARE_FILES:phyboard-lyra-am62xx-1 = "tispl.bin u-boot.img"
LMP_BOOT_FIRMWARE_FILES:append:sota:phyboard-lyra-am62xx-1 = " boot.itb"
PREFERRED_PROVIDER_virtual/kernel:sota:phyboard-lyra-am62xx-1 = "linux-lmp-ti"
OSTREE_KERNEL_ARGS:phyboard-lyra-am62xx-1 ?= "console=ttyS2,115200n8 ${OSTREE_KERNEL_ARGS_COMMON}"

# Phytec phyBOARD-Lyra TI AM62x (Rev2 GP w/ PMIC)
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-2-k3r5 = ""
BBMULTICONFIG:remove:phyboard-lyra-am62xx-2 = "k3r5"
BBMULTICONFIG:append:phyboard-lyra-am62xx-2 = " lmp-k3r5"
MACHINE_FEATURES:append:phyboard-lyra-am62xx-2 = " optee"
SOTA_CLIENT_FEATURES:append:phyboard-lyra-am62xx-2 = " ubootenv"
PREFERRED_PROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-2 = "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-2 = "libubootenv"
# only need boot script for sota builds
WKS_FILE_DEPENDS:append:sota:phyboard-lyra-am62xx-2 = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:sota:phyboard-lyra-am62xx-2 = "u-boot-ostree-scr-fit"
KERNEL_CLASSES:sota:phyboard-lyra-am62xx-2 = " kernel-lmp-fitimage "
IMAGE_BOOT_FILES:append:phyboard-lyra-am62xx-2 = " boot.itb"
IMAGE_BOOT_FILES:remove:phyboard-lyra-am62xx-2 = "oftree"
UBOOT_ENTRYPOINT:phyboard-lyra-am62xx-2 = "0x82000000"
UBOOT_LOADADDRESS:phyboard-lyra-am62xx-2 = "0x82000000"
UBOOT_DTB_LOADADDRESS:phyboard-lyra-am62xx-2 = "0x88000000"
EFI_PROVIDER:phyboard-lyra-am62xx-2 = ""
KERNEL_DEVICETREE:append:phyboard-lyra-am62xx-2 = " ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'ti/k3-am625-base-board-jailhouse.dtbo', '', d)}"
LMP_BOOT_FIRMWARE_FILES:phyboard-lyra-am62xx-2 = "tispl.bin u-boot.img"
LMP_BOOT_FIRMWARE_FILES:append:sota:phyboard-lyra-am62xx-2 = " boot.itb"
PREFERRED_PROVIDER_virtual/kernel:sota:phyboard-lyra-am62xx-2 = "linux-lmp-ti"
OSTREE_KERNEL_ARGS:phyboard-lyra-am62xx-2 ?= "console=ttyS2,115200n8 ${OSTREE_KERNEL_ARGS_COMMON}"

# Phytec phyBOARD-Lyra TI AM62x (Rev3 FS w/ PMIC)
SSTATE_ALLOW_OVERLAP_FILES_K3R5:phyboard-lyra-am62xx-3-k3r5 = ""
BBMULTICONFIG:remove:phyboard-lyra-am62xx-3 = "k3r5"
BBMULTICONFIG:append:phyboard-lyra-am62xx-3 = " lmp-k3r5"
MACHINE_FEATURES:append:phyboard-lyra-am62xx-3 = " optee"
SOTA_CLIENT_FEATURES:append:phyboard-lyra-am62xx-3 = " ubootenv"
PREFERRED_PROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-3 = "libubootenv"
PREFERRED_RPROVIDER_u-boot-fw-utils:phyboard-lyra-am62xx-3 = "libubootenv"
# only need boot script for sota builds
WKS_FILE_DEPENDS:append:sota:phyboard-lyra-am62xx-3 = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:sota:phyboard-lyra-am62xx-3 = "u-boot-ostree-scr-fit"
KERNEL_CLASSES:sota:phyboard-lyra-am62xx-3 = " kernel-lmp-fitimage "
IMAGE_BOOT_FILES:append:phyboard-lyra-am62xx-3 = " boot.itb"
IMAGE_BOOT_FILES:remove:phyboard-lyra-am62xx-3 = "oftree"
UBOOT_ENTRYPOINT:phyboard-lyra-am62xx-3 = "0x82000000"
UBOOT_LOADADDRESS:phyboard-lyra-am62xx-3 = "0x82000000"
UBOOT_DTB_LOADADDRESS:phyboard-lyra-am62xx-3 = "0x88000000"
EFI_PROVIDER:phyboard-lyra-am62xx-3 = ""
KERNEL_DEVICETREE:append:phyboard-lyra-am62xx-3 = " ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', 'ti/k3-am625-base-board-jailhouse.dtbo', '', d)}"
LMP_BOOT_FIRMWARE_FILES:phyboard-lyra-am62xx-3 = "tispl.bin u-boot.img"
LMP_BOOT_FIRMWARE_FILES:append:sota:phyboard-lyra-am62xx-3 = " boot.itb"
PREFERRED_PROVIDER_virtual/kernel:sota:phyboard-lyra-am62xx-3 = "linux-lmp-ti"
OSTREE_KERNEL_ARGS:phyboard-lyra-am62xx-3 ?= "console=ttyS2,115200n8 ${OSTREE_KERNEL_ARGS_COMMON}"

# Fix do_deploy error
# Adjust lines from: meta-phytec/conf/machine/include/phyk3.inc
do_image_wic[mcdepends] = "mc::lmp-k3r5:ti-sci-fw:do_deploy"
do_image_tar[mcdepends] = "mc::lmp-k3r5:ti-sci-fw:do_deploy"
