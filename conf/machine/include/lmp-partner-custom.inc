# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# iMX8MM Var DART
OSTREE_KERNEL_ARGS_imx8mm-var-dart = "console=tty0 console=ttymxc0,115200 earlycon=ec_imx6q,0x30890000,115200 root=/dev/mmcblk1p2 rootfstype=ext4"
PREFERRED_PROVIDER_virtual/dtb_imx8mm-var-dart = "lmp-device-tree"
PREFERRED_PROVIDER_virtual/trusted-firmware-a_imx8mm-var-dart = "imx-atf"
SOTA_CLIENT_FEATURES_append_imx8mm-var-dart = " ubootenv"
UBOOT_MACHINE_imx8mm-var-dart = "imx8mm_var_dart_defconfig"
