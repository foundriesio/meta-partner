# iMX8MN
UBOOT_SIGN_ENABLE_mx8mn = "1"
IMX_DEFAULT_BOOTLOADER_mx8mn ?= "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot-default-script_mx8mn = "u-boot-ostree-scr"
IMAGE_BOOT_FILES_mx8mn  = "imx-boot u-boot.itb boot.itb"
KERNEL_IMAGETYPE_mx8mn = "fitImage"
KERNEL_CLASSES_mx8mn = " kernel-lmp-fitimage "
