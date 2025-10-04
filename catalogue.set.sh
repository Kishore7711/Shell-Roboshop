#!/bin/bash

#### SCRIPT_NAME=$( echo "catalogue.sh"| cut -d "." -f1 )

set -e pipefail

trap 'echo "There is an Error in $LINENO, Command is : $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"  #### N for Normal Color

LOGS_FOLDER="/var/log/Shell-Roboshop"
SCRIPT_NAME=$( echo $0| cut -d "." -f1 )
SCRIPT_DIR=$PWD    ### Current PATH where the script is running
MONGODB_HOST="mongodb.devopscloud.tech"
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"  ### /var/log/Shell-Roboshop/mongodb.log

mkdir -p $LOGS_FOLDER
echo "Script Exectution Started at : $(date)" | tee -a $LOGS_FILE


if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: $N Please run this script with $R ROOT Prilivages $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$G SUCCESS::: $N You have $G ROOT Prilivages.. Please Proceed.... $N" | tee -a $LOGS_FILE
fi
    
    ### NodeJS ###
    dnf module disable nodejs -y &>>$LOGS_FILE
    
    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    
    dnf install nodejs -y &>>$LOGS_FILE
    
    id roboshop
    if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    else
        echo -e "User already exists ....$Y SKIPPING $N"
    fi


    mkdir -p /app
    
    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
    
    cd /app
    
    rm -rf /app/*
    
    unzip /tmp/catalogue.zip &>>$LOGS_FILE
    
    npm install &>>$LOGS_FILE
    
    cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service

    systemctl daemon-reload
    
    systemctl enable catalogue &>>$LOGS_FILE
    
    cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
    
    dnf install mongodb-mongosh -y &>>$LOGS_FILE
    
    INDEX=$(mongosh mongodb.devopscloud.tech --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
    if [ $INDEX -le 0 ]; then
        mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
    else
        echo -e "Catalogue Products Already Loaded .... $Y SKIPPED $N"
    fi

    systemctl restart catalogue