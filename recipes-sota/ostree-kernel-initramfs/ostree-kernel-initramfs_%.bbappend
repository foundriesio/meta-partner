do_install:append() {
    if [ "${KERNEL_IMAGETYPE}" = "uki" ]; then
        if [ -n "${INITRAMFS_IMAGE}" ]; then
            # this is a hack for ostree not to override init= in kernel cmdline -
            # make it think that the initramfs is present (while it is in UKI image)
            rm -fv $kerneldir/initramfs.img
            touch $kerneldir/initramfs.img
        fi
    fi
}
