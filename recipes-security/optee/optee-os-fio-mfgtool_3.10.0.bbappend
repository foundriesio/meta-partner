OPTEEMACHINE_imx8mm-var-dart = "imx-mx8mmevk"

EXTRA_OEMAKE_append_imx8mm-var-dart = " \
    CFG_UART_BASE=UART4_BASE \
    CFG_CORE_DYN_SHM=n CFG_DT=y CFG_EXTERNAL_DTB_OVERLAY=y CFG_DT_ADDR=0x43200000 \
"
