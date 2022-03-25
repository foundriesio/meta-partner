# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Variscite settings
BOOTSCR_LOAD_ADDR_mx8m-var = "0x44800000"
PREFERRED_PROVIDER_virtual/dtb_mx8m-var = "lmp-device-tree"
SOTA_CLIENT_FEATURES_append_mx8m-var = " ubootenv"
KERNEL_MODULE_AUTOLOAD_mx8m-var = "i2c-dev"

# iMX8M Mini Var DART/Symphony
OSTREE_KERNEL_ARGS_imx8mm-var-som-symphony = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
UBOOT_MACHINE_imx8mm-var-som-symphony = "imx8mm_var_dart_defconfig"
IMAGE_BOOT_FILES_imx8mm-var-som-symphony = "imx-boot u-boot.itb ${KERNEL_IMAGETYPE} boot.scr uEnv.txt devicetree/*"
