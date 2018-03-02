#!/bin/sh

#Setup MariaDB
/bin/sh /mariadb.sh

until $(nc -zv 127.0.0.1 3306); do
  printf 'Waiting for MySQL to come up.'
  sleep 5
done

if [ ! -f /etc/wpinstalled ]; then
    # Download WordPress
    wp_version=4.9.4 && \
    curl -L "https://wordpress.org/wordpress-${wp_version}.tar.gz" > /wordpress-${wp_version}.tar.gz && \
    rm -fr /var/www/html/index.html && \
    tar -xzf /wordpress-${wp_version}.tar.gz -C /var/www/html --strip-components=1 && \
    rm /wordpress-${wp_version}.tar.gz

    # Download WordPress CLI
    cli_version=1.4.1 && \
    curl -L "https://github.com/wp-cli/wp-cli/releases/download/v${cli_version}/wp-cli-${cli_version}.phar" > /usr/bin/wp && \
    chmod +x /usr/bin/wp

    if ! $(wp core is-installed  --allow-root --path='/var/www/html'); then
       echo "=> WordPress is not configured yet, configuring WordPress ..."

       mv /wp-config.php /var/www/html/wp-config.php
       chown -R nginx:nginx /var/www/html

       echo "=> Installing WordPress to ${WP_URL}"
       sed -i "s#WP_URL#${WP_URL}#g" /var/www/html/wp-config.php
       sed -i "s/MYSQL_USERNAME/${MYSQL_WP_USER}/g" /var/www/html/wp-config.php
       sed -i "s/MYSQL_PASSWORD/${MYSQL_ROOT_PASSWORD}/g" /var/www/html/wp-config.php
       wp --allow-root core install --path='/var/www/html' --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"
       touch /etc/wpinstalled
    else
       echo "=> WordPress is already configured."
    fi

else
    echo "WP is already installed, just start up."
fi

# Start supervisord and services (These are inherited from alpine-lemp)
exec /usr/bin/supervisord -n -c /etc/supervisord.conf


