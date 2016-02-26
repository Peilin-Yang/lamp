FROM ubuntu:14.04

MAINTAINER Peilin Yang <yangpeilyn@gmail.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install \
    lxc \
    supervisor \
    git \
    curl \
    apache2 \
    libapache2-mod-php5 \
    mysql-server \
    php5-mysql \
    pwgen \
    php-apc \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    php-pear \
    php-apc \
    phpmyadmin 

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD apache2.conf /etc/apache2/apache2.conf
ADD my.cnf /etc/mysql/my.cnf
ADD mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Add web site conf folder
ADD website.conf /etc/apache2/sites-available/website.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV PHP_ERROR_REPORTING E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
ENV PHPMYADMIN_ALIAS dba
ENV SITENAME testsite
ENV MYSQL_PASS=**Random** \
    ON_CREATE_DB=**False** 
    
# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 80 3306
CMD ["/run.sh"]
