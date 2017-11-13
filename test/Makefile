include ../utils/Makefile.help
include ../utils/Makefile.functions

export NAME := rsync
export ROOT_DIR := root
export USER := root

test: setup ##@targets Starts docker compose.
	docker-compose -p ${NAME} -f test.yaml up
.PHONY: up

clean: rm ##@targets Removes docker containers and created files.
	docker-compose -p ${NAME} -f test.yaml rm -f
	if [ -d $(ROOT_DIR) ]; then \
	sudo rm -rf $(ROOT_DIR); \
	fi

rm: ##@targets Removes docker containers.
	docker-compose -p ${NAME} -f test.yaml stop

setup:
	mkdir -p $(ROOT_DIR)
	sudo chmod o+rwX $(ROOT_DIR)
.PHONY: setup

try-rsync: ##@targets Tries to run rsync on the docker container.
	rsync -e 'ssh -F ./ssh_config' -v test.yaml root@localhost:/data/
