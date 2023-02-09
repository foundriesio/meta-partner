include recipes-kernel/linux/kmeta-linux-lmp-5.15.y.inc

LINUX_VERSION ?= "5.15.37"
KBRANCH = "mtk-v5.15-dev"
SRCREV_machine = "5b4f1088c3854df37b28680071c1ac985400f699"
SRCREV_meta = "${KERNEL_META_COMMIT}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI = "${AIOT_BSP_URI}/linux.git;protocol=ssh;branch=${KBRANCH};name=machine; \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
"

SRC_URI:append:i350-evk = " \
    file://i350-evk-standard.scc \
    file://i350-evk.scc \
    file://i350-evk.cfg \
"
SRC_URI:append:i350-pumpkin = " \
    file://i350-pumpkin-standard.scc \
    file://i350-pumpkin.scc \
    file://i350-pumpkin.cfg \
"
SRC_URI:append:i1200-demo = " \
    file://i1200-demo-standard.scc \
    file://i1200-demo.scc \
    file://i1200-demo.cfg \
"

KMETA = "kernel-meta"

include recipes-kernel/linux/linux-lmp.inc
