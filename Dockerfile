FROM mazzolino/armhf-debian

MAINTAINER del65@free.fr

ENV MYSQL_ROOT_PASSWORD `head -c 16 /dev/urandom  | sha1sum | cut -c1-40`
RUN echo MySQL root password : ${MYSQL_ROOT_PASSWORD}
ENV MYSQL_JEEDOM_PASSWORD `head -c 16 /dev/urandom  | sha1sum | cut -c1-40`
RUN echo MySQL jeedom user password : ${MYSQL_JEEDOM_PASSWORD}
ENV SHELL_ROOT_PASSWORD `head -c 16 /dev/urandom  | sha1sum | cut -c1-40`
RUN echo Shell root password : ${SHELL_ROOT_PASSWORD}

RUN apt-get update
RUN apt-get install -y ffmpeg libssh2-php ntp unzip miniupnpc curl wget nginx-common nginx-full openssh-server supervisor cron usb-modeswitch python-serial php5-common php5-fpm php5-cli php5-curl php5-json php5-mysql

# base de données
RUN echo "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
RUN apt-get install -y mysql-client mysql-common mysql-server mysql-server-core

# nodejs
RUN echo 'deb http://ftp.it.debian.org/debian wheezy-backports main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nodejs nodejs-legacy

# recuperation du script d'installation et exécution suite au téléchargement
RUN curl -sL --insecure https://www.npmjs.org/install.sh | bash -

# modification de la configuration PHP pour un temps d'exécution allongé et le traitement de fichiers lourds
RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php5/fpm/php.ini
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 1G/g" /etc/php5/fpm/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 1G/g" /etc/php5/fpm/php.ini

# installation nginx
RUN mkdir -p /usr/share/nginx/jeedom

# téléchargement de l'archive
RUN cd /usr/share/nginx/jeedom/ && wget --no-check-certificate -O jeedom.zip https://market.jeedom.fr/jeedom/stable/jeedom.zip

# décompression de l'archive dans un nouveau dossier "www"
RUN cd /usr/share/nginx/jeedom/ && unzip jeedom.zip -d www

# ajout au préalable d'un dossier tmp
RUN mkdir -p /usr/share/nginx/jeedom/www/tmp

# définition des droits utilisateur/groupes/autres de manière récursif
RUN chmod 755 -R /usr/share/nginx/jeedom/www

# délégation des droits pour l'utilisateur www-data de manière récursif
RUN chown -R www-data:www-data /usr/share/nginx/jeedom/www

# ajout de l'utilisateur www-data au group dialout (pour piloter la connexion 3G éventuelle)
RUN adduser www-data dialout

# on copie le fichier de configuration d'exemple 
RUN cp /usr/share/nginx/jeedom/www/core/config/common.config.sample.php /usr/share/nginx/jeedom/www/core/config/common.config.php

# on modifie le contenu avec les paramètres fixés lors de la configuration de l'utilisateur mysql dédié (cf. "Bases de données mysql")
RUN sed -i "s/#PASSWORD#/${MYSQL_JEEDOM_PASSWORD}/g" /usr/share/nginx/jeedom/www/core/config/common.config.php

ADD create_jeedom_db.sql /tmp/create_jeedom_db.sql
RUN sed -i "s/#PASSWORD#/${MYSQL_JEEDOM_PASSWORD}/g" /tmp/create_jeedom_db.sql
ADD init_jeedom_db.sh /tmp/init_jeedom_db.sh

RUN sh /tmp/init_jeedom_db.sh

ADD install_jeedom.sh /tmp/install_jeedom.sh
RUN sh /tmp/install_jeedom.sh

ADD nginx.conf /etc/nginx/sites-available/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN echo "root:${SHELL_ROOT_PASSWORD}" | chpasswd

RUN mkdir -p /var/run/sshd /var/log/supervisor

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo "* * * * * su --shell=/bin/bash - www-data -c 'nice -n 19 /usr/bin/php /usr/share/nginx/jeedom/www/core/php/jeeCron.php' >> /dev/null" | crontab -

EXPOSE 22 8080 9001
CMD ["/usr/bin/supervisord"]
