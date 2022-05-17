#!/bin/sh
#
# rspamd-learn.sh
#
# The Rspamd Bayes system does not activate until a certain
# number of ham (non-spam) and spam have been learned. The default
# is 200 of each ham and spam.
#
# Note that the sub-command "n" is called by inotifyd.
#
source docker-common.sh

SPAM_DIR=/tmp/spam
SPAM_ARC=$SPAM_DIR.7z
LAST_MONTH=$(date -d '@'$(expr $(date +%s) - 2592000) +%Y-%m)
SPAM_HTTP=http://untroubled.org/spam/$LAST_MONTH.7z

usage() { cat <<-!cat
	 d) download
	 l) learn
	 c) cleanup
	 a) download && learn && cleanup
	 n) notify <path> <file>
	 s) status
	!cat
	}

run() {
	case $1 in

	d) download ;;
	l) learn ;;
	c) cleanup ;;
	a) download && learn && cleanup ;;
	n) notify $@ ;;
	s) status ;;
	*) usage ;;

	esac
	}

learn() { rspamc learn_spam $SPAM_DIR/ ;}
cleanup() { rm -rf $SPAM_DIR $SPAM_ARC ;}
status() { rspamc stat ;}

download() {
	which 7z || apk add p7zip ncurses
	mkdir -p $SPAM_DIR
	if [ ! -e $SPAM_ARC ]; then
		echo downloading $SPAM_HTTP
		wget -O $SPAM_ARC $SPAM_HTTP
		7z e -o$SPAM_DIR $SPAM_ARC
	fi
	}

notify() {
	# assume the following arguments n path file
	dc_log 7 $@
	shift
	local dir=$1
	local file=$2
	local task=$(basename ${dir})
	if [ -f ${dir}/${file} ] && rspamc learn_${task} ${dir}/${file} >/dev/null; then
		rm -f ${dir}/${file}
		dc_log 5 Learned ${task} ${dir}/${file}
	else
		dc_log 3 Unable to process ${task} ${dir}/${file}
	fi
}

#
# run
#
run $@
