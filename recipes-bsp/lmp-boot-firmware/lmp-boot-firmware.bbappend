do_install[depends] += "${@bb.utils.contains('WKS_FILE_DEPENDS', 'imx-boot', 'imx-boot:do_deploy', '', d)}"
