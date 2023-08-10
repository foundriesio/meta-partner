# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Customizations for the mediatek BSP
PREFERRED_PROVIDER_virtual/kernel:mtk = "linux-lmp-mtk"
KERNEL_CLASSES:mtk = "kernel-lmp-fitimage"
WKS_FILE_DEPENDS:append:mtk = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:mtk = "u-boot-ostree-scr-fit"
SOTA_CLIENT_FEATURES:append:mtk = " ubootenv"
OSTREE_KERNEL_ARGS:mtk ?= "console=ttyS0,921600 ${OSTREE_KERNEL_ARGS_COMMON}"
IMAGE_BOOT_FILES:mtk = "boot.itb"
WKS_FILE:sota:mtk = "sdimage-mediatek-sota.wks.in"
## EBBR compatiblity
UBOOT_SIGN_ENABLE:sota:i1200-demo-ebbr = ""
KERNEL_IMAGETYPE:sota:i1200-demo-ebbr ?= "Image"
KERNEL_CLASSES:sota:i1200-demo-ebbr ?= ""
EFI_PROVIDER:i1200-demo-ebbr ?= "grub-efi"
OSTREE_BOOTLOADER:i1200-demo-ebbr ?= "grub"
IMAGE_EFI_BOOT_FILES:sota:i1200-demo-ebbr ?= "${@make_efi_dtb_boot_files(d)}"
WKS_FILE:sota:i1200-demo-ebbr ?= "sdimage-mediatek-efi-sota.wks.in"
### Required as it currently depends on meta-intel (sbsigntool)
CORE_IMAGE_BASE_INSTALL:remove:i1200-demo-ebbr = "efitools"

## Clang overrides for mediatek
TOOLCHAIN:pn-lk = "gcc"
TOOLCHAIN:pn-lk-prebuilt = "gcc"
TOOLCHAIN:pn-bl2 = "gcc"
TOOLCHAIN:pn-bl2-prebuilt = "gcc"

# Mask TI recipe with missing include file
# Mask STM recipe which doesn't exist when meta layer is dropped
BBMASK += " \
    /meta-lmp-bsp/recipes-kernel/linux/linux-lmp-ti-staging_git.bb \
    /meta-lmp-bsp/recipes-bsp/alsa/alsa-state-stm32mp1.bbappend \
"
