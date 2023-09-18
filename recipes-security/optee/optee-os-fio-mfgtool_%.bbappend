require optee-os-fio-phytec.inc

# Extra Settings for Secure Machines
EXTRA_OEMAKE:append:phyboard-pollux-imx8mp-3-sec = " \
    CFG_RPMB_WRITE_KEY=y \
"
