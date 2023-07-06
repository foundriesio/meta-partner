OPTEEMACHINE:apalis-imx6 = "imx-mx6qapalis"
OPTEEMACHINE:apalis-imx8 = "imx-mx8qmmek"

# Machine Settings
EXTRA_OEMAKE:append:apalis-imx6 = " \
    CFG_DDR_SIZE=0x80000000 CFG_NS_ENTRY_ADDR=0x17800000 CFG_NXP_CAAM=y \
    CFG_TZDRAM_START=0x4e000000 CFG_DT=y CFG_OVERLAY_ADDR=0x16000000 \
"
EXTRA_OEMAKE:append:apalis-imx8 = " \
    CFG_UART_BASE=0x5a070000 \
    CFG_NXP_CAAM=y CFG_NXP_CAAM_RNG_DRV=y \
    CFG_WITH_SOFTWARE_PRNG=n CFG_CRYPTO_DRIVER=y CFG_HWRNG_PTA=y CFG_HWRNG_QUALITY=1024 \
"

# Extra Settings for Secure Machines
EXTRA_OEMAKE:append:apalis-imx6-sec = " \
    CFG_REE_FS=n CFG_RPMB_FS=y CFG_RPMB_FS_DEV_ID=2 \
"
EXTRA_OEMAKE:append:apalis-imx8-sec = " \
    CFG_REE_FS=n CFG_RPMB_FS=y CFG_RPMB_FS_DEV_ID=0 \
"
EXTRA_OEMAKE:append:lmp-mfgtool:apalis-imx6-sec = " \
    CFG_RPMB_WRITE_KEY=y \
"
EXTRA_OEMAKE:append:lmp-mfgtool:apalis-imx8-sec = " \
    CFG_RPMB_WRITE_KEY=y \
"
