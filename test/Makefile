include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := rsync
ROOT_DIR:=$(shell realpath root)

test: setup ##@targets Starts docker compose.
	export ROOT_DIR="$(ROOT_DIR)" \
	&& docker-compose -p ${NAME} -f test.yaml up
.PHONY: up

clean: rm ##@targets Removes docker containers and created files.
	if [ -d $(ROOT_DIR) ]; then \
	sudo rm -rf $(ROOT_DIR); \
	fi

rm: ##@targets Removes docker containers.
	export ROOT_DIR="$(ROOT_DIR)" \
	&& docker-compose -p ${NAME} -f test.yaml stop \
	&& docker-compose -p ${NAME} -f test.yaml rm

setup:
	if ! [ -d $(ROOT_DIR) ]; then \
	mkdir -p $(ROOT_DIR); \
	sudo chown 200:200 -R $(ROOT_DIR); \
	fi
.PHONY: setup

try-rsync: ##@targets Tries to run rsync on the docker container.
	rsync -e 'ssh -F ./ssh_config' -v test.yaml rsync@localhost:/data/
