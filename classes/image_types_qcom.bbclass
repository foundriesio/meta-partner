# Copyright (c) 2023-2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

inherit image_types

IMAGE_TYPES += "qcomflash"

# Default Image names
SYSTEMIMAGE_TARGET ?= "system.img"
IMAGE_QCOMFLASH_ESPIMG ?= "${DEPLOY_DIR_IMAGE}/efi.bin"
IMAGE_QCOMFLASH_FS_TYPE ??= "ext4"
IMAGE_QCOMFLASH_ROOTFS ?= "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${IMAGE_QCOMFLASH_FS_TYPE}"

CONCATDTB_DIR = "${WORKDIR}/dtb"

python do_combine_dtbos() {
    import os, shutil, subprocess

    dtbdir = d.getVar('CONCATDTB_DIR')
    if os.path.exists(dtbdir):
        shutil.rmtree(dtbdir)
    os.mkdir(dtbdir)
    combined_dtb = os.path.join(dtbdir, "combined-dtb.dtb")
    print(combined_dtb)

    for dtbf in d.getVar("KERNEL_DEVICETREE").split():
        dtb = os.path.basename(dtbf)
        with open(combined_dtb, 'ab') as fout:
            with open(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), dtb), 'rb') as fin:
                shutil.copyfileobj(fin, fout)
    joint_dtb_list = "%s %s" %(d.getVar("KERNEL_DEVICETREE"), "combined-dtb.dtb")
}
addtask do_combine_dtbos before do_image_combined_dtb
do_combine_dtbos[depends] += "virtual/kernel:do_deploy"

oe_mkdtbfs() {
        fstype="$1"
        extra_imagecmd=""

        if [ $# -gt 1 ]; then
                shift
                extra_imagecmd=$@
        fi

        # Create a sparse image block
        bbdebug 1 Executing "dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype seek=65536 count=0 bs=1024"
        dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype seek=65536 count=0 bs=1024
        bbdebug 1 "Actual DTB fs size: `du -s ${CONCATDTB_DIR}`"
        bbdebug 1 "Actual Partition size: `stat -c '%s' ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype`"
        bbdebug 1 Executing "mkfs.vfat -F 32 -I $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype "
        mkfs.vfat -F 32 -I $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype
        mcopy -i ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype -s ${CONCATDTB_DIR}/* ::/
        # Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
        fsck.vfat -pvfV ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype
}
do_image_combined_dtb[depends] += "dosfstools-native:do_populate_sysroot mtools-native:do_populate_sysroot"
IMAGE_TYPES += "combined-dtb"
EXTRA_IMAGECMD:combined-dtb ?= ""
IMAGE_CMD:combined-dtb = "oe_mkdtbfs combined-dtb ${EXTRA_IMAGECMD}"

IMAGE_CMD:qcomflash = "create_qcomflash_pkg"
do_image_qcomflash[depends] += "python3-native:do_populate_sysroot qdl-native:do_populate_sysroot \
                                virtual/bootbins:do_deploy gen-partition-bins:do_deploy virtual/kernel:do_deploy"
IMAGE_TYPEDEP:qcomflash += "combined-dtb ${@bb.utils.contains('DISTRO_FEATURES', 'sota', 'ota-ext4 ota-esp', '', d)}"

# TODO: adapt to generic images (not sota)
create_qcomflash_pkg() {
    # qcomflash tarball creation
    rm -rf "${WORKDIR}/qcomflash"
    mkdir -p "${WORKDIR}/qcomflash"
    oldwd=`pwd`
    cd "${WORKDIR}/qcomflash"

    # copy efi.bin
    if [ -f ${IMAGE_QCOMFLASH_ESPIMG} ]; then
        install -m 0644 ${IMAGE_QCOMFLASH_ESPIMG} efi.bin
    fi

    # copy dtb.bin
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.combined-dtb ]; then
        install -m 0644 ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.combined-dtb dtb.bin
    fi

    # copy system.img
    if [ -f ${IMAGE_QCOMFLASH_ROOTFS} ]; then
        install -m 0644 ${IMAGE_QCOMFLASH_ROOTFS} ${SYSTEMIMAGE_TARGET}
    fi

    # Copy gpt_main.bin
    for gmbf in ${DEPLOY_DIR_IMAGE}/gpt_main[0-9].bin; do
        install -m 0644 $gmbf .
    done

    # Copy gpt_backup.bin
    for gpback in ${DEPLOY_DIR_IMAGE}/gpt_backup[0-9].bin; do
        install -m 0644 $gpback .
    done
    # Copy rawprogram.xml
    for rawpg in ${DEPLOY_DIR_IMAGE}/rawprogram[0-9].xml; do
        install -m 0644 $rawpg .
    done

    # Copy the .elf, .mbn files
    for elffile in ${DEPLOY_DIR_IMAGE}/*.elf; do
        install -m 0644 $elffile .
    done

    for mbnfile in ${DEPLOY_DIR_IMAGE}/*.mbn; do
        install -m 0644 $mbnfile .
    done

    # Copy the .melf, .fv files
    for melffile in ${DEPLOY_DIR_IMAGE}/*.melf; do
        if [ -f "$melffile" ]; then
            install -m 0644 $melffile .
        fi
    done

    for fvfile in ${DEPLOY_DIR_IMAGE}/*.fv; do
        if [ -f "$fvfile" ]; then
            install -m 0644 $fvfile .
        fi
    done

    # copy logfs_ufs_8mb.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/logfs_ufs_8mb.bin ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/logfs_ufs_8mb.bin logfs_ufs_8mb.bin
    fi

    # copy zeros_5sectors.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/zeros_5sectors.bin ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/zeros_5sectors.bin zeros_5sectors.bin
    fi

    for patchfile in ${DEPLOY_DIR_IMAGE}/patch*.xml; do
        install -m 0644 $patchfile .
    done

    # Install qdl
    install -m 0755 ${STAGING_BINDIR_NATIVE}/qdl .

    # Create tarball
    rm -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz
    ${IMAGE_CMD_TAR} --sparse --numeric-owner --transform="s,^\./,${IMAGE_BASENAME}-${MACHINE}/," -cf- . | gzip -f -9 -n -c --rsyncable > ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz
    ln -sf ${IMAGE_NAME}.qcomflash.tar.gz ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.qcomflash.tar.gz

    cd "$oldwd"
}

create_tegraflash_pkg[vardepsexclude] += "DATETIME"

def dtbos_recipes(d):
    extra_rdepends = (d.getVar("MACHINE_EXTRA_RDEPENDS") or '').split()
    out_tasks = ['dtc-native:do_populate_sysroot', 'virtual/kernel:do_deploy']
    for rdep in extra_rdepends:
        if rdep.endswith(('devicetree', 'dtb')):
            out_tasks.append('%s:do_deploy' % rdep)
    return ' '.join(out_tasks)

python () {
    d.setVarFlag('do_merge_dtbos', 'depends', '${@dtbos_recipes(d)}')
}

# Merge tech dtbos before generating boot.img
do_merge_dtbos[nostamp] = "1"
do_merge_dtbos[cleandirs] = "${DEPLOY_DIR_IMAGE}/DTOverlays"

python do_merge_dtbos () {
    import os, shutil, subprocess

    fdtoverlay_bin = d.getVar('STAGING_BINDIR_NATIVE') + "/fdtoverlay"
    dtbotpdir = d.getVar('DEPLOY_DIR_IMAGE') + "/" + "tech_dtbs"
    dtoverlaydir = d.getVar('DEPLOY_DIR_IMAGE') + "/" + "DTOverlays"
    os.makedirs(dtbotpdir, exist_ok=True)

    for kdt in d.getVar("KERNEL_DEVICETREE").split():
        org_kdtb = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), os.path.basename(kdt))

        # Rename and copy original kernel devicetree files
        kdtb = os.path.basename(org_kdtb) + ".0"
        shutil.copy2(org_kdtb, os.path.join(dtbotpdir, kdtb))

        # Find  and append matching dtbos for each dtb
        dtb = os.path.basename(org_kdtb)
        dtb_name = dtb.rsplit('.', 1)[0]
        dtbo_list =(d.getVarFlag('KERNEL_TECH_DTBOS', dtb_name) or "").split()
        bb.debug(1, "%s dtbo_list: %s" % (dtb_name, dtbo_list))
        dtbos_found = 0
        for dtbo_file in dtbo_list:
            dtbos_found += 1
            dtbo = os.path.join(dtbotpdir, dtbo_file)
            pre_kdtb = os.path.join(dtbotpdir, dtb + "." + str(dtbos_found - 1))
            post_kdtb = os.path.join(dtbotpdir, dtb + "." + str(dtbos_found))
            cmd = fdtoverlay_bin + " -v -i "+ pre_kdtb +" "+ dtbo +" -o "+ post_kdtb
            bb.debug(1, "merge_dtbos cmd: %s" % (cmd))
            try:
                subprocess.check_output(cmd, shell=True)
            except RuntimeError as e:
                bb.error("cmd: %s failed with error %s" % (cmd, str(e)))
        if dtbos_found == 0:
            bb.debug(1, "No tech dtbos to merge into %s" % dtb)

        # Copy latest overlayed file into DTOverlays path
        output = dtb + "." + str(dtbos_found)
        shutil.copy2(os.path.join(dtbotpdir, output), dtoverlaydir)
        os.symlink(output, os.path.join(dtoverlaydir, dtb))
}
addtask merge_dtbos before do_image_ota

# ESP also ships DTBs
IMAGE_CMD:ota:append() {
    # Uefi dtb
    mkdir -p ${OTA_BOOT}/dtb
    # Workaround: Trim "addons-" from the dtb name to meet UEFI lookup needs
    for dtb in ${KERNEL_DEVICETREE}; do
        dtb=${dtb##*/}
        dtb_trimmed="$(echo "$dtb" | sed -e 's:addons-::g' )"
        bbdebug 1 "UEFI_DTB before: $dtb after: $dtb_trimmed"
        cp ${DEPLOY_DIR_IMAGE}/DTOverlays/$dtb ${OTA_BOOT}/dtb/$dtb_trimmed
    done
}
do_image_ota[depends] += "virtual/kernel:do_deploy"

# Replacing from lmp due size changes (512MB) for qcm
oe_mkotaespfs() {
        fstype="$1"
        extra_imagecmd=""

        if [ $# -gt 1 ]; then
                shift
                extra_imagecmd=$@
        fi

        bbdebug 1 Executing "dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype seek=524288 count=0 bs=1024"
        dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype seek=524288 count=0 bs=1024
        bbdebug 1 "Actual ESP size: `du -s ${OTA_BOOT}`"
        bbdebug 1 "Actual Partition size: `stat -c '%s' ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype`"
        bbdebug 1 Executing "mkfs.vfat -F 32 -I $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype "
        mkfs.vfat -F 32 -I $extra_imagecmd ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype
        mcopy -i ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype -s ${OTA_BOOT}/* ::/
        # Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
        fsck.vfat -pvfV ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.$fstype
}
