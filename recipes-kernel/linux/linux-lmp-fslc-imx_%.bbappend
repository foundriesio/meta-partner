FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

KERNEL_REPO = "git://github.com/varigit/linux-imx.git"
KERNEL_BRANCH = "5.15-2.0.x-imx_var01"
SRCREV_machine = "823c33d95f44b8d3cd61ce55b2470eecb87503dc"
LINUX_VERSION = "5.15.60"

KERNEL_BRANCH:imx8mn-var-som = "lf-5.15.y_var01"
SRCREV_machine:imx8mn-var-som = "d4a03eb6188c8e3b31719d9b72680ab2fca86217"
LINUX_VERSION:imx8mn-var-som = "5.15.71"

KERNEL_BRANCH:imx8mp-var-dart = "lf-5.15.y_var01"
SRCREV_machine:imx8mp-var-dart = "289a927366f57435d24b41dc641eaeffb1e0de80"
LINUX_VERSION:imx8mp-var-dart = "5.15.71"

SRC_URI:append:imx8mm-var-som-symphony = " \
        file://imx8mm_var_som_symphony.cfg \
        file://imx8mm_var_som_symphony.scc   \
        file://imx8mm_var_som_symphony-standard.scc \
"

SRC_URI:append:imx8mn-var-som = " \
        file://imx8mn-var-som.cfg \
        file://imx8mn-var-som.scc   \
        file://imx8mn-var-som-standard.scc \
"

SRC_URI:append:imx8mp-var-dart = " \
        file://imx8mp-var-dart.cfg \
        file://imx8mp-var-dart.scc   \
        file://imx8mp-var-dart-standard.scc \
"

# FIX-UP build
SRC_URI:remove:mx8m-var = "file://0001-FIO-extras-arm64-dts-imx8mm-evk-use-imx8mm-evkb-for-.patch"
SRC_URI:remove:mx8m-var = "file://0001-FIO-fromlist-gpu-drm-imx-sec_mipi_dsim-imx-fix-probe.patch"
