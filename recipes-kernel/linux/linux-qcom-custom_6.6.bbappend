FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

require ${@bb.utils.contains_any('DISTRO_FEATURES', 'modsign', 'recipes-kernel/linux/linux-qcom-custom-signing.inc', '', d)}

SRC_URI += "file://lmp.cfg"

KERNEL_CONFIG_FRAGMENTS:append = " ${WORKDIR}/lmp.cfg"

# Kernel config
KERNEL_CONFIG_NAME ?= "${KERNEL_PACKAGE_NAME}-config-${KERNEL_ARTIFACT_NAME}"
KERNEL_CONFIG_LINK_NAME ?= "${KERNEL_PACKAGE_NAME}-config"

do_deploy:append() {
    # Publish final kernel config with a proper datetime-based link
    cp -a ${B}/.config ${DEPLOYDIR}/${KERNEL_CONFIG_NAME}
    ln -sf ${KERNEL_CONFIG_NAME} ${DEPLOYDIR}/${KERNEL_CONFIG_LINK_NAME}
}
