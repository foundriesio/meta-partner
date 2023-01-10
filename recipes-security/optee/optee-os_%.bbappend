# Separate TAs into a different package, follow optee-os-fio
PACKAGES += "${PN}-ta"
RPROVIDES:${PN}-ta = "virtual-optee-os-ta"
FILES:${PN}-ta = "${nonarch_base_libdir}/optee_armtz"

do_install:append() {
    # OP-TEE OS TAs
    install -d ${D}${nonarch_base_libdir}/optee_armtz
    install -m 0444 ${B}/ta/*/*.ta ${D}${nonarch_base_libdir}/optee_armtz
}
