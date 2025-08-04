qcom_sign_verify_file() {
	file="$(basename $1)"
	filedir="$(dirname "$1")"
	sectools="${QCOM_FIRMWARE_SIGN_SECTOOLS_DIR}/sectools"
	secprofile="${QCOM_FIRMWARE_SIGN_SECPROFILE}"
	root_hash="0x$(cat ${QCOM_FIRMWARE_SIGN_KEY_DIR}/sha384_roots_hash.txt | cut -d' ' -f2)"

	newline="\n"

	image_id_mapping="\
		a660_zap.mbn GPU-MICRO-CODE ${newline}\
		adsp.mbn ADSP ${newline}\
		aop.mbn AOP ${newline}\
		cdsp.mbn CDSP ${newline}\
		cpucp.elf CPUCP ${newline}\
		devcfg.mbn TZ-DEVCFG ${newline}\
		hypvm.mbn QHEE ${newline}\
		imagefv.elf UEFIFV ${newline}\
		ipa_fws.mbn IPA-FW ${newline}\
		loadalgota64.mbn TZ-APP-OEM ${newline}\
		msbtfw11.mbn SKIP ${newline}\
		multi_image.mbn OEM-MISC ${newline}\
		prog_firehose_ddr.elf DEVICE-PROGRAMMER ${newline}\
		prog_firehose_lite.elf DEVICE-PROGRAMMER ${newline}\
		qupv3fw.elf QUPV3 ${newline}\
		sec.elf SEC-ELF ${newline}\
		shrm.elf SHRM ${newline}\
		tz.mbn TZ ${newline}\
		uefi.elf UEFI ${newline}\
		uefi_sec.mbn TZ-APP-OEM ${newline}\
		vpu20_1v.mbn VENUS-FW ${newline}\
		vpu30_4v.mbn VENUS-FW ${newline}\
		vpu30_4v_16mb.mbn VENUS-FW ${newline}\
		wpss.mbn WPSS ${newline}\
		xbl_config.elf XBL-CONFIG ${newline}\
		xbl_config_gunyah.elf XBL-CONFIG ${newline}\
		xbl_config_kvm.elf XBL-CONFIG ${newline}\
		xbl.elf XBL ${newline}\
		XblRamdump.elf XBL-RAM-DUMP ${newline}\
		DigestsToSign.bin.mbn VIP ${newline}\
		FD02C9DA-306C-48C7-A49C-BBD827AE86EE.mbn TZ-APP-OEM ${newline}\
	"

	sign_id=$(${sectools} secure-image --inspect $1 | grep "| Software ID:" | cut -d'|' -f3)
	if [ -z "${sign_id}" ]; then
		bbwarn "$file does not contain signatures, skipping"
		return 0
	fi

	# Lookup the IMAGE-ID from mapping
	image_id=$(echo "${image_id_mapping}" | grep "${file}" | cut -d' ' -f2)
	bbdebug 1 "IMAGE_ID = ${image_id}"
	if [ -z "${image_id}" ] || [ "${image_id}" = "UNKNOWN" ]; then
		bbfatal "Unable to find IMAGE-ID mapping for ${file}"
	fi

	if [ "${image_id}" = "SKIP" ]; then
		bbwarn "Skip signing of ${file}"
		return 0
	fi

	${sectools} secure-image \
		--sign $1 --image-id=${image_id} \
		--security-profile ${secprofile} \
		--anti-rollback-version=0x0 \
		--signing-mode LOCAL \
		--root-certificate-index 0 \
		--root-certificate=${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_rootca0.cer \
		--ca-certificate=${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_attestca0.cer \
		--ca-key=${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_attestca0.key \
		--outfile $1
	if [ $? -ne 0 ]; then
		bbfatal "Signing ${file} failed"
	fi

	bbnote "Verifying root hash of ${file}"
	${sectools} secure-image --verify-root ${root_hash} $1
	if [ $? -ne 0 ]; then
		bbfatal "Root hash of ${file} failed verification"
	fi
}

QCOM_FIRMWARE_SIGN_ENABLE ??= "0"

qcom_check_signing_enabled() {
	if [ "${QCOM_FIRMWARE_SIGN_ENABLE}" != "1" ]; then
		return 0
	fi

	if [ ! -f "${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_rootca0.cer" ]; then
		bbfatal "QCOM_FIRMWARE_SIGN_KEY_DIR or Root certificate is invalid"
	fi
	if [ ! -f "${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_attestca0.cer" ]; then
		bbfatal "QCOM_FIRMWARE_SIGN_KEY_DIR or CA certificate is invalid"
	fi
	if [ ! -f "${QCOM_FIRMWARE_SIGN_KEY_DIR}/qpsa_attestca0.key" ]; then
		bbfatal "QCOM_FIRMWARE_SIGN_KEY_DIR or CA key is invalid"
	fi
	if [ ! -f "${QCOM_FIRMWARE_SIGN_SECTOOLS_DIR}/sectools" ]; then
		bbfatal "QCOM_FIRMWARE_SIGN_SECTOOLS_DIR is invalid"
	fi
	if [ ! -f "${QCOM_FIRMWARE_SIGN_SECPROFILE}" ]; then
		bbfatal "QCOM_FIRMWARE_SIGN_SECPROFILE is invalid"
	fi
}

do_qcom_firmware_sign[vardeps] += "QCOM_FIRMWARE_SIGN_ENABLE QCOM_FIRMWARE_SIGN_KEY_DIR QCOM_FIRMWARE_SIGN_SECPROFILE"
