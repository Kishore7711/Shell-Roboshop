#!/bin/bash

#### SCRIPT_NAME=$( echo "user.sh"| cut -d "." -f1 )

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
MYSQL_HOST="mysql.devopscloud.tech"

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

   dnf install maven -y  &>>$LOGS_FILE

    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Adding Roboshop Application User"
    else
        echo -e "User already exists ....$Y SKIPPING $N"
    fi

    mkdir -p /app
    VALIDATE $? "Creating App Directory"

    cd /app
    VALIDATE $? "Changing to App Directory"

    curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading shipping App Content"

    rm -rf /app/*
    VALIDATE $? "Removing Old App Content"

    unzip /tmp/shipping.zip &>>$LOGS_FILE
    VALIDATE $? "Extracting shipping App Content"

    mvn clean package &>>$LOGS_FILE

    mv target/shipping-1.0.jar shipping.jar  &>>$LOGS_FILE

    cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service  &>>$LOGS_FILE

    systemctl daemon-reload

    systemctl enable shipping  &>>$LOGS_FILE

    dnf install mysql -y  &>>$LOGS_FILE


    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'  &>>$LOGS_FILE
    if [$? -ne 0 ] ; then
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  &>>$LOGS_FILE
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOGS_FILE
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql  &>>$LOGS_FILE
    else
        echo -e "Shipping data is already loaded... $Y SKIPPING.. $N"
    fi

  systemctl restart shipping




