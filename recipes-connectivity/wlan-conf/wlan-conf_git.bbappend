FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:lmp = " file://simplify_init.patch"
