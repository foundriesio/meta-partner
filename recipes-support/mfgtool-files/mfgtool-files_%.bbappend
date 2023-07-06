FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:apalis-imx6-sec = " \
    file://fuse.uuu \
    file://close.uuu \
    file://readme.md \
"

SRC_URI:append:apalis-imx8-sec = " \
    file://fuse.uuu \
    file://close.uuu \
    file://readme.md \
"

do_deploy:prepend:apalis-imx6() {
    install -d ${DEPLOYDIR}/${PN}
    install -m 0644 ${DEPLOY_DIR_IMAGE}/SPL ${DEPLOYDIR}/${PN}/SPL-mfgtool
    install -m 0644 ${DEPLOY_DIR_IMAGE}/u-boot.itb ${DEPLOYDIR}/${PN}/u-boot-mfgtool.itb
}

do_compile:append:apalis-imx6-sec() {
    sed -i 's/SPL.*/&.signed/g' bootloader.uuu
}

do_deploy:prepend:apalis-imx6-sec() {
    install -d ${DEPLOYDIR}/${PN}
    install -m 0644 ${WORKDIR}/fuse.uuu ${DEPLOYDIR}/${PN}/fuse.uuu
    install -m 0644 ${WORKDIR}/close.uuu ${DEPLOYDIR}/${PN}/close.uuu
    install -m 0644 ${WORKDIR}/readme.md ${DEPLOYDIR}/${PN}/readme.md
}

do_compile:append:apalis-imx8-sec() {
    sed -i 's/imx-boot.*/&.signed/g' bootloader.uuu
}

do_deploy:prepend:apalis-imx8-sec() {
    install -d ${DEPLOYDIR}/${PN}
    install -m 0644 ${WORKDIR}/fuse.uuu ${DEPLOYDIR}/${PN}/fuse.uuu
    install -m 0644 ${WORKDIR}/close.uuu ${DEPLOYDIR}/${PN}/close.uuu
    install -m 0644 ${WORKDIR}/readme.md ${DEPLOYDIR}/${PN}/readme.md
}
