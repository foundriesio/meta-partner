FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-kernel/linux/kmeta-linux-lmp-5.15.y.inc

# Save SRCREV from original recipe
SRCREV_machine = "${SRCREV}"
SRCREV_meta = "${KERNEL_META_COMMIT}"

SRC_URI = " \
    ${AIOT_BSP_URI}/linux.git;protocol=ssh;branch=${SRCBRANCH};name=machine; \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
"

SRC_URI:append:i350-evk = " \
    file://i350-evk-standard.scc \
"
SRC_URI:append:i350-pumpkin = " \
    file://i350-pumpkin-standard.scc \
"
SRC_URI:append:i1200-demo = " \
    file://i1200-demo-standard.scc \
"

KMETA = "kernel-meta"

# Kernel config
KERNEL_CONFIG_NAME ?= "${KERNEL_PACKAGE_NAME}-config-${KERNEL_ARTIFACT_NAME}"
KERNEL_CONFIG_LINK_NAME ?= "${KERNEL_PACKAGE_NAME}-config"

do_deploy:append() {
    # Publish final kernel config with a proper datetime-based link
    cp -a ${B}/.config ${DEPLOYDIR}/${KERNEL_CONFIG_NAME}
    ln -sf ${KERNEL_CONFIG_NAME} ${DEPLOYDIR}/${KERNEL_CONFIG_LINK_NAME}
}

