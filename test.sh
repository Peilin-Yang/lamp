#!/bin/bash

set -e

echo "=> Building mysql 5.5 image"
docker build -t mysql-5.5 5.5/

echo "=> Testing if mysql is running on 5.5"
docker run -d -p 13306:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13306 ping | grep -c "mysqld is alive"

echo "=> Testing volume on mysql 5.5"
mkdir vol55
docker run --name mysql55.1 -d -p 13309:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" -v "$(pwd)/vol55":/var/lib/mysql mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13309 ping | grep -c "mysqld is alive"
docker stop mysql55.1
docker run  -d -p 13310:3306 -v "$(pwd)/vol55":/var/lib/mysql mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13310 ping | grep -c "mysqld is alive"

echo "=>Done"
