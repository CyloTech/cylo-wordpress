FROM repo.cylo.io/alpine-lemp:latest
LABEL maintainer="Gavin Hanson <glow@cylo.io>"

# MySQL environment variables
ENV MYSQL_USER root
ENV MYSQL_DATABASE wordpress
ENV MYSQL_PASSWORD ${MYSQL_ROOT_PASSWORD}
ENV MYSQL_WP_USER ${MYSQL_USER}
ENV MYSQL_WP_PASSWORD ${MYSQL_ROOT_PASSWORD}

# WordPress configuration
ADD conf/wp-config.php /wp-config.php

ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /*.sh

# WordPress environment variables
ENV WP_URL $(WP_URL:-"localhost")
ENV WP_TITLE ${WP_TITLE:-"Wordpress Blog"}
ENV WP_ADMIN_USER ${WP_ADMIN_USER:-"WPAdmin"}
ENV WP_ADMIN_PASSWORD ${WP_ADMIN_PASSWORD:-"WPPassword"}
ENV WP_ADMIN_EMAIL ${WP_ADMIN_EMAIL:-"test@test.com"}

CMD ["/entrypoint.sh"]