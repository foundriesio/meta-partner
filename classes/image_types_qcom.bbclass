# Copyright (c) 2023-2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

inherit image_types

IMAGE_TYPES += "qcomflash"

# Default Image names
ROOTFSIMAGE_TARGET ?= "rootfs.img"
IMAGE_QCOMFLASH_ESPIMG ?= "${DEPLOY_DIR_IMAGE}/efi.bin"
IMAGE_QCOMFLASH_FS_TYPE ??= "ext4"
IMAGE_QCOMFLASH_ROOTFS ?= "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${IMAGE_QCOMFLASH_FS_TYPE}"

QCOM_CDT_FILE ?= "cdt"

QCOMFLASH_DIR = "${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash"
IMAGE_CMD:qcomflash = "create_qcomflash_pkg"
do_image_qcomflash[dirs] = "${QCOMFLASH_DIR}"
do_image_qcomflash[cleandirs] = "${QCOMFLASH_DIR}"
do_image_qcomflash[depends] += "python3-native:do_populate_sysroot zip-native:do_populate_sysroot \
                                virtual/bootbins:do_deploy qcom-gen-partition-bins:do_deploy \
                                virtual/kernel:do_deploy dtb-qcom-image:do_image_complete \
                                dtb-el2-qcom-image:do_image_complete"
IMAGE_TYPEDEP:qcomflash += "${@bb.utils.contains('DISTRO_FEATURES', 'sota', 'ota-ext4 ota-esp', '', d)}"

# TODO: adapt to generic images (not sota)
create_qcomflash_pkg() {
    # copy efi.bin
    if [ -f ${IMAGE_QCOMFLASH_ESPIMG} ]; then
        install -m 0644 ${IMAGE_QCOMFLASH_ESPIMG} efi.bin
    fi

    # copy dtb.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/dtb-qcom-image-${MACHINE}.vfat ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/dtb-qcom-image-${MACHINE}.vfat dtb.bin
    fi

    # copy el2-dtb.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/dtb-el2-qcom-image-${MACHINE}.vfat ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/dtb-el2-qcom-image-${MACHINE}.vfat el2-dtb.bin
    fi

    # copy rootfs.img
    if [ -f ${IMAGE_QCOMFLASH_ROOTFS} ]; then
        install -m 0644 ${IMAGE_QCOMFLASH_ROOTFS} ${ROOTFSIMAGE_TARGET}
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

    # copy zeros_33sectors.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/zeros_33sectors.bin ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/zeros_33sectors.bin zeros_33sectors.bin
    fi

    # copy zeros_5sectors.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/zeros_5sectors.bin ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/zeros_5sectors.bin zeros_5sectors.bin
    fi

    # copy cdt.bin
    if [ -f ${DEPLOY_DIR_IMAGE}/${QCOM_CDT_FILE}.bin ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/${QCOM_CDT_FILE}.bin cdt.bin
    fi

    # copy sail_nor firmware
    if [ -d ${DEPLOY_DIR_IMAGE}/sail_nor ]; then
        mkdir sail_nor
        find ${DEPLOY_DIR_IMAGE}/sail_nor -type f -exec install -m 0644 {} sail_nor \;
    fi

    for patchfile in ${DEPLOY_DIR_IMAGE}/patch*.xml; do
        install -m 0644 $patchfile .
    done

    # Create tarball
    rm -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz
    ${IMAGE_CMD_TAR} --sparse --numeric-owner --transform="s,^\./,${IMAGE_BASENAME}-${MACHINE}/," -cf- . | gzip -f -9 -n -c --rsyncable > ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz
    ln -sf ${IMAGE_NAME}.qcomflash.tar.gz ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.qcomflash.tar.gz

    # Create zip for windows users (follow same directory pattern as the tarball)
    rm -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.zip
    cd ..
    ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash ${IMAGE_LINK_NAME}
    zip -r ${ZIP_COMPRESSION_LEVEL} ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.zip ${IMAGE_LINK_NAME}
    rm -f ${IMAGE_LINK_NAME}
    cd -
    ln -sf ${IMAGE_NAME}.qcomflash.zip ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.qcomflash.zip
}

create_qcomflash_pkg[vardepsexclude] += "DATETIME"

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
