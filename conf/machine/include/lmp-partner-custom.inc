# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Customizations for the mediatek BSP
PREFERRED_PROVIDER_virtual/kernel:mtk ?= "linux-mtk"
DISTRO_FEATURES_DEFAULT:remove:mtk = "modsign"
KERNEL_CLASSES:mtk = "kernel-lmp-fitimage"
WKS_FILE_DEPENDS:append:mtk = " u-boot-default-script"
PREFERRED_PROVIDER_u-boot-default-script:i1200-demo = "u-boot-ostree-scr-fit"
SOTA_CLIENT_FEATURES:append:mtk = " ubootenv"
OSTREE_KERNEL_ARGS:mtk ?= "console=ttyS0,921600 ${OSTREE_KERNEL_ARGS_COMMON}"
