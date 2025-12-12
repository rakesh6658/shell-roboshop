#!/bin/bash

user_id=$(id -u)

if [ $user_id -ne 0 ]
then
echo "Do not have root access"
exit 1
fi
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
validate(){
if [ $1 -ne 0 ]
then
echo -e "$2 ... $RED failure $NC"
else
echo -e "$2 ...  $GREEN success $NC"
fi

}
LOG_DIR="/var/log/shell-roboshop"
script_name=$(echo "$0" | cut -d "." -f1)
log_file="$LOG_DIR/$script_name.log"
mkdir -p /var/log/shell-roboshop



dnf install mysql-server -y &>>$log_file
validate $? "installing mysql"

systemctl enable mysqld &>>$log_file
validate $? "enabling mysqld"

systemctl start mysqld &>>$log_file
validate $? "starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$log_file
validate $? "mysql secure installation setting password"