#!/bin/bash

LOGS_FOLDER="/var/logs/expense"
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
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.. $R failed $N" &>>$LOG_FILE
        exit 1
    else 
        echo -e "$2 is.. $G success $N" &>>$LOG_FILE


    fi
    }

    echo "script started executing..$(date)" | tee -a $LOG_FILE # tee -a shows logs in multiple places
     CHECK_ROOT

     dnf install mysql-server -y
     validate $? "installing mysql.." | tee -a $LOG_FILE

     systemctl enable mysqld
     validate $? "enabling mysql.." | tee -a $LOG_FILE

     systemctl start mysqld
     validate $? "starting mysql..."

     mysql_secure_installation --set-root-pass ExpenseApp@1
     validate $? "setting the root password..." | tee -a $LOG_FILE






#     dnf list installed mysql

# if [ $? -ne 0 ]
# then 
#     echo "mysql is not install.. try to install.."
#     dnf install mysql -y
#     if [ $? -ne 0 ]
#     then
#         echo " mysql installation is not success.. check it"
#         exit 1
#     else
#         echo "mysql already installed.."
#     fi    
# else
#     echo "mysql is already install.. nothig to do"
# fi