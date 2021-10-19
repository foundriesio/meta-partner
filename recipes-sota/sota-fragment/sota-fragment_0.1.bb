SUMMARY = "Start up Application"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit allarch

SRC_URI = " \
	file://90-sota-fragment.toml \
"

S = "${WORKDIR}"

do_install() {
	install -m 0700 -d ${D}${libdir}/sota/conf.d
	install -m 0644 ${WORKDIR}/90-sota-fragment.toml ${D}${libdir}/sota/conf.d/90-sota-fragment.toml
}

FILES_${PN} += "${libdir}/sota/conf.d/90-sota-fragment.toml"
