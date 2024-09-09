#!/bin/bash

LOGS_FOLDER="/var/log/expense-shell"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
 mkdir -p $LOGS_FOLDER


USERID=$(id -u)

    #echo "user id is $USERID"
    R="\e[31m"
    G="\e[32m"
    N="\e[0m"
    Y="\e[33m"


    CHECK_ROOT(){

if [ $USERID -ne 0 ]
then  
    echo -e "$R proceed with  root previliges $N" &>>$LOG_FILE
    exit 1
fi 
    }
    VALIDATE(){
    if [ $1 -ne 0 ] # $1? values will come into $1
    then
        echo -e "$2 is.. $R failed $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is.. $G success $N" | tee -a $LOG_FILE


    fi
    }

    echo "script started executing..$(date)" | tee -a $LOG_FILE # tee -a shows logs in multiple places
     CHECK_ROOT

     dnf install mysql-server -y &>>$LOG_FILE
     VALIDATE $? "installing mysql" 

     systemctl enable mysqld &>>$LOG_FILE 
     VALIDATE $? "enabling mysql" 

     systemctl start mysqld  &>>$LOG_FILE
     VALIDATE $? "starting mysql"

     systemctl status mysqld &>>$LOG_FILE
     VALIDATE $? "CHECKING STATUS MYSQL"


mysql -h mysql.batch1320.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE # to connect mysql directly from inside"

 if [ $? -ne 0 ]
 then
    echo "$mysql root password is not setup.. setting up" &>>$LOG_FILE

    mysql_secure_installation --set-root-pass ExpenseApp@1 | tee -a $LOG_FILE
     VALIDATE $? "setting the root password..." 

    else
        echo -e "$mysql root password is already setup.. $R skipping $N" | tee -a $LOG_FILE

fi
     






