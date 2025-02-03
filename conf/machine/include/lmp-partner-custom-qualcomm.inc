# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask appends requiring other bsp layers
BBMASK += " \
    /meta-lmp/meta-lmp-base/recipes-security/optee/optee-os_%.bbappend \
"
# Mask meta-qcom-hwe recipes which requires fixes
BBMASK += " \
    /meta-qcom-hwe/recipes-core/systemd/systemd-boot_254.4.bb \
    /meta-qcom-hwe/recipes-connectivity/hostap-daemon/hostapd_%.bbappend \
    /meta-qcom-hwe/recipes-connectivity/wpa-supplicant/wpa-supplicant_2.10.bbappend \
    /meta-qcom-hwe/dynamic-layers/virtualization-layer/recipes-containers/docker/docker-moby_git.bbappend \
    /meta-qcom-hwe/recipes-containers/kubernetes/kubernetes_git.bbappend \
    /meta-qcom-hwe/recipes-extended/logrotate/logrotate_%.bbappend \
    /meta-qcom-hwe/recipes-connectivity/openssh/openssh_%.bbappend \
    \
    /meta-qcom-hwe/recipes-sota/ostree-kernel-initramfs/ostree-kernel-initramfs_%.bbappend \
    /meta-qcom-hwe/recipes-extended/ostree/ostree_%.bbappend \
    /meta-qcom-hwe/recipes-multimedia/audio/alsa-utils_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-extended/logrotate/logrotate_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-extended/shadow/shadow_4.11.1.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-core/dbus/dbus_%.bbappend \
    /meta-qcom-hwe/dynamic-layers/core/recipes-core/base-files/base-files_3.0.14.bbappend \
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

# Adreno does not provide libgl, use mesa-gl
PREFERRED_PROVIDER_virtual/mesa = "mesa-gl"
PREFERRED_PROVIDER_virtual/libgl = "mesa-gl"

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
PREFERRED_PROVIDER_virtual/partconf = "qcom-partition-confs"
PREFERRED_PROVIDER_virtual/kernel:qcm6490 ?= "linux-qcom-custom"
OSTREE_BOOTLOADER:qcm6490 ?= "none"
EFI_PROVIDER:qcm6490 = "systemd-boot"
EFI_PREFIX:qcm6490 = "/boot"
EFI_DTB_DIR:qcm6490 = "${EFI_PREFIX}/dtb"
KERNEL_DTBDEST:qcm6490 = "boot/dtb"
OSTREE_SPLIT_BOOT:qcm6490 = "1"
OSTREE_LOADER_LINK:qcm6490 = "0"
WKS_FILE:qcm6490:sota ?= "efidisk-sota.wks.in"
KERNEL_IMAGETYPE:qcm6490 = "uki"
KERNEL_ALT_IMAGETYPE:qcm6490 = ""
KERNEL_CLASSES:qcm6490 = " kernel-lmp-uki "
IMAGE_CLASSES_EXTRAS:qcm6490 ?= "image_types_qcom"
IMAGE_FSTYPES_OTA:append:qcm6490 = " qcomflash"
IMAGE_QCOMFLASH_ESPIMG:qcm6490:sota ?= "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ota-esp"
IMAGE_QCOMFLASH_FS_TYPE:qcm6490:sota ?= "ota-ext4"
EXTRA_IMAGECMD:ota-esp:qcm6490 = "-s 1 -S 4096"
IMAGE_FSTYPES:remove:qcom = "wic wic.gz wic.bmap"
OSTREE_KERNEL_ARGS:qcm6490 ?= "console=ttyMSM0,115200n8 earlycon pcie_pme=nomsi kernel.sched_pelt_multiplier=4 rcupdate.rcu_expedited=1 rcu_nocbs=0-7 kpti=off kasan=off kasan.stacktrace=off no-steal-acc page_owner=on swiotlb=128 audit=0 ${OSTREE_KERNEL_ARGS_COMMON}"

# Compatibility with QCLinux 1.3
IMAGE_CLASSES:remove = "image_types_ota_sdboot"
