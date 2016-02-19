#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

if [ "$MYSQL_PASS" = "**Random**" ]; then
    unset MYSQL_PASS
fi

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

# You can create a /mysql-setup.sh file to intialized the DB
if [ -f /mysql-setup.sh ] ; then
  . /mysql-setup.sh
fi

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

# On Create DB ...
if [ "$ON_CREATE_DB" = "**False**" ]; then
    unset ON_CREATE_DB
else
    echo "Creating MySQL database ${ON_CREATE_DB}"
    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${ON_CREATE_DB};"
    echo "Database created!"
fi

