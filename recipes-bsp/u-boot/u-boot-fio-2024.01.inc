FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-fio-2024.01:"

SRC_URI:append:lmp = " \
    file://0001-FIO-fromlist-spl-Add-CONFIG_SPL_FIT_SIGNATURE_STRICT.patch \
    file://0002-FIO-fromlist-cmd-Add-CONFIG_FIT_SIGNATURE_STRICT.patch \
    file://0003-FIO-toup-drivers-rpmb-replicate-linux-mmc-configurat.patch \
    file://0004-FIO-toup-drivers-rpmb-use-cache-aligned-buffers-on-r.patch \
    file://0005-FIO-extras-spl-mmc-only-load-legacy-if-set.patch \
    file://0006-FIO-internal-common-foundries.io-verified-boot-utili.patch \
    file://0007-FIO-extras-fit-verify-abort-if-signature-not-found-a.patch \
    file://0008-FIO-toup-boot-image-sig-guard-disabled-algos-for-che.patch \
"
