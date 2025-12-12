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

dnf install python3 gcc python3-devel -y &>>$log_file
validate $? "installing python"

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

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
validate $? "downloading payment application"

cd /app &>>$log_file
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/payment.zip &>>$log_file
validate $? "unzipping in /tmp directory"

pip3 install -r requirements.txt &>>$log_file
validate $? "Installing dependencies"

cp /home/ec2-user/shell-roboshop/payment.service  /etc/systemd/system/payment.service &>>$log_file
validate $? "copying payment.service"

systemctl daemon-reload &>>$log_file
validate $? "deamon reload"

systemctl enable payment  &>>$log_file
validate $? "enabling payment"

systemctl start payment  &>>$log_file
validate $? "starting payment"








