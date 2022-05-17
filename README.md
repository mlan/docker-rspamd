# The `mlan/rspamd` repository

![travis-ci test](https://img.shields.io/travis/com/mlan/docker-rspamd.svg?label=build&style=flat-square&logo=travis)
![docker version](https://img.shields.io/docker/v/mlan/rspamd?logo=docker&style=flat-square)
![image size](https://img.shields.io/docker/image-size/mlan/rspamd/latest.svg?label=size&style=flat-square&logo=docker)
![docker pulls](https://img.shields.io/docker/pulls/mlan/rspamd.svg?label=pulls&style=flat-square&logo=docker)
![docker stars](https://img.shields.io/docker/stars/mlan/rspamd.svg?label=stars&style=flat-square&logo=docker)
![github stars](https://img.shields.io/github/stars/mlan/docker-rspamd.svg?label=stars&style=flat-square&logo=github)

This (non official) repository provides dockerized mail filter [anti-spam](https://en.wikipedia.org/wiki/Anti-spam_techniques) and anti-virus filter using [Rspamd](https://rspamd.com/), and [ClamAV](https://www.clamav.net/), which also provides sender authentication using [SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework) and [DKIM](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail).

It uses a robust scoring framework and plug-ins to integrate a wide range of advanced heuristic and statistical analysis tests on email headers and body text including text analysis, Bayesian filtering, DNS block-lists, and collaborative filtering databases. Clam AntiVirus is an anti-virus toolkit, designed especially for e-mail scanning on mail gateways.

## Features

- [Anti-spam](#incoming-anti-spam-and-anti-virus) filter [Rspamd](https://rspamd.com/)
- [Anti-virus](#incoming-anti-spam-and-anti-virus) [ClamAV](https://www.clamav.net/)
- Sender authentication using [SPF](#incoming-spf-sender-authentication) and [DKIM](#dkim-sender-authentication)
- Consolidated configuration and run data under `/srv` to facilitate [persistent storage](#persistent-storage)
- Simplified configuration of [DKIM](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail) keys using environment variables
- [Kopano-spamd](#kopano-spamd-integration-with-mlankopano) integration with [mlan/kopano](https://github.com/mlan/docker-kopano)
- Configuration using [environment variables](#environment-variables)
- [Log](#logging-syslog_level-log_level-sa_debug) directed to docker daemon with configurable level
- Makefile which can build images and do some management and testing
- Health check
- Small image size based on [Alpine Linux](https://alpinelinux.org/)
- [Demo](#demo) based on `docker-compose.yml` and `Makefile` files

## Tags

The MAJOR.MINOR.PATCH [SemVer](https://semver.org/) is used. In addition to the three number version number you can use two or one number versions numbers, which refers to the latest version of the sub series. The tag `latest` references the build based on the latest commit to the repository.

To exemplify the usage of version tags, lets assume that the latest version is `1.0.0`. In this case `latest`, `1.0.0`, `1.0` and `1` all identify the same image.

# Usage

Often you want to configure Rspamd and its components. There are different methods available to achieve this. Many aspects can be configured using [environment variables](#environment-variables) described below. These environment variables can be explicitly given on the command line when creating the container. They can also be given in an `docker-compose.yml` file, see the [docker compose example](#docker-compose-example) below. Moreover docker volumes or host directories with desired configuration files can be mounted in the container. And finally you can `docker exec` into a running container and modify configuration files directly.

You can start a `mlan/rspamd` container using the destination domain `example.com` and table mail boxes for info@example.com and abuse@example.com by issuing the shell command below.

```bash
docker run -d --name flt -e 'WORKER_CONTROLLER=password="secret";' -p 127.0.0.1:11334:11334 mlan/rspamd
```

One convenient way to test the image is to clone the [github](https://github.com/mlan/docker-rspamd) repository and run the [demo](#demo) therein, see below.

## Docker compose example

An example of how to configure an mail filter using docker compose is given below. By it self the mail filter is perhaps not so exiting. A more complete configuration is shown in the [demo](#demo).

```yaml
version: '3'

services:
  flt:
    image: mlan/rspamd
    ports:
      - "127.0.0.1:11334:11334" # HTML Rspamd WebGui
    environment: # Virgin config, ignored on restarts unless FORCE_CONFIG given.
      - WORKER_CONTROLLER=password="${FLT_PASSWD-secret}";
      - METRICS=${FLT_METRIC}
      - SYSLOG_LEVEL=${SYSLOG_LEVEL-}
      - LOGGING=level="${FILT_LOGGING-error}";
    volumes:
      - flt:/srv
      - /etc/localtime:/etc/localtime:ro        # Use host timezone
    cap_add: # helps debugging by allowing strace
      - sys_ptrace

volumes:
  flt:
```

## Demo

This repository contains a [demo](demo) where 5 services are defined. It is comprised of `app`, `mta`, `flt`, `db` and `auth`, which are the web mail server, the mail transfer agent, the mail filter, the SQL database and LDAP authentication respectively.

You find the demoin the [demo](demo) directory, which hold the [docker-compose.yml](demo/docker-compose.yml) file as well as a [Makefile](demo/Makefile) which might come handy. Start with cloning the [github](https://github.com/mlan/docker-rspamd) repository.

```bash
git clone https://github.com/mlan/docker-rspamd.git
```

From within the [demo](demo) directory you can start the containers by typing:

```bash
make init
```

Then you can assess WebApp on the URL [`http://localhost:8008`](http://localhost:8008) and log in with the user name `demo` and password `demo` .

```bash
make web
```

You can send yourself a test email by typing:

```bash
make test
```

When you are done testing you can destroy the test containers by typing

```bash
make destroy
```

## Rspamd web interface

Rspamd comes with a simple web-based control interface for Rspamd spam filtering system. It provides basic functions for setting metric actions, scores, viewing statistic and learning.

![Rspamd web interface](https://rspamd.com/img/webui.png)

From the [demo](demo) you can assess the Rspamd WebUI on the URL [`http://localhost:11334`](http://localhost:11334) and log in with the password `demo` .

```bash
make filt-web
```

## Persistent storage

By default, docker will store the configuration and run data within the container. This has the drawback that the configurations and queued and quarantined mail are lost together with the container should it be deleted. It can therefore be a good idea to use docker volumes and mount the run directories and/or the configuration directories there so that the data will survive a container deletion.

To facilitate such approach, to achieve persistent storage, the configuration and run directories of the services has been consolidated to `/srv/etc` and `/srv/var` respectively. So if you to have chosen to use both persistent configuration and run data you can run the container like this:

```bash
docker run -d --name flt -v flt:/srv -p 127.0.0.1:11334:11334 mlan/rspamd
```

When you start a container which creates a new volume, as above, and the container has files or directories in the directory to be mounted (such as `/srv/` above), the directory’s contents are copied into the volume. The container then mounts and uses the volume, and other containers which use the volume also have access to the pre-populated content. More details [here](https://docs.docker.com/storage/volumes/#populate-a-volume-using-a-container).

## Configuration / seeding procedure

The `mlan/rspamd` image contains an elaborate configuration / seeding procedure. The configuration is controlled by environment variables, described below.

The seeding procedure will leave any existing configuration untouched. This is achieved by the using an unlock file: `DOCKER_UNLOCK_FILE=/srv/etc/.docker.unlock`.
During the image build this file is created. When the the container is started the configuration / seeding procedure will be executed if the `DOCKER_UNLOCK_FILE` can be found. Once the procedure completes the unlock file is deleted preventing the configuration / seeding procedure to run when the container is restarted.

The unlock file approach was selected since it is difficult to accidentally _create_ a file.

In the rare event that want to modify the configuration of an existing container you can override the default behavior by setting `FORCE_CONFIG=OVERWRITE` to a no-empty string.

## Environment variables

When you create the `mlan/rspamd` container, you can configure the services by passing one or more environment variables or arguments on the docker run command line. Once the services has been configured a lock file is created, to avoid repeating the configuration procedure when the container is restated.

## MTA integration with [mlan/postfix](https://github.com/mlan/docker-postfix)

The [rspamd proxy worker](https://rspamd.com/doc/workers/rspamd_proxy.html#milter-support) in Milter mode, which is enabled by default, interact with Postfix. Use the [Postfix configuration](https://rspamd.com/doc/integration.html#configuring-postfix) to have Postfix scan messages on Rspamd via the milter protocol. The rspamd proxy worker listens to port `11334` by default.

## Actions

Unlike SpamAssassin, Rspamd suggests the desired [action](https://rspamd.com/doc/faq.html#what-are-rspamd-actions) for a specific message scanned. This could be treated as a recommendation to MTA what it should do with this message. So Rspamd does not keep any quarantined emails.

## Filter metrics

FILT_METRIC='actions {greylist=4;add_header=6;rewrite_subject=8;reject=15;} group "antivirus" { symbol "VIRUS_EICAR" {weight=15;description="Eicar test signature";} symbol "CLAM_VIRUS" {weight=15;description="ClamAV found a Virus";}}'

## Antivirus

The Antivirus module provides integration with virus scanners. The `mlan/rspamd` image have [ClamAV](https://www.clamav.net/) configured and installed.

### ClamAV virus signatures

[ClamAV](https://www.clamav.net/) (`clamd`) requires a virus signature database to run. The database is kept up to date with official signatures using `freshclam`, which also runs in the `mlan/rspamd` image.

### ClamAV memory usage

ClamAV holds search strings and regular expression in memory. The algorithms used are from the 1970s and are very memory efficient. The problem is the huge number of virus signatures. This leads to the algorithms' data-structures growing quite large. Consequently, The minimum recommended system requirements are for using [ClamAV](https://www.clamav.net/documents/introduction) is 1GiB.
## SPF

The SPF module performs checks of the sender’s [SPF](http://www.open-spf.org/) policy.

[Sender Policy Framework (SPF)](https://en.wikipedia.org/wiki/Sender_Policy_Framework) is an [email authentication](https://en.wikipedia.org/wiki/Email_authentication) method designed to detect forged sender addresses in emails. SPF allows the receiver to check that an email claiming to come from a specific domain comes from an IP address authorized by that domain's administrators. The list of authorized sending hosts and IP addresses for a domain is published in the [DNS](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) records for that domain.

## DKIM

Rspamd is configured to check the digital signature of incoming email as well as add digital signatures to outgoing email.

## DKIM signing

[Domain-Keys Identified Mail (DKIM)](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail) is an [email authentication](https://en.wikipedia.org/wiki/Email_authentication) method designed to detect forged sender addresses in emails. DKIM allows the receiver to check that an email claimed to have come from a specific [domain](https://en.wikipedia.org/wiki/Domain_name) was indeed authorized by the owner of that domain. It achieves this by affixing a [digital signature](https://en.wikipedia.org/wiki/Digital_signature), linked to a domain name, `MAIL_DOMAIN`, to each outgoing email message, which the receiver can verify by using the DKIM key published in the [DNS](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) records for that domain.

#### `DKIM_KEYBITS`

The bit length used when creating new keys. Default: `DKIM_KEYBITS=2048`

#### `DKIM_SELECTOR`

The public key DNS record should appear as a TXT resource record at: `DKIM_SELECTOR._domainkey.MAIL_DOMAIN`. The TXT record to be used with the private key generated at container creation is written here: `/var/db/dkim/MAIL_DOMAIN.DKIM_SELECTOR._domainkey.txt`.
Default: `DKIM_SELECTOR=default`

#### `DKIM_PRIVATEKEY`

DKIM uses a private and public key pair used for signing and verifying email. A private key is created when the container is created. If you already have a private key you can pass it to the container by using the environment variable `DKIM_PRIVATEKEY`. For convenience the strings `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` can be omitted form the key string. For example `DKIM_PRIVATEKEY="MIIEpAIBAAKCAQEA04up8hoqzS...1+APIB0RhjXyObwHQnOzhAk"`

The private key is stored here `/var/lib/rspamd/dkim/MAIL_DOMAIN.DKIM_SELECTOR.key`, so alternatively you can copy the private key into the container:

```bash
docker cp $MAIL_DOMAIN.$DKIM_SELECTOR.key <container_name>:var/lib/rspamd/dkim
```

If you wish to create a new private key you can run:

```bash
docker exec -it <container_name> rspamadm dkim_keygen -s $DKIM_SELECTOR -b $DKIM_KEYBITS -d $MAIL_DOMAIN -k /var/lib/rspamd/dkim/$MAIL_DOMAIN.$DKIM_SELECTOR.key
```

## Kopano-spamd integration with [mlan/kopano](https://github.com/mlan/docker-kopano)

[Kopano-spamd](https://kb.kopano.io/display/WIKI/Kopano-spamd) allow users to
drag messages into the Junk folder triggering the anti-spam filter to learn it
as spam. If the user moves the message back to the inbox, the anti-spam filter
will unlearn it.

To allow kopano-spamd integration the kopano and rspamd containers need
to share the `KOPANO_SPAMD_LIB=/var/lib/kopano/spamd` folder.
If this directory exists within the
rspamd container, the spamd-spam and spamd-ham service will be started.
They will run `rspamc learn_spam` or `rspamc learn_ham`,
respectively when a message is placed in either `var/lib/kopano/spamd/spam` or
`var/lib/kopano/spamd/ham`.

## Logging `SYSLOG_LEVEL`

The level of output for logging is in the range from 0 to 7. The default is: `SYSLOG_LEVEL=5`

| emerg | alert | crit | err  | warning | notice | info | debug |
| ----- | ----- | ---- | ---- | ------- | ------ | ---- | ----- |
| 0     | 1     | 2    | 3    | 4       | **5**  | 6    | 7     |

# Knowledge base

Here some topics relevant for arranging a mail server are presented.

## DNS records

The [Domain Name System](https://en.wikipedia.org/wiki/Domain_Name_System) (DNS) is a [hierarchical](https://en.wikipedia.org/wiki/Hierarchical) and [decentralized](https://en.wikipedia.org/wiki/Decentralised_system) naming system for computers, services, or other resources connected to the [Internet](https://en.wikipedia.org/wiki/Internet) or a private network.

### SPF record

An [SPF record](https://en.wikipedia.org/wiki/Sender_Policy_Framework) is a [TXT](https://en.wikipedia.org/wiki/TXT_Record) record that is part of a domain's DNS zone file.
The TXT record specifies a list of authorized host names/IP addresses that mail can originate from for a given domain name. An example of such TXT record is give below

```
"v=spf1 ip4:192.0.2.0/24 mx include:example.com a -all"
```

### DKIM record

The public key DNS record should appear as a [TXT](https://en.wikipedia.org/wiki/TXT_Record) resource record at: `DKIM_SELECTOR._domainkey`

The data returned from the query of this record is also a list of tag-value pairs. It includes the domain's [public key](https://en.wikipedia.org/wiki/Public_key), along with other key usage tokens and flags as in this example:

```
"k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDmzRmJRQxLEuyYiyMg4suA2Sy
MwR5MGHpP9diNT1hRiwUd/mZp1ro7kIDTKS8ttkI6z6eTRW9e9dDOxzSxNuXmume60Cjbu08gOyhPG3
GfWdg7QkdN6kR4V75MFlw624VY35DaXBvnlTJTgRg/EW72O1DiYVThkyCgpSYS8nmEQIDAQAB"
```

The receiver can use the public key (value of the p tag) to then decrypt the hash value in the header field, and at the same time recalculate the hash value for the mail message (headers and body) that was received.

# Implementation

Here some implementation details are presented.

## Container init scheme

The container use [runit](http://smarden.org/runit/), providing an init scheme and service supervision, allowing multiple services to be started. There is a Gentoo Linux [runit wiki](https://wiki.gentoo.org/wiki/Runit).

When the container is started, execution is handed over to the script [`docker-entrypoint.sh`](src/docker/bin/docker-entrypoint.sh). It has 4 stages; 0) *register* the SIGTERM [signal (IPC)](https://en.wikipedia.org/wiki/Signal_(IPC)) handler, which is programmed to run all exit scripts in `/etc/docker/exit.d/` and terminate all services, 1) *run* all entry scripts in `/etc/docker/entry.d/`, 2) *start* services registered in `SVDIR=/etc/service/`, 3) *wait* forever, allowing the signal handler to catch the SIGTERM and run the exit scripts and terminate all services.

The entry scripts are responsible for tasks like, seeding configurations, register services and reading state files. These scripts are run before the services are started.

There is also exit script that take care of tasks like, writing state files. These scripts are run when docker sends the SIGTERM signal to the main process in the container. Both `docker stop` and `docker kill --signal=TERM` sends SIGTERM.

## Build assembly

The entry and exit scripts, discussed above, as well as other utility scrips are copied to the image during the build phase. The source file tree was designed to facilitate simple scanning, using wild-card matching, of source-module directories for files that should be copied to image. Directory names indicate its file types so they can be copied to the correct locations. The code snippet in the `Dockerfile` which achieves this is show below.

```dockerfile
COPY	src/*/bin $DOCKER_BIN_DIR/
COPY	src/*/entry.d $DOCKER_ENTRY_DIR/
```

There is also a mechanism for excluding files from being copied to the image from some source-module directories. Source-module directories to be excluded are listed in the file [`.dockerignore`](https://docs.docker.com/engine/reference/builder/#dockerignore-file). Since we don't want files from the module `notused` we list it in the `.dockerignore` file:

```sh
src/notused
```
