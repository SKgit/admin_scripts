#!/bin/bash
# Author: SmartKing <v.smartkin.g@gmail.com>
# URL: http://smartking.ru
# version: 0.01
# exaple command: ./create_mysql_db.sh sking_db 3dsasdf43@
# sking_db - name db
# 3dsasdf43@ - root password Mysql
MYSQL_PASS=$2

UID_ROOT=0

if [ "$UID" -ne "$UID_ROOT" ]; then
  echo "$0 - Requires root privileges"
  exit 1
fi

function generate_pass(){
    CHARS="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()-_=+\\|/"
    LENGTH="12"
    while [ "${n:=1}" -le "$LENGTH" ] ; do
 PASSWORD="$PASSWORD${CHARS:$(($RANDOM%${#CHARS})):1}"
        let n+=1
    done
    echo $PASSWORD
}

function is_running(){
    local result="$(ps -A|grep $1|wc -l)"
    if [[ $result -eq 0 ]]; then
 return 1
    else
 return 0
    fi
}

if [ $# -eq 1 ]; then
    echo -n "Check MySQL status: "
    if(is_running mysqld); then
        echo "OK [Running]";
        DB_NAME=$1
        DB_PASSWORD="$(generate_pass)"
        mysql -uroot -p${MYSQL_PASS} --execute="create database ${DB_NAME};"
        mysql -uroot -p${MYSQL_PASS} --execute="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_NAME}'@'localhost' IDENTIFIED by '${DB_PASSWORD}'  WITH GRANT OPTION;"
    else
        echo "Error: need start mysql daemon!"
        exit
    fi
fi;

#display information
echo "*****************************************"
echo "* Data base name: ${DB_NAME}"
echo "* Data base user: ${DB_NAME}"
echo "* User password: ${DB_PASSWORD}"
echo "* Profit!"
echo "*****************************************"