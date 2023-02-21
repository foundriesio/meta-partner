FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:phyboard-lyra-am62xx-1 = " \
        file://ti_k3-am625-phyboard-lyra-rdk-proto.dts \
"
COMPATIBLE_MACHINE:phyboard-lyra-am62xx-1 = ".*"
