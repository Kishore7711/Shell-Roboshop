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


dnf module disable nginx -y  &>>$LOGS_FILE
dnf module enable nginx:1.24 -y  &>>$LOGS_FILE
dnf install nginx -y  &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOGS_FILE
systemctl start nginx  &>>$LOGS_FILE
VALIDATE $? "Start Nginx"


rm -rf /usr/share/nginx/html/*  &>>$LOGS_FILE
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOGS_FILE
cd /usr/share/nginx/html  &>>$LOGS_FILE
unzip /tmp/frontend.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading Frontend"

rm -rf /etc/nginx/nginx.conf  &>>$LOGS_FILE
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf  &>>$LOGS_FILE
VALIDATE $? "Copying Nginx Conf"

systemctl restart nginx  &>>$LOGS_FILE
VALIDATE $? "Restart Nginx"