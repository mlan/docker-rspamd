# Road map

## Rspamd

Clean up default settings in rspamd.conf.docker. Only keep absolutely needed settings

## Rspamd configure using environment variables

Find a way to configure rspamd using environment variables.

`<FILEBASE>=<key1>=<value1>;key2>=<value2>;`

Need list of allowed file bases and use to match. No `_` allowed in FILEBASE!

`ANTIVIRUS=log_clean=false;`

Will set log_clean=false; in /etc/rspamd/local.d/antivirus.conf

But files can have names as `classifier-bayes.conf` and `fuzzy_check.conf`.
So need to allow `_` and code for `-`.

## Rspamd - ClamAV connection fails initially

Rspamd fail to connect to ClamAV initially. Needs to be restarted to work.
