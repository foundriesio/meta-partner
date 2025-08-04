include qcom-firmware-sign.inc

do_qcom_firmware_sign() {
    if ! qcom_check_signing_enabled ; then
        return 0
    fi

    bbnote "Searching for MBN and ELF files to sign"
    file_list=$(find "${S}/" -type f \( -iname "*.mbn" -o -iname "*.elf" \))
    for file in ${file_list}; do
        if ! qcom_sign_verify_file "${file}" ; then
            bbfatal "Failed to sign file: ${file}"
        fi
    done
}

addtask do_qcom_firmware_sign before do_install after do_compile
