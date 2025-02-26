PROVIDES += "virtual/bootloader"

# doesn't have GNU_HASH (didn't pass LDFLAGS?)
INSANE_SKIP:${PN} += "ldflags textrel"

# Deploy CDT by default (following meta-qcom master)
PACKAGE_ARCH = "${MACHINE_ARCH}"

CDT_FILE ?= ""
CDT_FILE:qcs6490-rb3gen2-core-kit ?= "cdt_core_kit"
CDT_FILE:qcs6490-rb3gen2-vision-kit ?= "cdt_vision_kit"
CDT_FILE:qcs9100-ride-sx ?= "cdt_ride_sx"
CDT_FILE:qcs9075-rb8-core-kit ?= "cdt_rb8_core_kit"

SRC_URI:append:qcs6490-rb3gen2-core-kit = " https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS6490/cdt/rb3gen2-core-kit.zip;downloadfilename=cdt-rb3gen2-core-kit_${PV}.zip;name=rb3gen2-core-kit"
SRC_URI:append:qcs6490-rb3gen2-vision-kit = " https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS6490/cdt/rb3gen2-vision-kit.zip;downloadfilename=cdt-rb3gen2-vision-kit_${PV}.zip;name=rb3gen2-vision-kit"
SRC_URI:append:qcs9100-ride-sx = " https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS9100/cdt/ride-sx_v3.zip;downloadfilename=cdt-qcs9100-ride-sx-v3_${PV}.zip;name=qcs9100-ride-sx"
SRC_URI:append:qcs9075-rb8-core-kit = " https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS9100/cdt/rb8_core_kit.zip;downloadfilename=cdt-rb8-core-kit_${PV}.zip;name=rb8-core-kit"
SRC_URI[rb3gen2-core-kit.sha256sum] = "0fe1c0b4050cf54203203812b2c1f0d9698823d8defc8b6516414a4e5e0c557e"
SRC_URI[rb3gen2-vision-kit.sha256sum] = "a339e297b454c4dc3805fe8cd11d6d8dcb801aa8f0c2dc691561c2785019fa3c"
SRC_URI[qcs9100-ride-sx.sha256sum] = "377a8405899ac82199deaf70bca3648c15b924a3fcef8f109555e661ed70f4b9"
SRC_URI[rb8-core-kit.sha256sum] = "a252244f800d7c9e15883e12935af4113f9f2ecba6490e46cd9b943169f15bfa"

do_deploy:append() {
	if [ -f "${WORKDIR}/${CDT_FILE}.bin" ]; then
		install -m 0644 ${WORKDIR}/${CDT_FILE}.bin ${DEPLOYDIR}/cdt.bin
	fi
}
