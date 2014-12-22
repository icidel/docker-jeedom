#!/bin/bash
/usr/bin/mysqld_safe &
sleep 5
mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/create_jeedom_db.sql
