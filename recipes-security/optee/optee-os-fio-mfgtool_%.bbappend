require optee-os-variscite.inc

# Set size for force load to 0x56000000 for all DDR sizes
EXTRA_OEMAKE:append:mx8m-var = " \
    CFG_DDR_SIZE=0x18000000 \
"

EXTRA_OEMAKE:append:imx8mm-var-som-symphony = " \
    CFG_UART_BASE=UART4_BASE \
"

EXTRA_OEMAKE:append:imx8mn-var-som = " \
    CFG_UART_BASE=UART4_BASE \
"
