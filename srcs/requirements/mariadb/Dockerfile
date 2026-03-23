# Utiliza a imagem oficial do MariaDB
FROM mariadb:11.3

# Copia arquivos de configuração personalizados, se existirem
# COPY conf/my.cnf /etc/mysql/my.cnf
# COPY tools/init.sql /docker-entrypoint-initdb.d/

# Define variáveis de ambiente (serão sobrescritas pelo docker-compose/.env)
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}

EXPOSE 3306
