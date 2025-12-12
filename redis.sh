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

dnf module disable redis -y &>>$log_file
validate $? "disabling redis"

dnf module enable redis:7 -y &>>$log_file
validate $? "enabling redis"

dnf install redis -y  &>>$log_file
validate $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode  no/g' /etc/redis/redis.conf &>>$log_file
validate $? "updating locations"

systemctl enable redis  &>>$log_file
validate $? "enabling redis"

systemctl start redis  &>>$log_file
validate $? "starting redis"
