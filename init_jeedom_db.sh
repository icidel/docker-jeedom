#!/bin/bash
/usr/bin/mysqld_safe &
mysqladmin --silent --wait=30 ping || exit 1
mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/create_jeedom_db.sql
