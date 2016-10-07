FROM ubuntu:trusty
MAINTAINER Ningappa <ningappa@poweruphosting.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y git apache2 php5-cli php5-mysql php5-gd php5-curl  php5-sqlite libapache2-mod-php5 curl mysql-server mysql-client phpmyadmin wget unzip cron supervisor && \
echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get clean && \
	a2enmod rewrite
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh

ADD run.sh /run.sh
RUN chmod 755 /*.sh

RUN sed -i -e 's/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/' /etc/mysql/my.cnf

ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drupal Console.
RUN curl https://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal
RUN drupal init --override


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



#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
