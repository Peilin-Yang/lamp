#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

CreateMySQLUserandOnCreateDB ()
{
    if [[ ! -d $VOLUME_HOME/mysql ]]; then
        echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
        echo "=> Installing MySQL ..."
        mysql_install_db > /dev/null 2>&1
        echo "=> Done!"  
        /create_mysql_admin_user.sh
    else
        echo "=> Using an existing volume of MySQL"
    fi
}

ImportSql()
{
    for FILE in ${STARTUP_SQL}; do
        echo "=> Importing SQL file ${FILE}"
        if [ "$ON_CREATE_DB" ]; then
            mysql -uroot "$ON_CREATE_DB" < "${FILE}"
        else
            mysql -uroot < "${FILE}"
        fi
    done
}

SetupPHP ()
{
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" \
        -e "s/^error_reporting.*/error_reporting = ${PHP_ERROR_REPORTING}/" /etc/php5/apache2/php.ini

    # Add default index file
    rm /var/www/html/*
    echo "<?php phpinfo(); ?>" > /var/www/html/index.php
}

SetupPHPMyadmin() 
{
    # Add Phpmyadmin
    dpkg-reconfigure -plow phpmyadmin
    sed -ri -e "s/\ \/phpmyadmin/\ \/${PHPMYADMIN_ALIAS}/" /etc/phpmyadmin/apache.conf
    ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin.conf
}

SetupWebsite() 
{
    a2dissite *default
    mkdir -p /var/www/${SITENAME}
    mkdir -p /var/www/${SITENAME}/public_html
    mkdir -p /var/www/${SITENAME}/log
    mkdir -p /var/www/${SITENAME}/backups

    sed -ri -e "s/SERVERNAMETOBEREPLACED/${SITENAME}/" /etc/apache2/sites-available/website.conf

    a2ensite website.conf
}

CreateMySQLUserandOnCreateDB
ImportSql
SetupPHP
SetupPHPMyadmin
SetupWebsite

exec supervisord -n
