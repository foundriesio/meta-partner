# iMX8MN
UBOOT_SIGN_ENABLE:mx8mn = "1"
IMX_DEFAULT_BOOTLOADER:mx8mn ?= "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot-default-script:mx8mn = "u-boot-ostree-scr"
IMAGE_BOOT_FILES:mx8mn  = "imx-boot u-boot.itb boot.itb"
KERNEL_IMAGETYPE:mx8mn = "fitImage"
KERNEL_CLASSES:mx8mn = " kernel-lmp-fitimage "
