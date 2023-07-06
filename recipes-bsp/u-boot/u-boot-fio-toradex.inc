UBOOT_REPO = "git://git.toradex.com/u-boot-toradex.git"
SRCREV = "c71ae7141f30da99e2206a331ac821603f238fa7"
SRCBRANCH = "toradex_imx_lf_v2022.04"
# base NXP/IMX u-boot release
UBOOT_IMX_VER = "2022.04-lf-5.15.52-2.1.0"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=5a7450c57ffe5ae63fd732446b988025"

require u-boot-fio-${UBOOT_IMX_VER}.inc
require u-boot-fio-${UBOOT_IMX_VER}-toradex.inc
