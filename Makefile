# Makefile
#
# build
#

-include    *.mk

BLD_ARG  ?= --build-arg DIST=alpine --build-arg REL=3.19
BLD_REPO ?= mlan/rspamd
BLD_VER  ?= latest

TST_REPO ?= $(BLD_REPO)
TST_VER  ?= $(BLD_VER)
TST_ENV  ?= -C test
TST_TGTE ?= $(addprefix test-,all diff down env htop logs check sh sv up)
TST_TGTI ?= test_% test-up_%
export TST_REPO TST_VER

push:
	#
	# PLEASE REVIEW THESE IMAGES WHICH ARE ABOUT TO BE PUSHED TO THE REGISTRY
	#
	@docker image ls $(BLD_REPO)
	#
	# ARE YOU SURE YOU WANT TO PUSH THESE IMAGES TO THE REGISTRY? [yN]
	@read input; [ "$${input}" = "y" ]
	docker push --all-tags $(BLD_REPO)

build-all: build

build: Dockerfile
	docker build $(BLD_ARG) $(addprefix --tag $(BLD_REPO):,$(call bld_tags,,$(BLD_VER))) .

variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

ps:
	docker ps -a

prune:
	docker image prune -f

clean:
	docker images | grep $(BLD_REPO) | awk '{print $$1 ":" $$2}' | uniq | xargs docker rmi

$(TST_TGTE):
	${MAKE} $(TST_ENV) $@

$(TST_TGTI):
	${MAKE} $(TST_ENV) $@
