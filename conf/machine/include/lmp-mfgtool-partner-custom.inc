# Apalis-iMX6
UBOOT_SIGN_ENABLE:apalis-imx6 = "1"
PREFERRED_PROVIDER_virtual/kernel:apalis-imx6 = "linux-lmp-dev-mfgtool"
PREFERRED_PROVIDER_virtual/bootloader:apalis-imx6 = "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot:apalis-imx6 = "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot-mfgtool:apalis-imx6 = "u-boot-fio-mfgtool"
UBOOT_CLASSES:apalis-imx6 = "uboot-fitimage"
IMAGE_BOOT_FILES:apalis-imx6 = "boot.itb SPL u-boot.itb"
KERNEL_IMAGETYPE:apalis-imx6 = "fitImage"
KERNEL_CLASSES:apalis-imx6 = " kernel-lmp-fitimage "

# Apalis-iMX8
PREFERRED_PROVIDER_virtual/bootloader:apalis-imx8 = "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot:apalis-imx8 = "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot-mfgtool:apalis-imx8 = "u-boot-fio-mfgtool"
