FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:i1200-demo = " \
    file://lmp.cfg \
"
