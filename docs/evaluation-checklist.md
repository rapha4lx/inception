# Inception Evaluation Checklist

## Startup

- `srcs/.env` exists and contains non-placeholder passwords.
- `/etc/hosts` maps the configured domain to `127.0.0.1`.
- `make` builds all three custom images and starts the stack.
- `docker compose -f srcs/docker-compose.yml ps` shows `nginx`, `wordpress`,
  and `mariadb`.

## Mandatory Architecture

- NGINX is the only service exposing a host port.
- MariaDB has no `ports:` mapping.
- WordPress runs PHP-FPM only.
- Each mandatory service has its own container.
- The compose file uses a custom Docker network.
- No service uses `network_mode: host`, `links`, or `--link`.

## Images and Runtime

- All Dockerfiles start from `debian:bookworm`.
- No mandatory service uses a ready-made `mariadb`, `wordpress`, or `nginx`
  Docker Hub service image as its base.
- Entrypoints finish setup and `exec` the foreground service process.
- No Dockerfile or entrypoint uses `tail -f`, `sleep infinity`, or an infinite
  keepalive loop.

## WordPress

- `https://<login>.42.fr` serves the WordPress site.
- WordPress connects to MariaDB through the internal Docker network.
- The configured administrator account can log in.
- A second non-admin WordPress user exists.
- The administrator username does not contain `admin` or `administrator`.

## TLS

- NGINX listens on port `443`.
- TLS is restricted to TLSv1.2 and TLSv1.3.
- HTTP is not exposed as the mandatory public entrypoint.

## Persistence

- Create or modify a WordPress page.
- Run `make down`.
- Run `make`.
- Confirm the WordPress content is still present.
- Confirm MariaDB data is under `/home/<login>/data/mariadb`.
- Confirm WordPress files are under `/home/<login>/data/wordpress`.

## Cleanup

- `make down` stops the stack cleanly.
- `make re` rebuilds and starts the stack again.
- `make logs` gives useful logs for all services.
