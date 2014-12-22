# creation de la base de donnée pour jeedom
create database jeedom;

# sélection de la base de donnée
use jeedom;

# création d'un utilisateur dédié à l'exploitation de cette base de donnée (veuillez modifier utilisateur et motdepasse à votre convenance)
create user  'jeedom'@'localhost' identified by '#PASSWORD#';
grant all privileges on jeedom.* to 'jeedom'@'localhost';

# rechargement des droits
flush privileges;

#deconnection
exit
