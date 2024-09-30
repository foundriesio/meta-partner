# when using adreno KHR/khrplatform.h is provided by adreno but virtual/libgl is provided by mesa-gl where
# we explicitly delete KHR/khrplatform.h, since its already coming from adreno package
DEPENDS:append:qcom = " qcom-adreno"
