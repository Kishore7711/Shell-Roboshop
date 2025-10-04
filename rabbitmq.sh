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
START_TIME=$(date +%s)
SCRIPT_DIR=$($PWD)

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

  cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
  VALIDATE $? "Adding RabbitMQ Repo"

  dnf install rabbitmq-server -y
  VALIDATE $? "Installing RebbitMQ"

  systemctl enable rabbitmq-server
  VALIDATE $? "Enableing Rabitmq"

  systemctl start rabbitmq-server
  VALIDATE $? "Starting RabitMQ"

  rabbitmqctl add_user roboshop roboshop123
  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
  VALIDATE $? "Setting up Permissions"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo  -e "Script Executed in $Y $TOTAL_TIME seconds $N"