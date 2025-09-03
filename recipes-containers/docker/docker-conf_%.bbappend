# LmP has its own daemon.json
## Use separated task as do_install from the original recipe calls return
do_rm_daemon_json() {
    rm -rf ${D}${sysconfdir}/docker
}
addtask rm_daemon_json after do_install before do_package
