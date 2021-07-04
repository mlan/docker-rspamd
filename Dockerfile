ARG	DIST=alpine
ARG	REL=latest


#
#
# target: full
#
# Install anti-spam, anti-virus mail filters and dkim.
#
#

FROM	$DIST:$REL AS full
LABEL	maintainer=mlan

ENV	SVDIR=/etc/service \
	DOCKER_PERSIST_DIR=/srv \
	DOCKER_BIN_DIR=/usr/local/bin \
	DOCKER_ENTRY_DIR=/etc/docker/entry.d \
	DOCKER_MILT_DIR=/etc/rspamd \
	DOCKER_MILT_LIB=/var/lib/rspamd \
	DOCKER_MILT_CLIB=/var/cache/rspamd \
	DOCKER_DB_DIR=/etc/redis \
	DOCKER_DB_LIB=/var/lib/redis \
	DOCKER_AV_DIR=/etc/clamav \
	DOCKER_AV_LIB=/var/lib/clamav \
	DOCKER_UNLOCK_FILE=/srv/etc/.docker.unlock \
	DOCKER_MILT_RUNAS=rspamd \
	DOCKER_AV_RUNAS=clamav \
	DOCKER_DB_RUNAS=redis \
	SYSLOG_LEVEL=5 \
	SYSLOG_OPTIONS=-SDt
ENV	DOCKER_MILT_LOCAL_DIR=$DOCKER_MILT_DIR/local.d \
	DOCKER_MILT_FILE=$DOCKER_MILT_DIR/rspamd.conf \
	DOCKER_DKIM_LIB=$DOCKER_MILT_LIB/dkim \
	DOCKER_DB_FILE=$DOCKER_DB_DIR/redis.conf \
	DOCKER_AVNGN_FILE=$DOCKER_AV_DIR/clamd.conf \
	DOCKER_AVSIG_FILE=$DOCKER_AV_DIR/freshclam.conf

#
# Copy utility scripts including docker-entrypoint.sh to image
#

COPY	src/*/bin $DOCKER_BIN_DIR/
COPY	src/*/entry.d $DOCKER_ENTRY_DIR/
COPY	src/*/etc /etc/

#
# Install
#
# Configure Runit, a process manager
#
# Essential configuration of: rspamd and clamav
#
#

RUN	source docker-common.sh \
	&& source docker-config.sh \
	&& dc_persist_dirs \
	$DOCKER_APPL_SSL_DIR \
	$DOCKER_AV_DIR \
	$DOCKER_AV_LIB \
	$DOCKER_CONF_DIR \
	$DOCKER_IMAP_DIR \
	$DOCKER_MILT_DIR \
	$DOCKER_MILT_LIB \
	$DOCKER_DB_DIR \
	$DOCKER_DB_LIB \
	&& apk --no-cache --update add \
	runit \
	rspamd \
	rspamd-client \
	rspamd-controller \
	rspamd-fuzzy \
	rspamd-proxy \
	rspamd-utils \
	clamav \
	clamav-libunrar \
	unzip \
	unrar \
	p7zip \
	ncurses \
	redis \
	&& docker-service.sh \
	"syslogd -nO- -l$SYSLOG_LEVEL $SYSLOG_OPTIONS" \
	"crond -f -c /etc/crontabs" \
	"rspamd -f -u $DOCKER_MILT_RUNAS -g $DOCKER_MILT_RUNAS" \
	"freshclam -d --quiet" \
	"-q clamd" \
	"-n redis -u $DOCKER_DB_RUNAS redis-server $DOCKER_DB_FILE" \
	&& source docker-common.sh \
	&& source docker-config.sh \
	&& addgroup $DOCKER_AV_RUNAS $DOCKER_MILT_RUNAS \
	&& addgroup $DOCKER_MILT_RUNAS $DOCKER_AV_RUNAS \
	&& addgroup $DOCKER_MILT_RUNAS $DOCKER_DB_RUNAS \
	&& chown $DOCKER_MILT_RUNAS: ${DOCKER_PERSIST_DIR}$DOCKER_MILT_LIB \
	&& chown $DOCKER_AV_RUNAS: ${DOCKER_PERSIST_DIR}$DOCKER_AV_LIB \
	&& chown $DOCKER_DB_RUNAS: ${DOCKER_PERSIST_DIR}$DOCKER_DB_LIB \
	&& mkdir /run/clamav && chown $DOCKER_AV_RUNAS: /run/clamav \
	&& mkdir /run/rspamd && chown $DOCKER_MILT_RUNAS: /run/rspamd \
	&& mkdir $DOCKER_MILT_CLIB && chown $DOCKER_MILT_RUNAS: $DOCKER_MILT_CLIB \
	&& dc_modify  $DOCKER_AVNGN_FILE Foreground yes \
	&& dc_modify  $DOCKER_AVNGN_FILE LogSyslog yes \
	&& dc_modify  $DOCKER_AVNGN_FILE LogFacility LOG_MAIL \
	&& dc_comment $DOCKER_AVNGN_FILE LogFile \
	&& dc_modify  $DOCKER_AVNGN_FILE TCPSocket 3310 \
	&& dc_modify  $DOCKER_AVSIG_FILE Foreground yes \
	&& dc_modify  $DOCKER_AVSIG_FILE LogSyslog yes \
	&& dc_comment $DOCKER_AVSIG_FILE UpdateLogFile \
	&& dc_modify  $DOCKER_AVSIG_FILE LogFacility LOG_MAIL \
	&& echo '.include(try=true; priority=1,duplicate=merge) "$CONFDIR/rspamd.conf.docker"' >> $DOCKER_MILT_FILE \
	&& echo "This file unlocks the configuration, so it will be deleted after initialization." > $DOCKER_UNLOCK_FILE

#
# Rudimentary healthcheck
#

HEALTHCHECK CMD sv status ${SVDIR}/*

#
# Entrypoint, how container is run
#

ENTRYPOINT ["docker-entrypoint.sh"]

#
# Have runit's runsvdir start all services
#

CMD	runsvdir -P ${SVDIR}

