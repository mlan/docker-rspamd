# 1.0.0

- [repo](.) Based on [mlan/postfix-amavis](https://github.com/mlan/docker-postfix).
- [repo](ROADMAP.md) Outline approach for configure rspamd using environment variables.
- [demo](demo/Makefile) Start migration to rspamd.
- [test](test/Makefile) Start migration to rspamd.
- [rspamd](src/rspamd) Consolidate configuration into [rspamd.conf.docker](src/rspamd/etc/rspamd/rspamd.conf.docker).
- [rspamd](src/rspamd) Correcting worker configuration in `rspamd.conf.docker`.
- [docker](Dockerfile) Make sure to merge `rspamd.conf.docker` in `rspamd.conf`.
- [rspamd](src/rspamd) Configure Rspamd using environment variables.
