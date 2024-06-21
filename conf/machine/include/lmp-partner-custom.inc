# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask appends requiring other bsp layers
BBMASK += " \
    /meta-lmp/meta-lmp-base/recipes-security/optee/optee-os_%.bbappend \
    /meta-lmp/meta-lmp-bsp/recipes-bsp/alsa/alsa-state-stm32mp1.bbappend \
"
# Mask meta-qcom-hwe recipes which requires fixes
BBMASK += " \
    /meta-qcom-hwe/recipes-core/systemd/systemd-boot_254.4.bb \
    /meta-qcom-hwe/recipes-containers/docker/docker-ce_git.bbappend \
    /meta-qcom-hwe/recipes-containers/kubernetes/kubernetes_git.bbappend \
    /meta-qcom-hwe/recipes-extended/logrotate/logrotate_%.bbappend \
"

# Recipes requiring GCC instead of Clang
TOOLCHAIN:pn-iw = "gcc"
TOOLCHAIN:pn-systemd-boot = "gcc"
TOOLCHAIN:pn-libselinux-python = "gcc"
TOOLCHAIN:pn-gbm = "gcc"
TOOLCHAIN:pn-weston = "gcc"
TOOLCHAIN:pn-display-hal-linux = "gcc"

# Distro Features
DISTRO_FEATURES:append = " pulseaudio acl xattr selinux"

# SELinux
PREFERRED_PROVIDER_virtual/refpolicy = "refpolicy-mls"
DISTRO_EXTRA_RDEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)}"
DEFAULT_ENFORCING ?= "permissive"
## Hack as the append from meta-selinux conflicts with lmp expectations (content under var)
PACKAGECONFIG:remove:pn-systemd = "backlight"

# User / group id tables used by the qcom bsp
USERADD_UID_TABLES += "files/quic-passwd-table"
USERADD_GID_TABLES += "files/quic-group-table"

# Sota / LmP customizations
PREFERRED_PROVIDER_virtual/kernel:qcm6490 ?= "linux-kernel-qcom"
OSTREE_BOOTLOADER:qcm6490 ?= "none"
EFI_PROVIDER:qcm6490 = "systemd-boot"
OSTREE_SPLIT_BOOT:qcm6490 = "1"
OSTREE_LOADER_LINK:qcm6490 = "0"
WKS_FILE:qcm6490:sota ?= "efidisk-sota.wks.in"
IMAGE_FSTYPES:remove:qcom = "wic wic.gz wic.bmap"
OSTREE_KERNEL_ARGS:qcm6490 ?= "console=ttyMSM0,115200n8 earlycon pcie_pme=nomsi kernel.sched_pelt_multiplier=4 rcupdate.rcu_expedited=1 rcu_nocbs=0-7 kpti=off kasan=off kasan.stacktrace=off no-steal-acc page_owner=on swiotlb=128 ${OSTREE_KERNEL_ARGS_COMMON}"
