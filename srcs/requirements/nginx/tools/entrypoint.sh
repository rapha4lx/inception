#!/bin/sh
set -eu

if [ -z "${DOMAIN_NAME:-}" ]; then
	echo "Missing required environment variable: DOMAIN_NAME" >&2
	exit 1
fi

mkdir -p /etc/nginx/ssl /var/www/html

if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/CN=${DOMAIN_NAME}" >/dev/null 2>&1
fi

envsubst '${DOMAIN_NAME}' \
	< /etc/nginx/templates/inception.conf.template \
	> /etc/nginx/sites-available/default

exec "$@"
