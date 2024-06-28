SUMMARY = "Minimal partner image which includes OTA Lite, Docker, and OpenSSH support"

require recipes-samples/images/lmp-image-common.inc

# Factory tooling requires SOTA (OSTree + Aktualizr-lite)
require ${@bb.utils.contains('DISTRO_FEATURES', 'sota', 'recipes-samples/images/lmp-feature-factory.inc', '', d)}

# Enable wayland related recipes if required by DISTRO
require ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'recipes-samples/images/lmp-feature-wayland.inc', '', d)}

require recipes-samples/images/lmp-feature-softhsm.inc
require recipes-samples/images/lmp-feature-wireguard.inc
require recipes-samples/images/lmp-feature-docker.inc
require recipes-samples/images/lmp-feature-wifi.inc
require recipes-samples/images/lmp-feature-ota-utils.inc
require recipes-samples/images/lmp-feature-sbin-path-helper.inc

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_BASE_INSTALL_GPLV3 = "\
    packagegroup-core-full-cmdline-utils \
    packagegroup-core-full-cmdline-multiuser \
"

CORE_IMAGE_BASE_INSTALL += " \
    kernel-modules \
    networkmanager-nmcli \
    git \
    vim \
    packagegroup-core-full-cmdline-extended \
    ${@bb.utils.contains('LMP_DISABLE_GPLV3', '1', '', '${CORE_IMAGE_BASE_INSTALL_GPLV3}', d)} \
"

CORE_IMAGE_BASE_INSTALL:append:qcom = " \
    packagegroup-qcom-initscripts \
    wlan-conf \
    cld80211-lib \
    common-tools \
    ath6kl-utils \
    ftm \
    kernel-module-wlan-platform \
    kernel-module-qcacld-wlan \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${CORE_IMAGE_BASE_INSTALL_WAYLAND}', '', d)} \
"

# qcom uses weston-launch (via init_display.service)
CORE_IMAGE_BASE_INSTALL:remove:qcom = " \
    weston-init \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND ?= ""
CORE_IMAGE_BASE_INSTALL_WAYLAND:qcom = " \
    packagegroup-qcom-display \
    packagegroup-qcom-fastcv \
    packagegroup-qcom-graphics \
    packagegroup-qcom-video \
    packagegroup-qcom-iot-base-utils \
"
