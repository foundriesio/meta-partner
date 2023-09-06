FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-kernel/linux/kmeta-linux-lmp-5.15.y.inc

# Use Phytec git by default
KERNEL_REPO ?= "git://git.phytec.de/linux-imx.git"
KERNEL_REPO_PROTOCOL ?= "git"
KERNEL_BRANCH ?= "v5.15.71_2.2.0-phy"
SRCREV_machine ?= "a3785e3e63123c2c1238338125be9003e034ed42"
LINUX_VERSION ?= "5.15.71"

SRCREV_meta = "${KERNEL_META_COMMIT}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI = "${KERNEL_REPO};protocol=${KERNEL_REPO_PROTOCOL};branch=${KERNEL_BRANCH};name=machine; \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
    file://0004-FIO-toup-hwrng-optee-support-generic-crypto.patch \
    file://0001-arm64-dts-imx8mq-drop-cpu-idle-states.patch \
"

SRC_URI:append:phyboard-pollux-imx8mp-3 = " \
    file://phyboard-pollux-imx8mp-3-standard.scc \
    file://phyboard-pollux-imx8mp-3.scc \
    file://phyboard-pollux-imx8mp-3.cfg \
"

KMETA = "kernel-meta"

include recipes-kernel/linux/linux-lmp.inc
