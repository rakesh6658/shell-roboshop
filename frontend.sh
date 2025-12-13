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

dnf module disable nginx -y &>>$log_file
validate $? "disable nginx"

dnf module enable nginx:1.24 -y &>>$log_file
validate $? "enable nginx"

dnf install nginx -y &>>$log_file
validate $? "installing nginx"

systemctl enable nginx  &>>$log_file
validate $? "enable nginx"

systemctl start nginx  &>>$log_file
validate $? "start nginx"

