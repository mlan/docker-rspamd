# Makefile
#
# test
#

-include    *.mk

TST_REPO ?= mlan/rspamd
TST_VER  ?= latest
TST_NAME ?= test
TST_SLOG ?= 7
TST_FLOG ?= notice

NET_NAME ?= $(TST_NAME)-net
NET_ENV  ?= --network $(NET_NAME)

FLT_NAME ?= $(TST_NAME)-flt

FLT_WEB_PW ?= secret
FLT_METRIC ?= 'actions {greylist=4;add_header=6;rewrite_subject=8;reject=15;} group "antivirus" { symbol "VIRUS_EICAR" {weight=15;description="Eicar test signature";} symbol "CLAM_VIRUS" {weight=15;description="ClamAV found a Virus";}}'

FLT_ENV  ?= \
--name $(FLT_NAME) \
-e SYSLOG_LEVEL=$(TST_SLOG) \
-e 'LOGGING=level="$(TST_FLOG)";' \
-e 'WORKER_CONTROLLER=enable_password="$(FLT_WEB_PW)";' \
-e METRICS=$(FLT_METRIC) \
-v $(FLT_NAME):/srv

FRC_ENV  ?= $(FLT_ENV) \
-e FORCE_CONFIG=yes

MTA_LIST ?= flt
CNT_LIST ?= $(MTA_LIST)

TST_W8S1 ?= 1
TST_W8S2 ?= 20
TST_W8L1 ?= 60
TST_W8L2 ?= 120

MAIL_FROM ?= sender@my-domain.biz
MAIL_TO   ?= recipient@example.com
MAIL_TYPE ?= text/plain
PLAIN_SUBJ = Test message.
PLAIN_MESS = Great news! You can receive email.
PLAIN_GREP = Spam: false
GTUBE_SUBJ = GTUBE spam message.
GTUBE_MESS = XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X
GTUBE_GREP = GTUBE
EICAR_SUBJ = EICAR virus message.
EICAR_MESS = X5O!P%@AP[4\PZX54(P^)7CC)7}\$$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$$H+H*
EICAR_TYPE = audio/basic
EICAR_GREP = VIRUS_EICAR


variables:
	make -pn | grep -A1 "^# makefile"| grep -v "^#\|^--" | sort | uniq

ps:
	docker ps -a

test-all: $(addprefix test_,1 2)
	

test_%: test-up_% test-wait_% test-logs_% test-check_% test-down_%
	

test-up_1:
	#
	#
	#
	# test (1) milter function
	#
	#
	docker run -d $(FLT_ENV) $(TST_REPO):$(call bld_tag,,$(TST_VER))

test-up_2:
	#
	#
	#
	# test (2) force_config dkim
	#
	#
	docker run -d $(FRC_ENV) $(TST_REPO):$(call bld_tag,,$(TST_VER))

test-check_%: test-check_plain_% test-check_gtube_% test-check_eicar_%
	#
	#
	# test ($*) success ☺
	#
	#
	#

test-wait_%:
	#
	# Waiting for clamd to open its tcp socket.
	#
	while ! docker exec -i $(FLT_NAME) nc -z localhost 3310; do sleep 5; done; sleep 5
	#
	# Ask clamd to reload signatures.
	#
	docker exec -i $(FLT_NAME) /bin/sh -c 'echo RELOAD | nc localhost 3310'
	#
	# Waiting for clamd to activate.
	#
	while ! docker container logs $(FLT_NAME) | grep 'Activating'; do sleep 5; done
	#
	# Waiting for rspamd to open its ipc socket.
	#
	while ! docker exec -i $(FLT_NAME) rspamadm control recompile 2>/dev/null; do sleep 5; done

test-logs_%:
	docker container logs $(FLT_NAME)

test-up-net:
	docker network create $(NET_NAME) 2>/dev/null || true

test-down-net:
	docker network rm $(NET_NAME) 2>/dev/null || true

test-down-vol:
	docker volume rm $(FLT_NAME) 2>/dev/null || true

test-down: test-down_0 test-down-net test-down-vol

test-down_%:
	docker rm -f $(FLT_NAME) 2>/dev/null || true
	if [ $* -ge 0 ]; then sleep $(TST_W8S1); fi

define messid
$(shell echo $$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c8)@dot.com)
endef

define head_mail
@echo -e "From: <$(1)>\nTo: <$(2)>\nDate: $$(date -R)\nMessage-ID: <$(messid)>\nMIME-Version: 1.0\nContent-type: $(if $(5),$(5),$(MAIL_TYPE))\nSubject: $(3)\n\n$(if $(4),$(4),$(PLAIN_MESS))\n"
endef

flt-check: test-check_0

test-check_plain_%:
	$(call head_mail,$(MAIL_FROM),$(MAIL_TO),$(PLAIN_SUBJ)) \
	| docker exec -i $(FLT_NAME) rspamc --hostname localhost | grep "$(PLAIN_GREP)"

test-check_gtube_%:
	$(call head_mail,$(MAIL_FROM),$(MAIL_TO),$(GTUBE_SUBJ),$(GTUBE_MESS)) \
	| docker exec -i $(FLT_NAME) rspamc --hostname localhost | grep "$(GTUBE_GREP)"

test-check_eicar_%:
	$(call head_mail,$(MAIL_FROM),$(MAIL_TO),$(EICAR_SUBJ),$(EICAR_MESS),$(EICAR_TYPE)) \
	| docker exec -i $(FLT_NAME) rspamc --hostname localhost | grep "$(EICAR_GREP)"

$(addprefix test-,diff env htop logs check sh sv up):
	${MAKE} $(patsubst test-%,flt-%,$@)

$(addsuffix -sh,$(CNT_LIST)):
	docker exec -it $(patsubst %-sh,$(TST_NAME)-%,$@) sh -c 'exec $$(getent passwd root | sed "s/.*://g")'

$(addsuffix -env,$(CNT_LIST)):
	docker exec -it $(patsubst %-env,$(TST_NAME)-%,$@) env

$(addsuffix -logs,$(CNT_LIST)):
	docker container logs $(patsubst %-logs,$(TST_NAME)-%,$@)

$(addsuffix -diff,$(CNT_LIST)):
	docker container diff $(patsubst %-diff,$(TST_NAME)-%,$@)

$(addsuffix -tools,$(CNT_LIST)):
	docker exec -it $(patsubst %-tools,$(TST_NAME)-%,$@) \
	apk --no-cache --update add \
	nano less lsof htop openldap-clients bind-tools iputils mariadb-client

$(addsuffix -htop,$(CNT_LIST)):
	docker exec -it $(patsubst %-htop,$(TST_NAME)-%,$@) htop

$(addsuffix -sv,$(MTA_LIST)):
	docker exec -it $(patsubst %-sv,$(TST_NAME)-%,$@) sh -c 'sv status $$SVDIR/*'

$(addsuffix -dkim-key,$(MTA_LIST)):
	docker exec -it $(patsubst %-dkim-key,$(TST_NAME)-%,$@) amavisd testkeys

$(addsuffix -spam-learn,$(MTA_LIST)):
	docker exec -it $(patsubst %-spam-learn,$(TST_NAME)-%,$@) amavis-learn.sh a

$(addsuffix -bayes-status,$(MTA_LIST)):
	docker exec -it $(patsubst %-bayes-status,$(TST_NAME)-%,$@) sa-learn --dump magic \
	| sed -r 's/[^ ]+\s+[^ ]+\s+([^ ]+).*non-token data: (.*)/\1\@\2/g' \
	| sed -r '/atime/s/(.*)@(.*)/echo $$(date --date=@\1 +%Y%b%d-%T)@\2/eg' \
	| column -t -s @

