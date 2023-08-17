SUMMARY = "Minimal partner image which includes OTA Lite, Docker, and OpenSSH support"

require recipes-samples/images/lmp-image-common.inc

# Factory tooling requires SOTA (OSTree + Aktualizr-lite)
require ${@bb.utils.contains('DISTRO_FEATURES', 'sota', 'recipes-samples/images/lmp-feature-factory.inc', '', d)}

# Enable wayland related recipes if required by DISTRO
require ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'recipes-samples/images/lmp-feature-wayland.inc', '', d)}

# Enable OP-TEE related recipes if provided by the image
require ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'recipes-samples/images/lmp-feature-optee.inc', '', d)}

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

## MEDIATEK BSP IMAGE ADDITIONS

NDA_IMAGE_INSTALL += " \
    packagegroup-rity-audio \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'packagegroup-rity-display', '', d)} \
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "packagegroup-rity-multimedia", "", d)} \
    packagegroup-rity-net \
    packagegroup-rity-tools \
    packagegroup-rity-zeroconf \
    packagegroup-tools-bluetooth \
    gstreamer1.0-meta-base \
    gstreamer1.0-meta-audio \
    gstreamer1.0-meta-debug \
    gstreamer1.0-meta-video \
    gstreamer1.0-python \
    e2fsprogs-resize2fs \
    iproute2 \
    can-utils \
"

NDA_IMAGE_INSTALL:append:genio-700 = " \
    packagegroup-rity-mtk-video \
"

NDA_IMAGE_INSTALL:remove:i300b = " \
    packagegroup-display \
    packagegroup-multimedia \
"

NDA_IMAGE_INSTALL:append:i1200 = " \
    packagegroup-rity-mtk-video \
    ${@bb.utils.contains("DISTRO_FEATURES", "nda-mtk", "packagegroup-rity-mtk-neuropilot", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "nda-mtk", "packagegroup-rity-mtk-camisp", "", d)} \
"

NDA_IMAGE_INSTALL:append:i350 = " \
    packagegroup-rity-mtk-video \
"

NDA_IMAGE_INSTALL:append:genio-700 = " \
    ${@bb.utils.contains("DISTRO_FEATURES", "nda-mtk", "packagegroup-rity-mtk-neuropilot", "", d)} \
"

CORE_IMAGE_BASE_INSTALL += " ${@bb.utils.contains('NDA_BUILD', '1', '${NDA_IMAGE_INSTALL}', '', d)}"
