#!/bin/bash
# Author: SmartKing <v.smartkin.g@gmail.com>
# URL: http://smartking.ru
# version: 0.01

# require  create_mysql_db.sh - version: 0.01

# exaple command: ./create_vhost.sh smartking.ru smartkingru 3dsasdf43@
# smartking.ru  - name domain
# smartkingru   - name user
# 3dsasdf43@    - root password Mysql

# CHANGE THESE VARIABLES TO MATCH YOUR CONFIGURATION!
IP_ADDRESS=`hostname -i`
SITE_NAME=$1 # example smartking.ru
USER_NAME=$2   # example smartkingru
MYSQL_ROOT_PWD=$3
ADMIN_EMAIL=admin@example.com
VHOST_CONF=/etc/apache2/sites-available/
OWNER=$USER_NAME:$USER_NAME
CHMOD=0755
UID_ROOT=0
APACHE2_DIR="/etc/apache2"

if [ $# -eq 0 ]
then
	echo -e "\nCreate virtual hosts.\n\nSyntax: $(basename $0) <domain.tld>\n"
	exit 1
fi

if [ "$UID" -ne "$UID_ROOT" ]
then
    echo "$0 - Requires root privileges"
    exit 1
fi

function is_user(){
    local check_user="$1";
    grep "$check_user:" /etc/passwd >/dev/null
    if [ $? -ne 0 ]
    then
        #echo "NOT HAVE USER"
        return 0
    else
        #echo "HAVE USER"
        return 1
    fi
}

function generate_pass(){
    CHARS="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()-_=+\\|/"
    LENGTH="12"
    while [ "${n:=1}" -le "$LENGTH" ] ; do
    PASSWORD="$PASSWORD${CHARS:$(($RANDOM%${#CHARS})):1}"
        let n+=1
    done
    echo $PASSWORD
}
function is_yes(){
    #TODO - add check 3-rd parameter for set default ansver (if press enter)
    while true
    do
    echo -n "Yes or No[Y/n]:"
    read  x
    if [ -z "$x" ]
    then
     return 0; #defaul answer: Yes
    fi
    case "$x" in
    y |Y |yes |Д |д |да ) return 0;;
    n |N |no |Н |н |нет ) return 1;;
    # * ) ; # asc again
    esac
        done
}

function create_user(){
    local login="$1"
    local password="$2"
    `useradd -m -s /bin/bash $login`
    #set password
    echo -e "$password\n$password\n" | passwd $login >> /dev/null
}

echo -n "Check user name $USER_NAME: "
if( is_user "$USER_NAME" )
then
    USER_PASSWORD="$(generate_pass)"
    echo "-----------------------------------"
    echo "User name    : $USER_NAME"
    echo "User password: $USER_PASSWORD"
    echo "-----------------------------------"
    echo -n "Continue? "
    if(! is_yes)
    then
        exit;
    fi
    echo "--- create user ---"
    create_user "$USER_NAME" "$USER_PASSWORD"
fi



if [ $# -eq 3 ]; then
    if [ "$2" != "none" ]; then
        mkdir /home/$USER_NAME/$SITE_NAME
        mkdir /home/$USER_NAME/$SITE_NAME/www
        mkdir /home/$USER_NAME/$SITE_NAME/logs
        mkdir /home/$USER_NAME/$SITE_NAME/tmp
        mkdir /home/$USER_NAME/$SITE_NAME/cgi-bin

        hostConf="
<VirtualHost *:80>
        ServerName $SITE_NAME
        ServerAlias www.$SITE_NAME
        ServerAdmin $ADMIN_EMAIL

        AddDefaultCharset utf-8
        AssignUserID ${USER_NAME} ${USER_NAME}

        DocumentRoot /home/$USER_NAME/$SITE_NAME/www
        CustomLog log combined
        ErrorLog /home/$USER_NAME/$SITE_NAME/logs/error.log
        DirectoryIndex index.php index.html

        ScriptAlias /cgi-bin/ /home/$USER_NAME/$SITE_NAME/cgi-bin
        <FilesMatch \"\\.ph(p[3-5]?|tml)$\">
                SetHandler application/x-httpd-php
        </FilesMatch>
        <FilesMatch \"\\.phps$\">
                SetHandler application/x-httpd-php-source
        </FilesMatch>
        php_admin_value upload_tmp_dir "/home/$USER_NAME/$SITE_NAME/tmp"
        php_admin_value session.save_path "/home/$USER_NAME/$SITE_NAME/tmp"
        php_admin_value open_basedir "/home/$USER_NAME/$SITE_NAME/www:."
</VirtualHost>
<Directory /home/$USER_NAME/$SITE_NAME/www>
        Options +Includes +ExecCGI
        php_admin_flag engine on
</Directory>
        "

        #touch ${APACHE2_DIR}/vhosts/${SITE_NAME}.conf
        touch ${APACHE2_DIR}/sites-available/${SITE_NAME}
        echo "$hostConf" >> ${APACHE2_DIR}/sites-available/${SITE_NAME}
        touch //home/$USER_NAME/$SITE_NAME/www/index.php
        echo "<?php phpinfo() ?>" >> /home/$USER_NAME/$SITE_NAME/www/index.php

        chown $USER_NAME:$USER_NAME /home/$USER_NAME/$SITE_NAME/*

        sudo a2ensite $SITE_NAME
        sudo /etc/init.d/apache2 graceful
    fi
fi;
if [ "$3" != "no" ]; then
    ./create_mysql_db.sh $USER_NAME $MYSQL_ROOT_PWD
fi
#display information
echo "-----------------------------------"
echo "User name    : $USER_NAME"
echo "User password: $USER_PASSWORD"
echo "-----------------------------------"
    echo "*****************************************"

echo -e "\nDone.\n"



exit 0