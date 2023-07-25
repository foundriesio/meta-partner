FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-kernel/linux/kmeta-linux-lmp-5.15.y.inc

# Use Toradex git by default
KERNEL_REPO ?= "git://git.toradex.com/linux-toradex.git"
KERNEL_REPO_PROTOCOL ?= "git"
KERNEL_BRANCH ?= "toradex_5.15-2.1.x-imx"
SRCREV_machine ?= "95b4e4bb8a106f916d94be8efb3ca6dacfc79466"
LINUX_VERSION ?= "5.15.77"

SRCREV_meta = "${KERNEL_META_COMMIT}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI = "${KERNEL_REPO};protocol=${KERNEL_REPO_PROTOCOL};branch=${KERNEL_BRANCH};name=machine; \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
    file://0004-FIO-toup-hwrng-optee-support-generic-crypto.patch \
    file://0001-arm64-dts-imx8mq-drop-cpu-idle-states.patch \
"

SRC_URI:append:apalis-imx8 = " \
    file://apalis-imx8-standard.scc \
    file://apalis-imx8.scc \
    file://apalis-imx8.cfg \
"

KMETA = "kernel-meta"

include recipes-kernel/linux/linux-lmp.inc

# make sure overlays are built
do_deploy[depends] += "device-tree-overlays:do_deploy"
