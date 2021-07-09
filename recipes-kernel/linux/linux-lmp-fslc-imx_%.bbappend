FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
        file://kernel-meta/bsp/imx/imx8mm_var_dart.cfg \
        file://kernel-meta/bsp/imx/imx8mm_var_dart.scc   \
        file://kernel-meta/bsp/imx/imx8mm_var_dart-standard.scc \
"