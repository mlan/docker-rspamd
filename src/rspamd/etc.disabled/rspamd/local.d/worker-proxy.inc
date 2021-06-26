bind_socket = "*v4:11332";
#bind_socket = "/var/spool/postfix/private/milter mode=0660 owner=postfix";
upstream "local" {
	hosts = "/run/rspamd/normal.sock";
}
