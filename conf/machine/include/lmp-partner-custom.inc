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
