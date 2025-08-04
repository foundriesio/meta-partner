include qcom-firmware-sign.inc

do_qcom_firmware_sign() {
    if ! qcom_check_signing_enabled ; then
        return 0
    fi

    bbnote "Searching for MBN and ELF files to sign"
    # firmware_install, defined in the firmware-common.unc unpacks archieve with firmware binaries
    # directly to ${D}, so we should look into this directory
    file_list=$(find "${D}/" -type f \( -iname "*.mbn" -o -iname "*.elf" \))
    for file in ${file_list}; do
        if ! qcom_sign_verify_file "${file}" ; then
            bbfatal "Failed to sign file: ${file}"
        fi
    done
}

addtask do_qcom_firmware_sign before do_deploy after do_install
