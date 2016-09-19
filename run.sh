#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

RUN /etc/init.d/mysql start && \
	cd /var/www/html && \
	drupal site:install standard \
		--langcode en \
		--site-name="Drupal 8" \
		--db-type='mysql' \
		--db-host="localhost" \
		--db-port=3306 \
		--db-user=${MYSQL_USER:-'admin'} \
		--db-pass=${MYSQL_PASS:-'admin'} \
		--db-name=${MYSQL_DBNAME:-'admin'} \
		--db-prefix="drupal_" \
		--site-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
		--account-name=${WP_USER:-'admin'} \
		--account-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
		--account-pass=${WP_PASS:-'password'}
		
		
drupal check
cd /var/www/html && \
	drupal module:download admin_toolbar --latest && \ 
	drupal module:install admin_toolbar --latest && \
	drupal module:download devel --latest && \ 
    	drupal module:install devel --latest
exec supervisord -n
