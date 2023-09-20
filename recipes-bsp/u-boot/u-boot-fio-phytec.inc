FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

UBOOT_REPO = "git://git.phytec.de/u-boot-imx.git"
SRCREV = "1bd482665d236089202c3ef4a8721064a540e769"
SRCBRANCH = "v2021.04_2.2.0-phy"
# base NXP/IMX u-boot release
UBOOT_IMX_VER = "2021.04-lf-5.10.72-2.2.0"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

require u-boot-fio-${UBOOT_IMX_VER}.inc

SRC_URI:append:phyboard-pollux-imx8mp-3 = " \
    file://0001-FIO-internal-arch-arm-dts-imx8mp-pollux-disable-unne.patch \
    file://0002-FIO-internal-board-phytec-phycore_imx8mp-enable-boot.patch \
    file://0003-FIO-internal-phycore_imx8mp-runtime-detection-raw-se.patch \
    file://0004-FIO-internal-phycore_imx8mp-fix-SPL-stack-size-and-B.patch \
    file://0005-FIO-internal-phycore_imx8mp-allow-setting-CONFIG_BOO.patch \
    file://0001-FIO-internal-arch-arm-dts-imx8mp-phyboard-pollux-ena.patch \
"
