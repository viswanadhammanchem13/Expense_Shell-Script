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

dnf module list nginx &>>$LOG_FILE
Validate $? "Listing Nginx Packages"

dnf module disable nginx -y &>>$LOG_FILE
Validate $? "Disabling Nginx Packages"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
Validate $? "Enabling Nginx Packages"

dnf install nginx -y &>>$LOG_FILE
Validate $? "Installing Nginx Packages"

systemctl enable nginx &>>$LOG_FILE
Validate $? "Enable Nginx Packages"

systemctl start nginx &>>$LOG_FILE
Validate $? "Starting Nginx Packages"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
Validate $? "Removing Default Content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
Validate $? "Download the frontend content"

cd /usr/share/nginx/html &>>$LOG_FILE
Validate $? "Change to Default DIR"

unzip /tmp/frontend.zip &>>$LOG_FILE
Validate $? "Extract the frontend content."

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
Validate $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
Validate $? "Coping Catalogue Service"

systemctl restart nginx &>>$LOG_FILE
Validate $? "Restarting Nginx Service" 