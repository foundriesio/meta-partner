PACKAGECONFIG:append:qcom = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'egl glesv2', '', d)}"
PACKAGECONFIG:remove:qcom = "opengl"
