# 1.0.0

- [docker](Makefile) Use alpine:3.15 (rspamd:3.2 clamav:0.104.3 redis:6.2.7).
- [docker](Dockerfile) Make sure to merge `rspamd.conf.docker` in `rspamd.conf`.
- [repo](.) Based on [mlan/postfix-amavis](https://github.com/mlan/docker-postfix).
- [repo](ROADMAP.md) Outline approach for configure rspamd using environment variables.
- [repo](Makefile) Now use functions in `bld.mk`.
- [demo](demo/Makefile) Start migration to rspamd.
- [rspamd](src/rspamd) Consolidate configuration into [rspamd.conf.docker](src/rspamd/etc/rspamd/rspamd.conf.docker).
- [rspamd](src/rspamd) Correcting worker configuration in `rspamd.conf.docker`.
- [rspamd](src/rspamd) Configure Rspamd using environment variables.
- [test](test/Makefile) Rspamd test suite arranged.
- [test](test/Makefile) Monitor logs to determine when clamd is activated.
- [demo](demo/Makefile) Demo now use Rspamd environment variables.
- [demo](demo/Makefile) Monitor logs to determine when clamd is activated.
