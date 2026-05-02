FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		gettext-base \
		nginx \
		openssl \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /etc/nginx/ssl /var/www/html

COPY conf/inception.conf.template /etc/nginx/templates/inception.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
