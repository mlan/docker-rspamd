# Road map

## Rspamd

Clean up default settings in rspamd.conf.local. Only keep absolutely needed settings

## Rspamd configure using environment variables

Find a way to configure rspamd using environment variables.

### new idea

Keep all settings in same file

`RSPAMD??=<json>`

`RSPAMD_0={"antivirus":{"clamav":{"patterns":{"JUST_EICAR":"Eicar-Signature"},"servers":"/run/clamav/clamd.sock","symbol":"CLAM_VIRUS","scan_mime_parts":false,"type":"clamav"}}}`

Need to understand difference `.conf` and `.inc` in this context.

### old idea

`RSPAMD_<FILEBASE>_<KEY>=<value>`

Need list of allowed file bases and use to match. No `_` allowed in FILEBASE!

`RSPAMD_ANTIVIRUS_LOG_CLEAN=false`

Will set log_clean = false; in /etc/rspamd/local.d/antivirus.conf

But files can have names as `classifier-bayes.conf` and `fuzzy_check.conf`.
So need to allow `_` and code for `-`.

## Rspamd - ClamAV connection fails initially

Rspamd fail to connect to ClamAV initially. Needs to be restarted to work.
