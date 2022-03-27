OPTEEMACHINE_imx8mm-var-som-symphony = "imx-mx8mmevk"
OPTEEMACHINE_imx8mn-var-som = "imx-mx8mnevk"

EXTRA_OEMAKE_append_imx8mm-var-som-symphony = " \
    CFG_UART_BASE=UART4_BASE \
"

EXTRA_OEMAKE_append_imx8mn-var-som = " \
    CFG_TZDRAM_START=0x56000000 \
    CFG_UART_BASE=UART4_BASE \
"
