# 0.9.0

- [docker](Makefile) Use alpine:3.16 (rspamd:3.3 clamav:0.104.3 redis:7.0.5).
- [docker](Dockerfile) Make sure to merge `rspamd.conf.docker` in `rspamd.conf`.
- [repo](.) Based on [mlan/postfix-amavis](https://github.com/mlan/docker-postfix).
- [repo](ROADMAP.md) Outline approach for configure rspamd using environment variables.
- [repo](ROADMAP.md) Describe rspamd modules and their configuration using environment variables.
- [repo](ROADMAP.md) Describe the rspamd web interface.
- [repo](Makefile) Don't advertize multistage builds yet.
- [repo](Makefile) Now use functions in `bld.mk`.
- [demo](demo/Makefile) Start migration to rspamd.
- [rspamd](src/rspamd) Consolidate configuration into [rspamd.conf.docker](src/rspamd/etc/rspamd/rspamd.conf.docker).
- [rspamd](src/rspamd) Correcting worker configuration in `rspamd.conf.docker`.
- [rspamd](src/rspamd) Configure Rspamd using environment variables.
- [test](test/Makefile) Rspamd test suite arranged.
- [test](test/Makefile) Monitor logs to determine when clamd is activated.
- [test](test/Makefile) Don't advertize multistage builds yet.
- [test](test/Makefile) Added Bayes initialization.
- [demo](demo/Makefile) Demo now use Rspamd environment variables.
- [demo](demo/Makefile) Monitor logs to determine when clamd is activated.
