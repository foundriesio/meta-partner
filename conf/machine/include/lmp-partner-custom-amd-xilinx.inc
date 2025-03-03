# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

XILINX_VER_MAIN ?= "2024.2"

# This is an 'XSCT' based BSP
XILINX_XSCT_VERSION ?= "2024.2"
XILINX_WITH_ESW ?= "xsct"

# HACK: Need to investigate why this isn't setting correctly: meta-xilinx-tools/conf/xsct-tarball.inc:10:
# XILINX_SDK_TOOLCHAIN_BASE = "${@'${COMPONENTS_DIR}/${BUILD_ARCH}/xsct-native' if d.getVar('PN') == 'defaultpkgname' else '${RECIPE_SYSROOT_NATIVE}'}"
XILINX_SDK_TOOLCHAIN_BASE:zynqmp = "${COMPONENTS_DIR}/${BUILD_ARCH}/xsct-native"

# insane class settings
INSANE_SKIP:pn-qemu-xilinx-native += "native-last"
INSANE_SKIP:pn-qemu-xilinx-system-native += "native-last"

# meta-clang:kirkstone: clang is not ready to be used for linux kernel:
# commit 299a5fd ("linux-yocto: Use binutils provided strip")
# We have to remove using clang tools objcopy and strip for all LmP linux
# kernel recipes to avoid building errors like:
# aarch64-lmp-linux-llvm-strip: error: Link field value 30 in section .rela.dyn is not a symbol table
# do_assemble_fitimage.520200: 841: arm-lmp-linux-gnueabi-llvm-objcopy: not found
OBJCOPY:pn-linux-xlnx:toolchain-clang = "${HOST_PREFIX}objcopy"
STRIP:pn-linux-xlnx:toolchain-clang = "${HOST_PREFIX}strip"

# kv260
# uz3eg-iocc-ebbr-sec
TOOLCHAIN:pn-arm-trusted-firmware = "gcc"

# U-boot does compile with clang but clang-15 crashes compiling it :(
TOOLCHAIN:pn-u-boot-xlnx = "gcc"

# libmali-xlnx calls gcc directly on do_install
TOOLCHAIN:pn-libmali-xlnx = "gcc"

# Xilinx

# On kria we need the default provider (fit-based) + scr for compatibility with
# the standard boot firmware, so drop provides to avoid multiple providers
PROVIDES:pn-u-boot-ostree-scr:remove:kv260 = "u-boot-default-script"

## Avnet UltraZed with secure boot support
UBOOT_SIGN_ENABLE:sota:uz3eg-iocc-sec = "1"
SOTA_CLIENT_FEATURES:remove:sota:uz3eg-iocc-sec = "ubootenv"
LMP_BOOT_FIRMWARE_VERSION:uz3eg-iocc-sec = "8"
## Avnet UltraZed with secure boot support and EBBR
UBOOT_SPL_SIGN_ENABLE:sota:uz3eg-iocc-ebbr-sec = "1"
UBOOT_SIGN_ENABLE:sota:uz3eg-iocc-ebbr-sec = "0"
