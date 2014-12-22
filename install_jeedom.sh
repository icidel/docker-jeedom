#!/bin/bash
/usr/bin/mysqld_safe &
sleep 5
php /usr/share/nginx/jeedom/www/install/install.php mode=force
