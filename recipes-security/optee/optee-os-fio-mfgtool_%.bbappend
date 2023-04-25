OPTEEMACHINE:imx8mm-var-som-symphony = "imx-mx8mmevk"
OPTEEMACHINE:imx8mn-var-som = "imx-mx8mnevk"

EXTRA_OEMAKE:append:imx8mm-var-som-symphony = " \
    CFG_UART_BASE=UART4_BASE \
"

# Set size for force load to 0x56000000
EXTRA_OEMAKE:append:imx8mn-var-som = " \
    CFG_DDR_SIZE=0x18000000 \
    CFG_UART_BASE=UART4_BASE \
"
