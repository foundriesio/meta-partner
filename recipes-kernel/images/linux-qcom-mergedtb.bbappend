# fix do_configure warning due lack of inclusion in DEPENDS
python __anonymous() {
    dtbo_providers = ""
    for recipe in d.getVar('KERNEL_TECH_DTBO_PROVIDERS').split():
        dtbo_providers += " " + recipe

    depends = d.getVar("DEPENDS")
    depends += " virtual/kernel %s" % dtbo_providers
    d.setVar('DEPENDS', depends)
}
