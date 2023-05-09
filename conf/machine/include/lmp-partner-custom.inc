# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# TODO: nothing seems to provide this
MACHINE_EXTRA_RDEPENDS:remove = " \
        bluealsa \
"

# Mask missing / broken recipes
BBMASK += " \
    /meta-variscite-bsp/recipes-bsp/imx-mkimage/imx-boot_1.0.bbappend \
    /meta-variscite-bsp/recipes-connectivity/bluealsa/bluealsa_git.bbappend \
    /meta-variscite-bsp/recipes-core/systemd/systemd_%.bbappend \
    /meta-variscite-bsp/recipes-libraries/arm-compute-library/arm-compute-library_22.05.bbappend \
"

# General Variscite settings
PREFERRED_PROVIDER_virtual/bootloader:mx8m-var ?= "u-boot-fio"
PREFERRED_PROVIDER_u-boot:mx8m-var ?= "u-boot-fio"
PREFERRED_PROVIDER_virtual/kernel:mx8m-var = "linux-lmp-fslc-imx"
BOOTSCR_LOAD_ADDR:mx8m-var = "0x44800000"
SOTA_CLIENT_FEATURES:append:mx8m-var = " ubootenv"
KERNEL_MODULE_AUTOLOAD:mx8m-var = "i2c-dev"

# VAR-SOM-MX8M-MINI (DDR4)
OSTREE_KERNEL_ARGS:imx8mm-var-som-symphony = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
UBOOT_MACHINE:imx8mm-var-som-symphony = "imx8mm_var_dart_defconfig"
UBOOT_MAKE_TARGET:imx8mm-var-som-symphony = ""
# SOTA_CLIENT_FEATURES:append:imx8mm-var-som-symphony = " ubootenv"
OPTEE_BIN_EXT:imx8mm-var-som-symphony = "8mm"
IMXBOOT_TARGETS:imx8mm-var-som-symphony = "flash_evk_spl_ddr4"
MACHINE_FEATURES:append:imx8mm-var-som-symphony = " optee bcm4339 bcm43430"
ATF_BOOT_UART_BASE:imx8mm-var-som-symphony = "0x30a60000"

# VAR-SOM-MX8M-NANO
OSTREE_KERNEL_ARGS:fio-imx8mn-var-som = "console=tty1 console=ttymxc3,115200 earlycon=ec_imx6q,0x30a60000,115200 root=/dev/mmcblk2p2 rootfstype=ext4"
#PREFERRED_PROVIDER_virtual/bootloader:fio-imx8mn-var-som ?= "u-boot-fio"
#PREFERRED_PROVIDER_u-boot:fio-imx8mn-var-som ?= "u-boot-fio"
UBOOT_MACHINE:fio-imx8mn-var-som = "imx8mn_var_som_defconfig"
UBOOT_MAKE_TARGET:fio-imx8mn-var-som = ""
#PREFERRED_PROVIDER_virtual/kernel:fio-imx8mn-var-som = "linux-lmp-fslc-imx"
#SOTA_CLIENT_FEATURES:append:fio-imx8mn-var-som = " ubootenv"
OPTEE_BIN_EXT:fio-imx8mn-var-som = "8mn"
IMXBOOT_TARGETS:fio-imx8mn-var-som ?= "flash_evk_spl_ddr4"
MACHINE_FEATURES:append:fio-imx8mn-var-som = " optee bcm4339 bcm43430"
ATF_BOOT_UART_BASE:fio-imx8mn-var-som = "0x30a60000"
TEE_LOAD_ADDR:fio-imx8mn-var-som ?= "0x56000000"
