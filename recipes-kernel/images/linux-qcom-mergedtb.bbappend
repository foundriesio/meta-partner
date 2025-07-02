# fix do_configure warning due lack of inclusion in DEPENDS
python __anonymous() {
    dtbo_providers = ""
    for recipe in d.getVar('KERNEL_TECH_DTBO_PROVIDERS').split():
        dtbo_providers += " " + recipe

    depends = d.getVar("DEPENDS")
    depends += " virtual/kernel %s" % dtbo_providers
    d.setVar('DEPENDS', depends)
}

DEPENDS += "openssl-native"

do_dtb_sign() {
	if [ "${UEFI_SIGN_ENABLE}" = "1" ]; then
		if [ ! -f "${UEFI_SIGN_KEYDIR}/DB.key" -o ! -f "${UEFI_SIGN_KEYDIR}/DB.crt" ]; then
			bbfatal "UEFI_SIGN_KEYDIR or DB.key/crt is invalid"
		fi
		combined=${B}/DTOverlays/combined-dtb.dtb
		openssl cms -sign -inkey ${UEFI_SIGN_KEYDIR}/DB.key -signer ${UEFI_SIGN_KEYDIR}/DB.crt -binary -in ${combined} --out ${combined%.dtb}.sig -outform DER
	fi
}
do_dtb_sign[depends] += "openssl-native:do_populate_sysroot"
do_dtb_sign[vardeps] += "UEFI_SIGN_ENABLE UEFI_SIGN_KEYDIR"
addtask dtb_sign before do_install after do_compile

FILES:${PN}-combined += "combined-dtb.sig"
