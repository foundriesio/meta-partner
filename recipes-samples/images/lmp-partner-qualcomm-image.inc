# Additions for qcom partner image

CORE_IMAGE_BASE_INSTALL:append:qcom = " \
    packagegroup-qcom-audio \
    packagegroup-qcom-initscripts \
    var-persist-mount \
    qcom-resize-partitions \
    wlan-conf \
    cld80211-lib \
    curl \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${CORE_IMAGE_BASE_INSTALL_WAYLAND}', '', d)} \
"
CORE_IMAGE_BASE_INSTALL:append:qcom-custom-distro = " \
    cbsp-boot-utilities \
    packagegroup-qcom-core \
    packagegroup-qcom-data \
    packagegroup-qcom-perf \
    packagegroup-qcom-securemsm \
    qcom-ath6kl-utils \
    qcom-ftm \
    qcom-wlan-tools \
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
CORE_IMAGE_BASE_INSTALL_WAYLAND::append:qcom-custom-distro = " \
    packagegroup-qcom-graphics \
    packagegroup-qcom-fastcv \
    packagegroup-qcom-video \
    packagegroup-qcom-iot-base-utils \
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
