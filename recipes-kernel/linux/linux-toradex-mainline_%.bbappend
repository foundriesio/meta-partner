FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

require recipes-kernel/linux/kmeta-linux-lmp-6.1.y.inc

SRCREV_meta = "${KERNEL_META_COMMIT}"
KMETA = "kernel-meta"

SRC_URI:append = " \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
"

SRC_URI:append:apalis-imx6 = " \
    file://0001-MLK-16912-PL310-unlock-ways-during-initialization.patch \
    file://apalis-imx6-standard.scc \
    file://apalis-imx6.scc \
    file://apalis-imx6.cfg \
"
