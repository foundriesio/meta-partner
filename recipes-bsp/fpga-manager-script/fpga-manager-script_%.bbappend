FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:lmp = " \
    file://0001-Correct-used-paths.patch \
"
