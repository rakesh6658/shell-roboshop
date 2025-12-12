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
MONGODB_HOST=mongodb.joindevops.store
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

dnf install maven -y &>>$log_file
validate $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
validate $? "Adding user roboshop"
else
echo "roboshop user already exists"
fi

mkdir -p /app &>>$log_file
validate $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$log_file
validate $? "downloading shipping application"

cd /app &>>$log_file
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/shipping.zip &>>$log_file
validate $? "unzipping in /tmp directory"

mvn clean package  &>>$log_file
validate $? "building java application"

mv target/shipping-1.0.jar shipping.jar  &>>$log_file
validate $? "renaming to shipping.jar"

cp /home/ec2-user/shell-roboshop/shipping.service  /etc/systemd/system/shipping.service &>>$log_file
validate $? "copying user.service"

systemctl daemon-reload &>>$log_file
validate $? "deamon reload"

systemctl enable shipping  &>>$log_file
validate $? "enabling shipping"

systemctl start shipping  &>>$log_file
validate $? "starting shipping"

dnf install mysql -y &>>$log_file
validate $? "installing mysql client"

mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/schema.sql &>>$log_file
validate $? "loading schema"

mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$log_file
validate $? "creating app-user"

mysql -h mysql.joindevops.store -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$log_file
validate $? "loading master data"

systemctl restart shipping &>>$log_file
validate $? "restarting shipping"








