# Additions for qcom partner image

CORE_IMAGE_BASE_INSTALL:append:qcom = " \
    packagegroup-qcom-core \
    packagegroup-qcom-initscripts \
    packagegroup-qcom-perf \
    packagegroup-qcom-ppat \
    packagegroup-qcom-data \
    packagegroup-qcom-securemsm \
    var-persist-mount \
    qcom-resize-partitions \
    wlan-conf \
    cld80211-lib \
    qcom-wlan-tools \
    qcom-ath6kl-utils \
    qcom-ftm \
    curl \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${CORE_IMAGE_BASE_INSTALL_WAYLAND}', '', d)} \
"

CORE_IMAGE_BASE_INSTALL:append:qcom = " \
    packagegroup-qcom-audio \
    packagegroup-qcom-bluetooth \
    packagegroup-qcom-iot-base-utils \
"

CORE_IMAGE_BASE_INSTALL:remove:qcom = " \
    psplash \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND ?= ""
CORE_IMAGE_BASE_INSTALL_WAYLAND:qcom = " \
    packagegroup-qcom-camera \
    packagegroup-qcom-display \
    packagegroup-qcom-fastcv \
    packagegroup-qcom-graphics \
    packagegroup-qcom-opencv \
    packagegroup-qcom-video \
    packagegroup-qcom-qim-product \
"
CORE_IMAGE_BASE_INSTALL_WAYLAND:append:qcm6490 = " \
    packagegroup-qcom-sensors \
    qcom-camera-server \
"

# Add default LmP user in additional groups
EXTRA_USERS_PARAMS += "\
usermod -a -G video ${LMP_USER}; \
"
