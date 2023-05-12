MACHINE_EXTRA_RDEPENDS:remove = " \
        gptfdisk \
        hostapd \
        hdparm \
        imx-kobs \
        iw \
        kernel-modules \
        kmod \
        ${PREFERRED_CONNECTIVITY_MANAGER_PACKAGES} \
        packagegroup-tools-bluetooth \
        bluealsa \
        pm-utils \
        rng-tools \
        wpa-supplicant \
        wireless-regdb-static \
        u-boot-fw-utils \
        u-boot-splash \
        u-boot-default-env \
"

DISTRO_FEATURES:remove:mx8-nxp-bsp = " virtualization"
DISTRO_FEATURES:remove:mx9-nxp-bsp = " virtualization"

# General Variscite settings
PREFERRED_PROVIDER_virtual/kernel:mx8m-var = "linux-lmp-fslc-imx"
PREFERRED_PROVIDER_virtual/bootloader:mx8m-var = "u-boot-fio-mfgtool"
PREFERRED_PROVIDER_u-boot:mx8m-var = "u-boot-fio-mfgtool"

# VAR-SOM-MX8M-NANO
IMXBOOT_TARGETS:fio-imx8mn-var-som = "flash_ddr4_evk"
