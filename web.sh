#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.nikikdrama.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started exicuting at $TIMESTAMP" &>> $LOGFILE


VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILED $N"
        exit 1
        
    else
        echo -e "$2...$G SUCCESS $N"
    fi      
}

if [ $ID -ne 0 ]
then
    echo  -e "$R ERROR: plese run script with root user $N"
    exit 1
else
    echo "you are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Desabling current Nodejs" "thrid"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling  Nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already exist $Y SKINPING $N"
fi

dnf install nginx -y &>> $LOGFILE
VALIDATED $? "Insatlling nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATED $? "enable nginx"

systemctl start nginx &>> $LOGFILE
VALIDATED $? "starting nginx"


rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATED $? "remove default web site"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATED $? "downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATED $? "moving nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATED $? "unziping web"

vim /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATED $? "copied roboshop reverse proxy config"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATED $? "copied roboshop reserve proxy config"

systemctl restart nginx &>> $LOGFILE
VALIDATED $? "restarted nginx"