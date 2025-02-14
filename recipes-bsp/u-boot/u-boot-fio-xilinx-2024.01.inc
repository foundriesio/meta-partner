FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-fio-xilinx-2024.01:"

SRC_URI:append:lmp = " \
    file://0001-FIO-toup-arm64-zynqmp-add-cmd-for-adjusting-multiboo.patch \
    file://0002-FIO-toup-spl-mmc-support-dynamic-spl-payload-name-on.patch \
    file://0003-FIO-toup-zynqmp-detect-spl-payload-based-on-multiboo.patch \
    file://0004-FIO-toup-arm64-zynqmp-add-cmd-for-getting-boot-auth-.patch \
    file://0005-FIO-toup-board-zynqmp-allow-env-in-fat-ext-when-boot.patch \
    file://0006-FIO-toup-zynqmp-add-dynamic-detection-of-fit-image-s.patch \
    file://0007-FIO-internal-arm64-zynqmp-add-bootslot-command.patch \
    file://0008-FIO-toup-arm64-zynqmp-add-OP-TEE-nodes.patch \
    file://0009-FIO-toup-arm64-versal-add-OP-TEE-nodes.patch \
"
