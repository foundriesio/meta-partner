# Additions for qcom partner image

CORE_IMAGE_BASE_INSTALL:append:qcom = " \
    curl \
    linux-firmware-ath10k \
    packagegroup-qcom-audio \
    packagegroup-qcom-initscripts \
    qcom-resize-partitions \
    var-persist-mount \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${CORE_IMAGE_BASE_INSTALL_WAYLAND}', '', d)} \
"
CORE_IMAGE_BASE_INSTALL:append:qcom-custom-bsp = " \
    cbsp-boot-utilities \
    cld80211-lib \
    packagegroup-qcom-core \
    packagegroup-qcom-data \
    packagegroup-qcom-perf \
    packagegroup-qcom-securemsm \
    qcom-ath6kl-utils \
    qcom-ftm \
    qcom-wlan-tools \
    wlan-conf \
"
CORE_IMAGE_BASE_INSTALL:remove:qcom = " \
    psplash \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND ?= ""
CORE_IMAGE_BASE_INSTALL_WAYLAND:qcom = " \
    docker-conf \
    packagegroup-qcom-camera \
    packagegroup-qcom-display \
    packagegroup-qcom-opencv \
    packagegroup-qcom-qim-product \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND:append:qcom-custom-bsp = " \
    packagegroup-qcom-fastcv \
    packagegroup-qcom-graphics \
    packagegroup-qcom-iot-base-utils \
    packagegroup-qcom-video \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND:append:qcm6490 = " \
    packagegroup-qcom-sensors \
    qcom-camera-server \
"

CORE_IMAGE_EXTRA_INSTALL:remove:sota = " \
    varmount \
"

# Add default LmP user in additional groups
EXTRA_USERS_PARAMS += "\
usermod -a -G video ${LMP_USER}; \
"
