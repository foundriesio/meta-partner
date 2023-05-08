UBOOT_REPO = "git://github.com/varigit/uboot-imx.git"
SRCREV = "e79288da3ae864dd6a05e7ed84f6f600f1d8cd97"
SRCREV:imx8mm-var-som-symphony = "49ec7c516ad2ad0c8a352cad5de69a5ac26c752c"
SRCBRANCH = "lf_v2022.04_var02"
SRCBRANCH:imx8mm-var-som-symphony = "lf_v2022.04_var01"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=5a7450c57ffe5ae63fd732446b988025"

SRC_URI:append:imx8mm-var-som-symphony = " \
    file://0001-Kconfig-fix-selecting-FSL_CAAM-without-HAS_CAAM.patch \
    file://0001-imx8mm_var_dart-runtime-image-offset-detection-for-i.patch \
    file://0002-imx8mm_var_dart-define-default-dfu_alt_info-for-emmc.patch \
    file://0003-imx8mm_var_dart-increase-CONFIG_SYS_SPL_MALLOC_SIZE-.patch \
"

SRC_URI:append:imx8mn-var-som = " \
    file://0001-Kconfig-fix-selecting-FSL_CAAM-without-HAS_CAAM.patch \
    file://0001-imx8mn_var_som-runtime-image-offset-detection-for-im.patch \
    file://0002-imx8mn_var_som-define-default-dfu_alt_info-for-emmc-.patch \
    file://0003-imx8mn_var_som-board-fix-compilation-errors.patch \
    file://0004-imx8mn_var_som-increase-CONFIG_SYS_SPL_MALLOC_SIZE-t.patch \
    file://0005-imx8mn_var_som-adjust-SPL-stack-settings-to-match-im.patch \
"
