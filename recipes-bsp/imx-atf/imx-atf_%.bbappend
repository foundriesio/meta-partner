# add OP-TEE setting for VAR-SOM-MX8M-NANO
EXTRA_OEMAKE:append:fio-imx8mn-var-som = " \
    BL32_BASE=0x56000000 \
"
