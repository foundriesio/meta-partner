PROVIDES += "virtual/bootloader"

# doesn't have GNU_HASH (didn't pass LDFLAGS?)
INSANE_SKIP:${PN} += "ldflags textrel"
