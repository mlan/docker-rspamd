#bind_socket = "$RUNDIR/fuzzy.sock mode=0660 owner=rspamd"; # BUG: cannot use unixsocket
bind_socket = "*v4:11335";
