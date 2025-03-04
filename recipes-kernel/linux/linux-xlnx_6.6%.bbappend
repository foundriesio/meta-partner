FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "${@bb.utils.contains('ARCH', 'x86', 'elfutils-native', '', d)}"
DEPENDS += "openssl-native util-linux-native"

require ${@bb.utils.contains_any('DISTRO_FEATURES', 'integrity', 'recipes-kernel/linux/linux_ima.inc', '', d)}

LINUX_VERSION_EXTENSION:lmp ?= "-lmp-xilinx"

# Add kernel fragment support for FF features
SRC_URI:append:lmp = " \
        file://wireguard.cfg \
        file://docker.cfg \
        file://zram.cfg \
        file://bpf.cfg \
"

# Kernel config
KERNEL_CONFIG_NAME ?= "${KERNEL_PACKAGE_NAME}-config-${KERNEL_ARTIFACT_NAME}"
KERNEL_CONFIG_LINK_NAME ?= "${KERNEL_PACKAGE_NAME}-config"

# Deploy kernel-config to be stored in artifacts
do_deploy:append() {
    # Publish final kernel config with a proper datetime-based link
    cp -a ${B}/.config ${DEPLOYDIR}/${KERNEL_CONFIG_NAME}
    ln -sf ${KERNEL_CONFIG_NAME} ${DEPLOYDIR}/${KERNEL_CONFIG_LINK_NAME}
}
