FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:phyboard-pollux-imx8mp-3-sec = " \
    file://fuse.uuu \
    file://close.uuu \
    file://readme.md \
"

do_compile:append:phyboard-pollux-imx8mp-3-sec() {
    sed -i 's/imx-boot.*/&.signed/g' bootloader.uuu
}

do_deploy:prepend:phyboard-pollux-imx8mp-3-sec() {
    install -d ${DEPLOYDIR}/${PN}
    install -m 0644 ${WORKDIR}/fuse.uuu ${DEPLOYDIR}/${PN}/fuse.uuu
    install -m 0644 ${WORKDIR}/close.uuu ${DEPLOYDIR}/${PN}/close.uuu
    install -m 0644 ${WORKDIR}/readme.md ${DEPLOYDIR}/${PN}/readme.md
}
