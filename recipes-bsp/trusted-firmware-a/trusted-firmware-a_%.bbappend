FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Align provides with meta-arm
PROVIDES += "virtual/trusted-firmware-a"

# Patch Makefile setting for SPD=opteed
# Fixes a TFA panic on post-OPTEE load: PANIC at PC : 0x00000000fffe977c
# v2.12.0: https://github.com/ARM-software/arm-trusted-firmware/commit/f5b2fa90e0c0324f31e72429e7a7382f49a25912
SRC_URI += " \
    file://0001-fix-zynqmp-handle-secure-SGI-at-EL1-for-OP-TEE.patch \
"

# Enable opteed as the main SPD provider (required for optee)
EXTRA_OEMAKE:append:zynqmp = " SPD=opteed"
