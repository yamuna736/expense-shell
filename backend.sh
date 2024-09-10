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

    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling the default node"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling te nodejs... success"

    dnf install nodejs -y&>>$LOG_FILE
    VALIDATE $? "insatlling nodejs... success"

    id expense &>>$LOG_FILE #user there are not checking with ID
    if [ $? -ne 0 ]
    then
        echo "$user is not created... creating" | tee -a $LOG_FILE
        useradd expense
        VALIDATE $? "adding the user.."
    else
        echo -e "$user is already existed..$R skippimg $N"

    fi
        mkdir -p /app
        VALIDATE $? "creating a app directory..."

        curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
        VALIDATE $? "Downloading backend Apllication"

        cd /app
        rm -rf /app/* #remove the existing code and download neww code
        unzip /tmp/backend.zip &>>$LOG_FILE
        VALIDATE $? "Extracting backend Apllication"

        npm install &>>$LOG_FILE
        cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
        # pwd user copy and copying the backend service for connecting mysql
        #check with ls -l /home/ec2-user/expense-shell/backend.service

        # load data before running the backend

        dnf install mysql -y &>>$LOG_FILE
        VALIDATE $? "installing MYSQL Client"

        mysql -h 172.31.86.244 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
        # sql schema will be in backend : cat /app/schema/backend.sql
        VALIDATE $? " shchema loading.."

        systemctl daemon-reload &>>$LOG_FILE
        VALIDATE $? "Daemon relaod"



        systemctl enable backend &>>$LOG_FILE
        VALIDATE $? "Enabling backend"

        systemctl restart backend &>>$LOG_FILE
        VALIDATE $? "restarted Backend"