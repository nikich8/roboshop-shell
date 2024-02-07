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
VALIDATE $? "Desabling current Nodejs"

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

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "downloading user application"

cd /app

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unziping user"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"


cp /home/centos/roboshop-shell.service /etc/systemd/system/user.service

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user deamon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"


mongo --host $MONGODB_HOST </app/schema/user.js
VALIDATE $? "Loading user data into mongodb"
