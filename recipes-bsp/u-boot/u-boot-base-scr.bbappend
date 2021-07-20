FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_compile() {
    sed -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        -e 's/@@FDT_FILE@@/${UBOOT_DTB_NAME}/' \
        "${WORKDIR}/uEnv.txt.in" > uEnv.txt
    mkimage -A arm -T script -C none -n "LMP base boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}