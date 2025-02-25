FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS:append:qcom = " useradd-qcom"
USERADDSETSCENEDEPS:append = " useradd-qcom:do_populate_sysroot_setscene"

# Extend standard groups with audio and users
USERADD_PARAM:${PN} = "--home /home/weston --shell /bin/sh --user-group -G video,audio,users,input,system weston"

DEFAULTBACKEND:qcom = "drm"
DEFAULTBACKEND:qcm6490 = "sdm"
