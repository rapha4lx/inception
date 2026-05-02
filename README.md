# Inception

This project builds the mandatory 42 Inception stack with one container per
service:

- NGINX, exposed only on HTTPS port `443`
- WordPress running through PHP-FPM on the internal Docker network
- MariaDB on the internal Docker network

All service images are built from `debian:bookworm`.

## Prerequisites

- Docker
- Docker Compose plugin
- A Linux VM or host where Docker can bind port `443`
- A local domain pointing to `127.0.0.1`

Add the domain to `/etc/hosts`:

```txt
127.0.0.1 rapha4lx.42.fr
```

## Environment

Create the runtime environment file:

```sh
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env` and replace every placeholder password. Do not commit
`srcs/.env`.

Important variables:

- `LOGIN`: your 42 login
- `DOMAIN_NAME`: local domain served by NGINX
- `DATA_PATH`: host data directory, normally `/home/<login>/data`
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_ROOT_PASSWORD`
- `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL`
- `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL`

The WordPress administrator username must not contain `admin` or
`administrator`.

## Data

The Makefile creates the expected host directories:

```txt
/home/<login>/data/mariadb
/home/<login>/data/wordpress
```

MariaDB data and WordPress files persist there through Docker named volumes
backed by bind mounts.

## Commands

```sh
make          # create data directories, build, and start the stack
make build    # build images
make down     # stop containers
make re       # rebuild and restart from scratch
make logs     # follow logs
make status   # show container status
make fclean   # remove containers, local images, and Docker volumes
```

Debug shells are available through:

```sh
make shell-nginx
make shell-wordpress
make shell-mariadb
```

## Validation

After `make`, open:

```txt
https://rapha4lx.42.fr
```

The generated TLS certificate is self-signed, so the browser may show a local
certificate warning.

Use [docs/evaluation-checklist.md](docs/evaluation-checklist.md) before peer
evaluation.
