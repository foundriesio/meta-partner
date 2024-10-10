FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS:append:qcom = " useradd-qcom"

# Extend standard groups with audio and users
USERADD_PARAM:${PN} = "--home /home/weston --shell /bin/sh --user-group -G video,audio,users,input,system weston"
