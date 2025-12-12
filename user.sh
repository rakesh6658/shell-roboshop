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

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs"

dnf install nodejs -y &>>$log_file
validate $? "Installing nodejs"

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

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$log_file
validate $? "downloading user application"

cd /app &>>$log_file
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/user.zip &>>$log_file
validate $? "unzipping in /tmp directory"

npm install &>>$log_file
validate $? "Installing dependencies"

cp /home/ec2-user/shell-roboshop/user.service  /etc/systemd/system/user.service &>>$log_file
validate $? "copying user.service"

systemctl daemon-reload &>>$log_file
validate $? "deamon reload"

systemctl enable user  &>>$log_file
validate $? "enabling user"

systemctl start user  &>>$log_file
validate $? "starting user"








