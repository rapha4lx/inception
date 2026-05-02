#!/bin/sh
set -eu

require_var() {
	if [ -z "${1:-}" ]; then
		echo "Missing required environment variable: $2" >&2
		exit 1
	fi
}

require_var "${DB_NAME:-}" "DB_NAME"
require_var "${DB_USER:-}" "DB_USER"
require_var "${DB_PASSWORD:-}" "DB_PASSWORD"
require_var "${DB_ROOT_PASSWORD:-}" "DB_ROOT_PASSWORD"

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

	mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking \
		--socket=/run/mysqld/mysqld.sock &
	pid="$!"

	i=0
	until mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
		i=$((i + 1))
		if [ "$i" -gt 60 ]; then
			echo "MariaDB bootstrap server did not start" >&2
			exit 1
		fi
		sleep 1
	done

	mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		DROP USER IF EXISTS ''@'localhost';
		DROP USER IF EXISTS ''@'%';
		DROP DATABASE IF EXISTS test;
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
	SQL

	mariadb-admin --socket=/run/mysqld/mysqld.sock \
		-u root -p"${DB_ROOT_PASSWORD}" shutdown
	wait "$pid"
fi

exec "$@"
