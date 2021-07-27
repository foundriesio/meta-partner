FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
        file://kernel-meta/bsp/imx/imx8mm_var_som_symphony.cfg \
        file://kernel-meta/bsp/imx/imx8mm_var_som_symphony.scc   \
        file://kernel-meta/bsp/imx/imx8mm_var_som_symphony-standard.scc \
        file://kernel-meta/bsp/imx/fragment-sn65dsi83.cfg \
        file://0901-sn65dsi83-Add-dsi2lvds-bridge.patch \
        file://0902-sn65dsi83-Fix-complation-failures.patch \
        file://0903-sn65dsi83-Fix-Kconfig-help-messages.patch \
        file://0904-sn65dsi83-Convert-debug-messages-from-dev_info-to-de.patch \
        file://0905-sn65dsi83-Add-burst-sync-option-switch.patch \
        file://0906-sn65dsi83-Add-panel-enable-option.patch \
        file://0907-sn65dsi83-Add-de-neg-polarity-option.patch \
        file://0908-sn65dsi83-Add-dual-channel-support.patch \
"
