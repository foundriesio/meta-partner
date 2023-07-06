FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-fio-2022.04-lf-5.15.52-2.1.0-toradex:"

SRC_URI:append = " \
    file://0002-FIO-extra-apalis_imx6-fix-redefinition-of-PHY_ANEG_T.patch \
    file://0004-FIO-internal-mx6-allow-redeclaration-of-get_board_se.patch \
    file://0005-FIO-fromlist-apalis_imx6-allocate-specific-region-of.patch \
    file://0014-FIO-extras-arm-apalis_imx6-simplify-boot-targets.patch \
    file://0091-FIO-internal-arch-arm-dts-imx6-apalis-u-boot-Add-RPM.patch \
    file://0097-FIO-toup-ARM-dts-fsl-imx8qm-apalis-don-t-include-u-b.patch \
    file://0099-FIO-toup-ARM-dts-fsl-imx8qm-apalis-use-dm-spl-proper.patch \
    file://0100-FIO-toup-ARM-dts-fsl-imx8qm-apalis-add-missing-nodes.patch \
    file://0101-FIO-toup-apalis-imx8-add-support-of-SPL-build.patch \
    file://0102-FIO-toup-apalis-imx8-enable-SPL-build.patch \
    file://0103-FIO-toup-apalis-imx8-sync-config-with-Kconfig-defaul.patch \
    file://0121-FIO-toup-apalis-imx8-allow-dropping-CONFIG_CMD_USB-r.patch \
    file://0142-FIO-toup-ARM-dts-imx6-apalis-remove-stub-for-memory-.patch \
    file://0230-FIO-internal-ARM-dts-fsl-imx8qm-apalis-u-boot-add-op.patch \
"

# UNSURE
# file://0232-FIO-fromtree-include-apalis-imx8-different-fixes-for.patch

