FROM ubuntu:trusty
MAINTAINER Ningappa <ningappa@poweruphosting.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y git apache2 php5-cli php5-mysql php5-gd php5-curl php5-xdebug php5-sqlite libapache2-mod-php5 curl mysql-server mysql-client phpmyadmin wget unzip cron supervisor

RUN apt-get clean

ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh


RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf


#ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
#ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drupal Console.
RUN curl http://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal
RUN drupal init

# Install Drupal.
RUN rm -rf /var/www/html
RUN cd /var/www && \
	drupal site:new html 8.1.8
RUN mkdir -p /var/www/html/sites/default/files && \
	chmod a+w /var/www/html/sites/default -R && \
	mkdir /var/www/html/sites/all/modules/contrib -p && \
	mkdir /var/www/html/sites/all/modules/custom && \
	mkdir /var/www/html/sites/all/themes/contrib -p && \
	mkdir /var/www/html/sites/all/themes/custom && \
	cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php && \
	cp /var/www/html/sites/default/default.services.yml /var/www/html/sites/default/services.yml && \
	chmod 0664 /var/www/html/sites/default/settings.php && \
	chmod 0664 /var/www/html/sites/default/services.yml && \
	chown -R www-data:www-data /var/www/html/
RUN /etc/init.d/mysql start && \
	cd /var/www/html && \
	drupal site:install standard \
		--site-name="Drupal 8" \
		--db-type=mysql \
		--db-user=${MYSQL_USER:-'admin'} \
		--db-pass=${MYSQL_PASS:-'admin'} \
		--db-name=drupal \
		--site-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
		--account-name=${WP_USER:-'admin'} \
		--account-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
		--account-pass=${WP_PASS:-'password'}
RUN /etc/init.d/mysql start && \
	cd /var/www && \
	drupal module:install admin_toolbar --latest && \
drupal module:install devel --latest

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]