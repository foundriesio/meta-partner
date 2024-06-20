# LMP partner specific customizations (either replace or extend options as defined by meta-lmp)

# Mask appends requiring other bsp layers
BBMASK += " \
    /meta-lmp/meta-lmp-base/recipes-security/optee/optee-os_%.bbappend \
    /meta-lmp/meta-lmp-bsp/recipes-bsp/alsa/alsa-state-stm32mp1.bbappend \
"
