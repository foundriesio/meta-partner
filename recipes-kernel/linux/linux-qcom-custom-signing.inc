require recipes-kernel/linux/linux_ima.inc

SRC_URI += "file://signing.cfg"

KERNEL_CONFIG_FRAGMENTS:append = " ${WORKDIR}/signing.cfg"
