# Allow EFUSE access, used by OP-TEE (need to disable PRINT headers for PMU_RAM space)
YAML_COMPILER_FLAGS:append:zynqmp = "-DXPFW_PRINT_VAL=0 -DENABLE_EFUSE_ACCESS"
