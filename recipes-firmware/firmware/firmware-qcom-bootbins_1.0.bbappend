PROVIDES += "virtual/bootloader"

# doesn't have GNU_HASH (didn't pass LDFLAGS?)
INSANE_SKIP:${PN} += "ldflags textrel"

# Deploy CDT by default (following meta-qcom master)
PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI:append:qcs615 = " \
    https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS615/cdt/ADP_AIR_SA6155P_V2.zip;downloadfilename=cdt-qcs615-adp-air_${PV}.zip;name=qcs615-adp-air \
"
SRC_URI:append:qcm6490 = " \
    https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS6490/cdt/rb3gen2-core-kit.zip;downloadfilename=cdt-rb3gen2-core-kit_${PV}.zip;name=rb3gen2-core-kit \
    https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS6490/cdt/rb3gen2-vision-kit.zip;downloadfilename=cdt-rb3gen2-vision-kit_${PV}.zip;name=rb3gen2-vision-kit \
"
SRC_URI:append:qcs9100 = " \
    https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS9100/cdt/ride-sx_v3.zip;downloadfilename=cdt-qcs9100-ride-sx-v3_${PV}.zip;name=qcs9100-ride-sx \
    https://artifacts.codelinaro.org/artifactory/codelinaro-le/Qualcomm_Linux/QCS9100/cdt/rb8_core_kit.zip;downloadfilename=cdt-rb8-core-kit_${PV}.zip;name=rb8-core-kit \
"

SRC_URI[qcs615-adp-air.sha256sum] = "37d99eb113e286400bce0d70aa12a74d05f93d01f045bf67e7a46b3c606c8fd0"
SRC_URI[rb3gen2-core-kit.sha256sum] = "0fe1c0b4050cf54203203812b2c1f0d9698823d8defc8b6516414a4e5e0c557e"
SRC_URI[rb3gen2-vision-kit.sha256sum] = "a339e297b454c4dc3805fe8cd11d6d8dcb801aa8f0c2dc691561c2785019fa3c"
SRC_URI[qcs9100-ride-sx.sha256sum] = "377a8405899ac82199deaf70bca3648c15b924a3fcef8f109555e661ed70f4b9"
SRC_URI[rb8-core-kit.sha256sum] = "a252244f800d7c9e15883e12935af4113f9f2ecba6490e46cd9b943169f15bfa"

do_deploy:append() {
	find "${WORKDIR}" -maxdepth 1 -name 'cdt*bin' -exec install -m 0644 {} ${DEPLOYDIR} \;
}
