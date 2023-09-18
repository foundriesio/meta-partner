OPTEEMACHINE:phyboard-pollux-imx8mp-3 = "imx-mx8mpevk"

EXTRA_OEMAKE:append:phyboard-pollux-imx8mp-3 = " \
    CFG_UART_BASE=UART1_BASE \
    CFG_TZDRAM_START=0x56000000 \
"

# Extra Settings for Secure Machines
EXTRA_OEMAKE:append:phyboard-pollux-imx8mp-3-sec = " \
    CFG_REE_FS=n CFG_RPMB_FS=y CFG_RPMB_FS_DEV_ID=2 \
"
