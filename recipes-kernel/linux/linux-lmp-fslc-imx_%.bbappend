FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

#SRC_URI:append:mx8m-var = " \
#	file://0901-sn65dsi83-Add-dsi2lvds-bridge.patch \
#	file://0902-sn65dsi83-Fix-complation-failures.patch \
#	file://0903-sn65dsi83-Fix-Kconfig-help-messages.patch \
#	file://0904-sn65dsi83-Convert-debug-messages-from-dev_info-to-de.patch \
#	file://0905-sn65dsi83-Add-burst-sync-option-switch.patch \
#	file://0906-sn65dsi83-Add-panel-enable-option.patch \
#	file://0907-sn65dsi83-Add-de-neg-polarity-option.patch \
#	file://0908-sn65dsi83-Add-dual-channel-support.patch \
#	file://fragment-sn65dsi83.cfg \
#"

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
