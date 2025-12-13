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

cp /home/ec2-user/shell-roboshop/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>>$log_file
validate $? "copying rabbitmq.repo"

dnf install rabbitmq-server -y &>>$log_file
validate $? "installing rabbitmq-server"

systemctl enable rabbitmq-server &>>$log_file
validate $? "enabling rabbitmq-server"

systemctl start rabbitmq-server &>>$log_file
validate $? "starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>>$log_file
validate $? "adding user and password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "setting permissions"
