FILESEXTRAPATHS:prepend := "${THISDIR}:"

GROUPADD_PARAM:pulseaudio-server:qcom = "-r pulse"
USERADDSETSCENEDEPS:append = " useradd-qcom:do_populate_sysroot_setscene"
