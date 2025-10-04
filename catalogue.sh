#!/bin/bash

#### SCRIPT_NAME=$( echo "catalogue.sh"| cut -d "." -f1 )

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
    echo -e "$R ERROR:: $N Please run this script with $B ROOT Prilivages $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$G SUCCESS::: $N You have $B ROOT Prilivages.. Please Proceed.... $N" | tee -a $LOGS_FILE
fi

VALIDATE(){
    if [ $1 -ne 0 ] ; then 
        echo -e "$2 ....  $R Failed $N" | tee -a $LOGS_FILE
    else
        echo -e "$2 ....  $G Successful $N" | tee -a $LOGS_FILE
    fi
         }

    
    ### NodeJS ###
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling Nodejs"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling Nodejs 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing Nodejs"

    id roboshop
    if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Adding Roboshop Application User"
    else
        echo -e "User already exists ....$Y SKIPPING $N"
    fi


    mkdir -p /app
    VALIDATE $? "Creating App Directory"

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading Catalogue App Content"

    cd /app
    VALIDATE $? "Changing to App Directory"

    rm -rf /app/*
    VALIDATE $? "Removing Old App Content"

    unzip /tmp/catalogue.zip &>>$LOGS_FILE
    VALIDATE $? "Extracting Catalogue App Content"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing Nodejs Dependencies"

    cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
    VALIDATE $? "Copying Catalogue SystemD Service File"

    systemctl daemon-reload
    VALIDATE $? "Reloading SystemD Daemon"

    systemctl enable catalogue &>>$LOGS_FILE
    VALIDATE $? "Enabling Catalogue Service"

    cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Copying Mongodb Repo File"

    dnf install mongodb-mongosh -y &>>$LOGS_FILE
    VALIDATE $? "Installing Mongodb Client"

    INDEX=$(mongosh mongodb.devopscloud.tech --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
    if [ $INDEX -le 0 ]; then
        mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
        VALIDATE $? "Loading Catalogue Schema ( Load Catalogue Products )"
    else
        echo -e "Catalogue Products Already Loaded .... $Y SKIPPED $N"
    fi

    systemctl restart catalogue
    VALIDATE $? "Starting Catalogue Service"