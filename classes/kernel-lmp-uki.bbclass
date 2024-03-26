# Copyright (c) 2023-2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# This bbclass is designed to repack kernel image as a UKI (Unified Kernel Image)
#
# The UKI is composed by:
#   - an UEFI stub, from systemd-boot
#   - the kernel Image
#   - an initramfs
#   - other metadata like cmdline

KERNEL_IMAGE_BIN_EXT ?= ".efi"

inherit kernel-artifact-names
inherit python3native

require conf/image-uefi.conf

DEPENDS:append = " \
            systemd-boot-native \
            python3-native \
            python3-pefile-native \
            os-release \
            "

# Based on kernel-fitimage
def get_kernel_uki_replacement_type(d):
    kerneltypes = d.getVar('KERNEL_IMAGETYPES') or ""
    replacementtype = ""
    if 'uki' in kerneltypes.split():
        uarch = d.getVar("UBOOT_ARCH")
        if uarch == "arm64":
            replacementtype = "Image"
        elif uarch == "riscv":
            replacementtype = "Image"
        elif uarch == "x86":
            replacementtype = "bzImage"
        else:
            replacementtype = "zImage"
    return replacementtype

KERNEL_IMAGETYPE_REPLACEMENT ?= "${@get_kernel_uki_replacement_type(d)}"

python __anonymous () {
        # Override KERNEL_IMAGETYPE_FOR_MAKE variable, which is internal
        # to kernel.bbclass . We have to override it, since we pack zImage
        # (at least for now) into the UKI.
        typeformake = d.getVar("KERNEL_IMAGETYPE_FOR_MAKE") or ""
        if 'uki' in typeformake.split():
            d.setVar('KERNEL_IMAGETYPE_FOR_MAKE', typeformake.replace('uki', d.getVar('KERNEL_IMAGETYPE_REPLACEMENT')))
}

do_uki[depends] += "systemd-boot:do_deploy"
do_uki[depends] += "${@ '${INITRAMFS_IMAGE}:do_image_complete' if d.getVar('INITRAMFS_IMAGE') else ''}"
do_uki[dirs] = "${B}"

python do_uki() {
    import glob
    import subprocess
    import os

    # Construct the ukify command
    ukify_cmd = ("ukify build")

    deploy_dir_image = d.getVar('DEPLOY_DIR_IMAGE')

    # clean up uki
    #uki_file = "uki-%s.efi" % d.getVar('INITRAMFS_IMAGE')
    #if os.path.exists(uki_file):
    #    os.remove(uki_file)
    uki_file = "%s/uki" % d.getVar('KERNEL_OUTPUT_DIR')
    if os.path.exists(uki_file):
        os.remove(uki_file)

    # Ramdisk
    if d.getVar('INITRAMFS_IMAGE'):
        baseinitrd = os.path.join(d.getVar("DEPLOY_DIR_IMAGE"), d.getVar("INITRAMFS_IMAGE_NAME"))
        for img in (".cpio.gz", ".cpio.lz4", ".cpio.lzo", ".cpio.lzma", ".cpio.xz", ".cpio"):
            if os.path.exists(baseinitrd + img):
                initrd = baseinitrd + img
                break
        if not initrd:
            bb.fatal("ERROR: cannot find {initrd}.")
        ukify_cmd += " --initrd=%s" % initrd
    else:
        bb.fatal("ERROR - Required argument: INITRD")

    # Kernel
    if d.getVar('KERNEL_IMAGETYPE_FOR_MAKE'):
        kernel = "%s/%s" % (d.getVar('KERNEL_OUTPUT_DIR'), d.getVar('KERNEL_IMAGETYPE_FOR_MAKE'))
        kernel_version = d.getVar('KERNEL_VERSION')
        if not os.path.exists(kernel):
            bb.fatal(f"ERROR: cannot find {kernel}.")
        ukify_cmd += " --linux=%s --uname %s" % (kernel, kernel_version)
    else:
        bb.fatal("ERROR - Required argument: KERNEL")

    # Kernel cmdline
    if d.getVar('UKI_CMDLINE'):
        ukify_cmd += " --cmdline='%s'" % (d.getVar('UKI_CMDLINE'))

    # Architecture
    target_arch = d.getVar('EFI_ARCH')
    ukify_cmd += " --efi-arch %s" % target_arch

    # Stub
    stub = "%s/linux%s.efi.stub" % (deploy_dir_image, target_arch)
    if not os.path.exists(stub):
        bb.fatal(f"ERROR: cannot find {stub}.")
    ukify_cmd += " --stub %s" % stub

    # Add option for dtb
    if d.getVar('KERNEL_DEVICETREE') and d.getVar('UKI_DTB') == "1" :
        first_dtb = d.getVar('KERNEL_DEVICETREE').split()[0]
        dtbf = os.path.basename(first_dtb)
        dtb_path = "%s/%s" % (deploy_dir_image, dtbf)

        if not os.path.exists(dtb_path):
            bb.fatal(f"ERROR: cannot find {dtb_path}.")
        ukify_cmd += " --devicetree %s" % dtb_path

    # Os-release
    osrelease = d.getVar('RECIPE_SYSROOT') + d.getVar('libdir') + "/os-release"
    ukify_cmd += " --os-release @%s" % osrelease

    # Custom UKI name
    output = " --output=%s" % uki_file
    ukify_cmd += " %s" % output

    # Set env to determine where bitbake should look for dynamic libraries
    env = os.environ.copy() # get the env variables
    env['LD_LIBRARY_PATH'] = d.expand("${RECIPE_SYSROOT_NATIVE}/usr/lib/systemd:${LD_LIBRARY_PATH}")

    # Run the ukify command
    bb.note("Calling ukify: %s" % ukify_cmd)
    subprocess.check_call(ukify_cmd, env=env, shell=True)
}
addtask uki before do_deploy after do_bundle_initramfs

# Hack because kernel.bbclass only knows how to ignore fitImage
kernel_do_install:prepend() {
	touch ${KERNEL_OUTPUT_DIR}/uki
}
