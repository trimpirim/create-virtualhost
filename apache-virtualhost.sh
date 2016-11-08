#!/bin/bash


CURRENT_USER=$(who am i | awk '{print $1}')
PROJECT_DIR=
WWW_DIR="/Users/${CURRENT_USER}/Sites"
PROJECT_WWW_DIR=
DOMAIN=
APACHE_CONFIG="/etc/apache2/extra/vhosts"
IP_ADDRESS="127.0.0.1"

if [[ "$1" != "" ]]; then
  PROJECT_DIR="$1"
else
  echo "No project dir specified"
  exit 1
fi

if [[ "$2" != "" ]]; then
  DOMAIN="$2"
  PROJECT_WWW_DIR="${WWW_DIR}/$2"
else
  echo "No domain specified"
  exit 1
fi

if [[ "$4" != "" ]]; then
  WWW_DIR="$4"
fi

create_virtualhost()
{
  touch "${APACHE_CONFIG}/${DOMAIN}.conf"
  ln -s ${PROJECT_DIR} ${PROJECT_WWW_DIR}
  cat << __EOF >${APACHE_CONFIG}/${DOMAIN}.conf
# Created $date
<VirtualHost *:80>
  DocumentRoot "${PROJECT_WWW_DIR}"

  ServerName ${DOMAIN}
  ServerAlias ${DOMAIN}

  <Directory "${PROJECT_WWW_DIR}">
    AllowOverride All
    Options Indexes MultiViews FollowSymLinks
    Require all granted
  </Directory>
</VirtualHost>
__EOF

  /bin/echo "${IP_ADDRESS} ${DOMAIN}" >> /etc/hosts

  apachectl -k restart
}

create_virtualhost