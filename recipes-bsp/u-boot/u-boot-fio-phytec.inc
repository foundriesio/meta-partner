UBOOT_REPO = "git://git.phytec.de/u-boot-imx.git"
SRCREV = "1bd482665d236089202c3ef4a8721064a540e769"
SRCBRANCH = "v2021.04_2.2.0-phy"
# base NXP/IMX u-boot release
UBOOT_IMX_VER = "2021.04-lf-5.10.72-2.2.0"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

require u-boot-fio-${UBOOT_IMX_VER}.inc
