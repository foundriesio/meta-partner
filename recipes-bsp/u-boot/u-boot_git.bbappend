FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:i1200-demo = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'ebbr', 'file://lmp-ebbr.cfg', 'file://lmp.cfg', d)} \
"
