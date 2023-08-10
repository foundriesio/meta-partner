# REVERT-ME-92: Temporarily fix docker-compose branch (v2->main)
SRC_URI = "\
	git://github.com/docker/compose.git;branch=main;protocol=https;name=compose \
	git://github.com/docker/cli.git;branch=23.0;protocol=https;name=cli;destsuffix=${S}/src/github.com/docker/cli \
	"
