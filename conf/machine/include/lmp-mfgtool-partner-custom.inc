# Phytec phyBOARD-Pollux i.MX 8MPlus
PREFERRED_PROVIDER_virtual/bootloader:phyboard-pollux-imx8mp-3 ?= "u-boot-fio-mfgtool"

# Phytec phyBOARD-lyra-am62xx-3
INITRAMFS_IMAGE:k3 = "initramfs-ostree-lmp-recovery"
EXTRA_IMAGEDEPENDS:remove:k3 = "u-boot-default-script"
PREFERRED_PROVIDER_virtual/optee-os:k3 = "optee-os-fio-mfgtool"
KERNEL_IMAGETYPE:k3 = "fitImage"
KERNEL_CLASSES:k3 = " kernel-lmp-fitimage "
PREFERRED_PROVIDER_virtual/bootloader:lmp-mfgtool:phyboard-lyra-am62xx-1 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_virtual/bootloader:lmp-mfgtool:phyboard-lyra-am62xx-2 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_virtual/bootloader:lmp-mfgtool:phyboard-lyra-am62xx-3 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_u-boot:lmp-mfgtool:phyboard-lyra-am62xx-1 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_u-boot:lmp-mfgtool:phyboard-lyra-am62xx-2 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_u-boot:lmp-mfgtool:phyboard-lyra-am62xx-3 = "u-boot-ti-mfgtool"
PREFERRED_PROVIDER_virtual/kernel:lmp-mfgtool:phyboard-lyra-am62xx-1 = "linux-lmp-ti"
PREFERRED_PROVIDER_virtual/kernel:lmp-mfgtool:phyboard-lyra-am62xx-2 = "linux-lmp-ti"
PREFERRED_PROVIDER_virtual/kernel:lmp-mfgtool:phyboard-lyra-am62xx-3 = "linux-lmp-ti"
