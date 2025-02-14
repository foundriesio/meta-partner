FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Fix missing function declaration with upstream patch from:
# https://git.savannah.gnu.org/cgit/freeipmi.git/commit/?h=freeipmi-1-6-0-stable&id=9239a686e4bfd862145f4654017112a0f8cbbb0d
# Delivered in freeipmi-1-6-15
SRC_URI:append = " \
    file://0001-libfreeipmi-sel-ipmi-sel-string-supermicro-common.h-.patch \
    file://0002-ipmi-sensors-fix-header-guard-definitions.patch \
    file://0003-ipmi-sensors-add-missing-include.patch \
"
