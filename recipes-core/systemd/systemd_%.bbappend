# Fix: QA Issue: systemd: invalid PACKAGECONFIG: gnu-efi [invalid-packageconfig]
PACKAGECONFIG:remove:qcom = "gnu-efi"

# Not needed, LmP has a different patch which uses --any instead
SRC_URI:remove:qcom = "file://0001-QCLINUX-units-adjust-timeout-for-systemd-networkd-wa.patch"
