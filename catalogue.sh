#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Desabling current Nodejs" "thrid"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling  Nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already exist $Y SKINPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "downloading catalogue application"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unziping catalogue"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"
#absolute path,becoz catalogue exist there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "catalogue deamon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"


mongo --host $MONGDB_HOST </app/schema/catalogue.js
VALIDATE $? "Loading catalogue data into mongodb"



