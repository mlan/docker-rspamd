# 1.0.2

- [docker](Makefile) Use alpine:3.19 (rspamd:3.7.4 clamav:1.2.1 redis:7.2.3).
- [docker](src/docker) Improve debug message in [docker-service.sh](src/docker/bin/docker-service.sh).
- [test](test/Makefile) Wait for rspamd to open its ipc socket before sending test messages.

# 1.0.1

- [docker](Makefile) Use alpine:3.18 (rspamd:3.6 clamav:1.1.0 redis:7.0.12).
- [test](demo/Makefile) Now use the `mariadb-show` instead of `mysqlshow` command in MariaDB image.

# 1.0.0

- [docker](Makefile) Use alpine:3.18 (rspamd:3.5 clamav:1.1.0 redis:7.0.11).
- [github](.github/workflows/testimage.yml) Now use GitHub Actions to test image.
- [demo](demo/Makefile) Now depend on the `docker-compose-plugin`.
- [demo](demo/Makefile) Fix the broken `-diff` target.
- [docker](Makefile) Add a `build-all` target for compatibility with multistage builds.
- [docker](Dockerfile) Make sure to merge `rspamd.conf.docker` in `rspamd.conf`.
- [repo](.) Based on [mlan/postfix-amavis](https://github.com/mlan/docker-postfix).
- [repo](README.md) Described approach for configure Rspamd using environment variables.
- [repo](README.md) Now use `DKIM_DOMAIN` instead of `MAIL_DOMAIN` .
- [repo](ROADMAP.md) A selection of Rspamd modules are configured using environment variables is described.
- [repo](ROADMAP.md) Describe the rspamd web interface.
- [repo](Makefile) Don't advertize multistage builds yet.
- [repo](Makefile) Now use functions in `bld.mk`.
- [repo](.travis.yml) Cleaned up dependencies for travis.
- [rspamd](src/rspamd) Consolidate configuration into [rspamd.conf.docker](src/rspamd/etc/rspamd/rspamd.conf.docker).
- [rspamd](src/rspamd) Correcting worker configuration in `rspamd.conf.docker`.
- [rspamd](src/rspamd) Configure Rspamd using environment variables.
- [rspamd](src/rspamd) Cleaned up `rspamd.conf.docker`.
- [rspamd](src/rspamd) Fixed rspamd_setup_dkim().
- [rspamd](src/rspamd) Fixed rspamd_monitor_spamd().
- [test](test/Makefile) Rspamd test suite arranged.
- [test](test/Makefile) Monitor logs to determine when clamd is activated.
- [test](test/Makefile) Don't advertize multistage builds yet.
- [test](test/Makefile) Added Bayes initialization.
- [test](.travis.yml) Updated dist to jammy.
- [demo](demo/Makefile) Start migration to rspamd.
- [demo](demo/.env) Now use `FLT_` instead of `FILT_`.
- [demo](demo/Makefile) Demo now use Rspamd environment variables.
- [demo](demo/Makefile) Monitor logs to determine when clamd is activated.
- [demo](demo/Makefile) Now use `flt` instead of `filt`.
- [demo](demo/Makefile) Added `flt-test_rand`, `flt-config`.
- [demo](demo/docker-compose.yml) Added - `DKIM_DOMAIN=${MAIL_DOMAIN-example.com}`.
- [demo](demo/Makefile) Fixed target `mta-edh`.
