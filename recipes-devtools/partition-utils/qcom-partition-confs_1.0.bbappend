FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://lmp-ufs-partitions.conf"

PARTCONF:lmp ?= "lmp-ufs-partitions.conf"
