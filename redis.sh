#!/bin/bash

#### SCRIPT_NAME=$( echo $0| cut -d "." -f1 )

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"  #### N for Normal Color

LOGS_FOLDER="/var/log/Shell-Roboshop"
SCRIPT_NAME=$( echo "mongodb.sh"| cut -d "." -f1 )
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

    dnf module disable redis -y &>>$LOGS_FILE
    VALIDATE $? "Diable Default redis"

    dnf module enable redis:7 -y &>>$LOGS_FILE
    VALIDATE $? "Enable redis 7"

    dnf install redis -y &>>$LOGS_FILE
    VALIDATE $? "Installing redis 7"

    sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 'protected-mode/ c protected-mode no' /etc/redis/redis.conf  ### ( sed -i means pariminent)
    VALIDATE $? "Allow Remote Connections to Redis"

    systemctl enable redis &>>$LOGS_FILE
    VALIDATE $? "Enable redis"

    systemctl start redis &>>$LOGS_FILE
    VALIDATE $? "Start redis"