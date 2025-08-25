FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://lmp-ufs-partitions.conf"

PARTCONF:lmp ?= "lmp-ufs-partitions.conf"

# Replace compile and deploy as we currently only support UFS
do_compile() {
	${PYTHON} ${STAGING_BINDIR_NATIVE}/gen_partition.py \
		-i ${WORKDIR}/${PARTCONF} \
		-o ${B}/partition.xml
}

do_deploy() {
	install -m 0644 ${B}/partition.xml -D ${DEPLOYDIR}/partition.xml
}
