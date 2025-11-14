# Do not assume one by default as we also support different providers
require ${@bb.utils.contains('PREFERRED_PROVIDER_virtual/optee-os', 'optee-os-fio', 'optee-os-fio-bsp-nxp-imx.inc', '', d)}
require ${@bb.utils.contains('PREFERRED_PROVIDER_virtual/optee-os', 'optee-os-fio-mfgtool', 'optee-os-fio-bsp-nxp-imx-mfgtool.inc', '', d)}
include ${@bb.utils.contains('PREFERRED_PROVIDER_virtual/optee-os', 'optee-os-fio-mfgtool', 'recipes-security/optee/optee-os-fio-mfgtool_${PV}.bb', '', d)}
