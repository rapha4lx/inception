#!/bin/sh
set -eu

require_var() {
	if [ -z "${1:-}" ]; then
		echo "Missing required environment variable: $2" >&2
		exit 1
	fi
}

require_var "${DOMAIN_NAME:-}" "DOMAIN_NAME"
require_var "${DB_NAME:-}" "DB_NAME"
require_var "${DB_USER:-}" "DB_USER"
require_var "${DB_PASSWORD:-}" "DB_PASSWORD"
require_var "${WP_TITLE:-}" "WP_TITLE"
require_var "${WP_ADMIN_USER:-}" "WP_ADMIN_USER"
require_var "${WP_ADMIN_PASSWORD:-}" "WP_ADMIN_PASSWORD"
require_var "${WP_ADMIN_EMAIL:-}" "WP_ADMIN_EMAIL"
require_var "${WP_USER:-}" "WP_USER"
require_var "${WP_USER_PASSWORD:-}" "WP_USER_PASSWORD"
require_var "${WP_USER_EMAIL:-}" "WP_USER_EMAIL"

admin_name="$(printf '%s' "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')"
case "$admin_name" in
	*admin*|*administrator*)
		echo "WP_ADMIN_USER must not contain admin or administrator" >&2
		exit 1
		;;
esac

mkdir -p /run/php /var/www/html
chown -R www-data:www-data /run/php /var/www/html

i=0
until mariadb-admin ping -h mariadb -u "$DB_USER" -p"$DB_PASSWORD" >/dev/null 2>&1; do
	i=$((i + 1))
	if [ "$i" -gt 60 ]; then
		echo "MariaDB is not reachable from WordPress" >&2
		exit 1
	fi
	sleep 1
done

if [ ! -f /var/www/html/wp-settings.php ]; then
	wp core download --path=/var/www/html --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
	wp config create \
		--path=/var/www/html \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="mariadb:3306" \
		--skip-check \
		--allow-root
fi

if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
	wp core install \
		--path=/var/www/html \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root
fi

if ! wp user get "$WP_USER" --path=/var/www/html --allow-root >/dev/null 2>&1; then
	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--path=/var/www/html \
		--user_pass="$WP_USER_PASSWORD" \
		--role=author \
		--allow-root
fi

chown -R www-data:www-data /var/www/html

exec "$@"
