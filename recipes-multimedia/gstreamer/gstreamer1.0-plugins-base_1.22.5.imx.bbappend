FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-glupload-don-t-reject-non-RGBA-output-format-in-_dir.patch"
