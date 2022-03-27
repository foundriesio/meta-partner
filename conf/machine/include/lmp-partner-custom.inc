# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# TODO: upstream to meta-lmp
# i.MX8M Nano settings
UBOOT_SIGN_ENABLE_sota_mx8mn = "1"
IMX_DEFAULT_BOOTLOADER_mx8mn ?= "u-boot-fio"
UBOOT_DTB_LOADADDRESS_mx8mn = "0x43000000"
PREFERRED_PROVIDER_virtual/trusted-firmware-a_mx8mn ?= "imx-atf"
EXTRA_IMAGEDEPENDS_append_mx8mn = "virtual/trusted-firmware-a"
UBOOT_CLASSES_mx8mn = "uboot-fitimage"
ATF_BINARY_mx8mn = "arm-trusted-firmware.bin"
UBOOT_CONFIG_mx8mn = ""
LMP_BOOT_FIRMWARE_FILES_mx8mn = "imx-boot u-boot.itb"
IMAGE_BOOT_FILES_mx8mn = "imx-boot u-boot.itb ${KERNEL_IMAGETYPE} ${@make_dtb_boot_files(d)} boot.scr uEnv.txt"
IMAGE_BOOT_FILES_sota_mx8mn = "boot.itb"
WKS_FILE_DEPENDS_append_mx8mn = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script_mx8mn = "u-boot-base-scr"
PREFERRED_PROVIDER_u-boot-default-script_sota_mx8mn = "u-boot-ostree-scr-fit"
KERNEL_IMAGETYPE_sota_mx8mn = "fitImage"
KERNEL_CLASSES_sota_mx8mn = " kernel-lmp-fitimage "
## iMX8: Use latest NXP BSP downstream kernel
PREFERRED_PROVIDER_virtual/kernel_mx8mn ?= "linux-lmp-fslc-imx"
MACHINE_FIRMWARE_mx8mn = "linux-firmware-imx-sdma-imx7d"
WKS_FILE_sota_mx8mn = "sdimage-imx8-spl-sota.wks.in"
IMXBOOT_TARGETS_mx8mn = "flash_evk_spl"

# Variscite settings
BOOTSCR_LOAD_ADDR_mx8m-var = "0x44800000"
PREFERRED_PROVIDER_virtual/dtb_mx8m-var = "lmp-device-tree"
SOTA_CLIENT_FEATURES_append_mx8m-var = " ubootenv"
KERNEL_MODULE_AUTOLOAD_mx8m-var = "i2c-dev"

# iMX8M Mini Var DART/Symphony
OSTREE_KERNEL_ARGS_imx8mm-var-som-symphony = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
UBOOT_MACHINE_imx8mm-var-som-symphony = "imx8mm_var_dart_defconfig"
IMAGE_BOOT_FILES_imx8mm-var-som-symphony = "imx-boot u-boot.itb ${KERNEL_IMAGETYPE} boot.scr uEnv.txt devicetree/*"

# iMX8M Nano Var Symphony
OSTREE_KERNEL_ARGS_imx8mn-var-som = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
UBOOT_MACHINE_imx8mn-var-som = "imx8mn_var_som_defconfig"
IMAGE_BOOT_FILES_append_lmp-base_imx8mn-var-som = " devicetree/variscite_imx8mn-var-som-symphony.dtb;imx8mn-var-som-symphony.dtb"
