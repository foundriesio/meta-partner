# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# iMX8MM Var DART
OSTREE_KERNEL_ARGS_imx8mm-var-som-symphony = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
PREFERRED_PROVIDER_virtual/dtb_imx8mm-var-som-symphony = "lmp-device-tree"
SOTA_CLIENT_FEATURES_append_imx8mm-var-som-symphony = " ubootenv"
UBOOT_MACHINE_imx8mm-var-som-symphony = "imx8mm_var_dart_defconfig"
BOOTSCR_LOAD_ADDR_imx8mm-var-som-symphony = "0x44800000"

IMAGE_BOOT_FILES_imx8mm-var-som-symphony = "imx-boot u-boot.itb ${KERNEL_IMAGETYPE} boot.scr uEnv.txt devicetree/*"

KERNEL_MODULE_AUTOLOAD_imx8mm-var-som-symphony = "i2c-dev"
