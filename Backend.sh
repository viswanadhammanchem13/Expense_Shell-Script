#!/bin/bash
TIME=$(date)
USERID=$(id -u) #Stores User UID
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_Folder="/var/log/Roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_Folder/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_Folder

echo -e  "$R Script Executed at:$TIME $N" | tee -a $LOG_FILE # Tee command Display the content on Screen

if [ $USERID -ne 0 ] #Checks Whether UID is = 0 or not
then #!= 0 Enter into Loop
    echo -e "$R Error:Please proceed the Installation with sudo $N" | tee -a $LOG_FILE #Prints this messages on Screen
    exit 1 #!= 0 Don't Proceed with next command and Exit
else #If =0 Enter into else loop
    echo -e "$Y Please proceed the Installation $N" | tee -a $LOG_FILE #Prints this messages on Screen
fi #Condition Ends

Validate (){ #Function Definition
    if [ $1 -eq 0 ] #Checks If Exit code equls to Zero, Yes
    then #Enter into Loop
        echo -e "$G $2...... is suceefull $N"  | tee -a $LOG_FILE #Prints this messages on Screen
    else #Checks If Exit code != Zero, No
        echo -e " $R $2 ......is failed $N" | tee -a $LOG_FILE #Prints this messages on Screen
        exit 1 #Condition Exits and Entire Script Fails.
    fi #Condition Ends
}

dnf module disable nodejs -y &>>$LOG_FILE
Validate $? "Disabeling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
Validate $? "Enabling NodeJS:20"

dnf install nodejs -y &>>$LOG_FILE
Validate $? "Installling NodeJS"

id expense
if [ $? -eq 0 ]
then
    echo "Expense user is already created...Skipping"
else 
    echo "expense user is not created...Creating"
    useradd --system --home /app --shell /sbin/nologin --comment "expense user" expense
    Validate $? "Creating expense user"
fi

mkdir  -p /app
Validate $? "Creating /app Dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
Validate $? "Downloading the Code"

rm -rf /app/*
cd /app &>>$LOG_FILE
unzip /tmp/backend.zip &>>$LOG_FILE
Validate $? "Unzip the Code"

npm install &>>$LOG_FILE
Validate $? "Dependencies installions"

cp $SCRIPT_DIR/Backend.Service /etc/systemd/system/backend.service &>>$LOG_FILE
Validate $? "Coping Backend Service"

systemctl daemon-reload &>>$LOG_FILE
Validate $? "System Daemon Reload"

systemctl enable backend &>>$LOG_FILE
Validate $? "Enabling Backend Service"

systemctl start backend &>>$LOG_FILE
Validate $? "Starting Backend Service"

dnf install mysql -y
Validate $? "Installing MySQL Client"

mysql -h mysql.manchem.site -u root -p$MYSQL_ROOT_PWD -e 'use cities' &>>$LOG_FILE
if [ $? -eq 0 ]
then
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
else
    echo -e "Data is Not loaded into MySQL ... $Y Loading $N"
    mysql -h mysql.manchem.site -uroot -p$MYSQL_ROOT_PWD < /app/schema/backend.sql
fi
Validate $? "Loading data into MySQL"

systemctl restart backend &>>$LOG_FILE
Validate $? "Restarting Backend  Service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

