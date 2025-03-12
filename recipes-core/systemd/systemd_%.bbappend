FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
   file://0001-sd-device-introduce-sd_device_new_child.patch \
   file://0002-udev-net_id-avoid-slot-based-names-only-for-single-f.patch \
   file://0003-udev-net_id-Use-devicetree-aliases-when-available.patch \
"
