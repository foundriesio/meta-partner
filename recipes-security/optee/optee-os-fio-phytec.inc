OPTEEMACHINE:phyboard-pollux-imx8mp-3 = "imx-mx8mpevk"

EXTRA_OEMAKE:append:phyboard-pollux-imx8mp-3 = " \
    CFG_UART_BASE=UART1_BASE \
    CFG_TZDRAM_START=0x56000000 \
"
