FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

include recipes-kernel/linux/kmeta-linux-lmp-5.10.y.inc

LINUX_VERSION ?= "5.10.168"
KBRANCH = "v5.10.168-phy"
SRCREV_machine = "81adb4b8910319515414fad820563c0a86af5460"
SRCREV_meta = "${KERNEL_META_COMMIT}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI = "git://github.com/phytec/linux-phytec-ti.git;protocol=https;branch=${KBRANCH};name=machine; \
    ${KERNEL_META_REPO};protocol=${KERNEL_META_REPO_PROTOCOL};type=kmeta;name=meta;branch=${KERNEL_META_BRANCH};destsuffix=${KMETA} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'jailhouse', '${SRC_URI_JAILHOUSE}', '', d)} \
"

# Jailhouse patches and config
SRC_URI_JAILHOUSE = " \
    file://0001-arm64-dts-am654-base-board-Reserve-memory-for-jailho.patch \
    file://0002-arm64-dts-k3-am654-base-board-jailhouse-Disable-mcu_.patch \
    file://0003-mm-Re-export-ioremap_page_range.patch \
    file://0004-mm-vmalloc-Export-__get_vm_area_caller.patch \
    file://0005-arm-arm64-export-__hyp_stub_vectors.patch \
    file://0006-uio-Enable-read-only-mappings.patch \
    file://0007-ivshmem-Add-header-file.patch \
    file://0008-uio-Add-driver-for-inter-VM-shared-memory-device.patch \
    file://0009-ivshmem-net-virtual-network-device-for-Jailhouse.patch \
    file://0010-arm64-dts-disable-peripherals-for-am654x-root-cell.patch \
    file://0011-arm64-dts-expanded-k3-am654-memory-region-for-jailho.patch \
    file://0012-arm64-dts-disable-pcie0_rc-node-in-k3-am654-jailhous.patch \
    file://0013-arm64-dts-am625-base-board-Reserve-memory-for-jailho.patch \
    file://0014-arm64-dts-add-reserved_memory-label-for-CMA-regions-.patch \
"

SRC_URI:append:phyboard-lyra-am62xx-1 = " \
    file://phyboard-lyra-am62xx-1-standard.scc \
    file://phytec-ti.cfg \
"

# Special configuration for remoteproc/rpmsg IPC modules
module_conf_rpmsg_client_sample = "blacklist rpmsg_client_sample"
module_conf_ti_k3_r5_remoteproc = "softdep ti_k3_r5_remoteproc pre: virtio_rpmsg_bus"
module_conf_ti_k3_dsp_remoteproc = "softdep ti_k3_dsp_remoteproc pre: virtio_rpmsg_bus"
KERNEL_MODULE_PROBECONF += "rpmsg_client_sample ti_k3_r5_remoteproc ti_k3_dsp_remoteproc"

KMETA = "kernel-meta"

include recipes-kernel/linux/linux-lmp.inc
