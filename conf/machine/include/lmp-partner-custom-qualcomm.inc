# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask appends requiring other bsp layers
BBMASK += " \
    /meta-lmp/meta-lmp-base/recipes-security/optee/optee-os_%.bbappend \
"
# Mask meta-qcom-hwe recipes which requires fixes
BBMASK += " \
    /meta-qcom-hwe/recipes-extended/logrotate/logrotate_%.bbappend \
    /meta-qcom-hwe/recipes-connectivity/openssh/openssh_%.bbappend \
    /meta-qcom-hwe/recipes-core/uutils-coreutils/uutils-coreutils_0.0.27.bbappend \
    /meta-qcom-hwe/recipes-extended/ostree/ostree_%.bbappend \
    /meta-qcom-hwe/recipes-multimedia/audio/alsa-utils_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/virtualization-layer/recipes-containers/docker/docker-moby_git.bbappend \
    /meta-qcom-hwe/dynamic-layers/virtualization-layer/recipes-containers/kubernetes/kubernetes_git.bbappend \
    /meta-qcom-hwe/dynamic-layers/virtualization-layer/recipes-containers/docker-compose/docker-compose_git.bbappend \
    /meta-qcom-hwe/dynamic-layers/sota/recipes-sota/ostree-kernel-initramfs/ostree-kernel-initramfs_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-core/dbus/dbus_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-core/base-files/base-files_3.0.14.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-connectivity/iproute2/iproute2_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-extended/shadow/shadow_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-extended/logrotate/logrotate_%.bbappend \
    \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0_1.24%.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-bad_1.20%.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-bad_1.24.2.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-bad_1.24.9.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-base_1.24%.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-good_1.20%.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-good_1.24.2.bbappend \
    /meta-qcom-qim-product-sdk/recipes-gst/gstreamer/gstreamer1.0-plugins-good_1.24.9.bbappend \
"

# Use GCC by default, way too many different failures with clang
TOOLCHAIN = "gcc"
RUNTIME = "gnu"
# Recipes requiring GCC instead of Clang
TOOLCHAIN:pn-iw = "gcc"
TOOLCHAIN:pn-systemd-boot = "gcc"
TOOLCHAIN:pn-libselinux-python = "gcc"
TOOLCHAIN:pn-gbm = "gcc"
TOOLCHAIN:pn-weston = "gcc"
TOOLCHAIN:pn-qcom-display-hal-linux = "gcc"
TOOLCHAIN:pn-pal = "gcc"
TOOLCHAIN:pn-pa-pal-plugins = "gcc"
TOOLCHAIN:pn-qcom-libdmabufheap = "gcc"
TOOLCHAIN:pn-jsoncpp = "gcc"
TOOLCHAIN:pn-bt-app = "gcc"
TOOLCHAIN:pn-bt-cert = "gcc"
TOOLCHAIN:pn-bthost-ipc = "gcc"
TOOLCHAIN:pn-btvendorhal = "gcc"
TOOLCHAIN:pn-fluoride = "gcc"

# Distro Features
DISTRO_FEATURES:append = " pulseaudio acl xattr selinux"

# Qcom specific forks/updates
PREFERRED_VERSION_wpa-supplicant ??= "2.10.qcom"
PREFERRED_VERSION_modemmanager:qcom-custom-bsp = "1.22.0"
PREFERRED_VERSION_libqmi:qcom-custom-bsp = "1.34.0"
PREFERRED_VERSION_libqrtr-glib:qcom-custom-bsp = "1.2.2+git"

# Adreno does not provide libgl, use mesa-gl
PREFERRED_PROVIDER_virtual/mesa:qcom-custom-bsp = "mesa-gl"
PREFERRED_PROVIDER_virtual/libgl:qcom-custom-bsp = "mesa-gl"

# SELinux
PREFERRED_PROVIDER_virtual/refpolicy = "refpolicy-mls"
DISTRO_EXTRA_RDEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)}"
DEFAULT_ENFORCING ?= "permissive"
## Hack as the append from meta-selinux conflicts with lmp expectations (content under var)
PACKAGECONFIG:remove:pn-systemd = "backlight"

# User / group id tables used by the qcom bsp
USERADD_UID_TABLES += "files/quic-passwd-table"
USERADD_GID_TABLES += "files/quic-group-table"

# Custom image classes
IMAGE_CLASSES_EXTRAS ?= ""
IMAGE_CLASSES += "${IMAGE_CLASSES_EXTRAS}"

# Sota / LmP customizations
MACHINE_FEATURES:append:qcom = " efi"
UEFI_SIGN_ENABLE:qcom = "1"
PREFERRED_PROVIDER_virtual/partconf = "qcom-partition-confs"
PREFERRED_PROVIDER_virtual/kernel:qcom ?= "linux-qcom-${QCOM_SELECTED_BSP}"
OSTREE_BOOTLOADER:qcom ?= "none"
EFI_PROVIDER:qcom = "systemd-boot"
EFI_PREFIX:qcom = "/boot"
EFI_DTB_DIR:qcom = "${EFI_PREFIX}/dtb"
KERNEL_DTBDEST:qcom = "boot/dtb"
OSTREE_SPLIT_BOOT:qcom = "1"
OSTREE_LOADER_LINK:qcom = "0"
WKS_FILE:qcom:sota ?= "efidisk-sota.wks.in"
KERNEL_IMAGETYPE:qcom = "uki"
KERNEL_ALT_IMAGETYPE:qcom = ""
KERNEL_CLASSES:qcom = " kernel-lmp-uki "
IMAGE_CLASSES_EXTRAS:qcom ?= "image_types_qcom"
IMAGE_FSTYPES_OTA:append:qcom = " qcomflash"
IMAGE_QCOMFLASH_ESPIMG:qcom:sota ?= "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ota-esp"
IMAGE_QCOMFLASH_FS_TYPE:qcom:sota ?= "ota-ext4"
EXTRA_IMAGECMD:ota-esp:qcom = "-s 1 -S 4096"
IMAGE_FSTYPES:remove:qcom = "wic wic.gz wic.bmap"

## SoC / Machine specific
QCOM_SELECTED_BSP:qcs615 ?= "base"
OSTREE_KERNEL_ARGS:qcs615 ?= "console=ttyMSM0,115200n8 earlycon pcie_pme=nomsi pci=noaer kpti=off kasan=off kasan.stacktrace=off swiotlb=128 mitigations=auto rcupdate.rcu_expedited=1 rcu_nocbs=0-7 no-steal-acc vfio_iommu_type1.allow_unsafe_interrupts=1 deferred_probe_timeout=15 audit=0 ${OSTREE_KERNEL_ARGS_COMMON}"
OSTREE_KERNEL_ARGS:qcm6490 ?= "console=ttyMSM0,115200n8 earlycon pcie_pme=nomsi kernel.sched_pelt_multiplier=4 rcupdate.rcu_expedited=1 rcu_nocbs=0-7 kpti=off kasan=off kasan.stacktrace=off no-steal-acc selinux=0 swiotlb=128 audit=0 ${OSTREE_KERNEL_ARGS_COMMON}"
OSTREE_KERNEL_ARGS:qcs9100 ?= "console=ttyMSM0,115200n8 earlycon pcie_pme=nomsi pci=noaer kpti=off kasan=off kasan.stacktrace=off swiotlb=128 mitigations=auto kernel.sched_pelt_multiplier=4 rcupdate.rcu_expedited=1 rcu_nocbs=0-7 no-steal-acc vfio_iommu_type1.allow_unsafe_interrupts=1 fw_devlink.strict=1 vfio_platform.reset_required=0 amc6821.pwminv=1 audit=0 ${OSTREE_KERNEL_ARGS_COMMON}"

# CDTs
QCOM_CDT_FILE:qcs615-adp-air ?= "adp_3_1.0"
QCOM_CDT_FILE:qcs6490-rb3gen2-core-kit ?= "cdt_core_kit"
QCOM_CDT_FILE:qcs6490-rb3gen2-vision-kit ?= "cdt_vision_kit"
QCOM_CDT_FILE:qcs9100-ride-sx ?= "cdt_ride_sx"
QCOM_CDT_FILE:qcs9075-iq-9075-evk ?= "cdt_rb8_core_kit"

# Compatibility with QCLinux 1.3
IMAGE_CLASSES:remove = "image_types_ota_sdboot"
