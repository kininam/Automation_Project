#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
myname=namritha
s3_bucket=upgrad-$myname
#1. Updating system
echo "======================= Updating System ====================="
sudo apt update -y
echo "=============================== Update competed ==========================="
#2. Installing Apache2
echo "================================== Chekcing if apache is installed ========================"
if dpkg --get-selections | grep apache > 0
then
        echo "======================= Apache is already installed ==========================="
else
        apt install apache2 -y
        echo "============================== Apache installation completed successfully ====================="
fi
#3. Starting the service
echo "==============================checking is service is running============================================="
if systemctl list-units --type=service --state=active  | grep apache2 > 0
then
        echo "============================ Service is running ========================="
else
        echo "=============================== Service is not running ================================"
        systemctl start apache2
        echo "================================== Service started successfully =============================="
fi
#4. Check if service is enabled
echo " ======================= Checking if service is enabled ====================================="
if systemctl list-unit-files --state=enabled | grep apache2 > 0
then
        echo "=============================== Service is enabled =============================="
else
        echo "========================= Service is in disabled state =========================="
        systemctl enable apache2
        echo "=========================== Service is enabled now ============================"
fi
#5. Creating a tar file
echo "=========================== Creating a tar file =================================="
tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar /var/log/apache2/access*.log

#6. Uploading file to S3
#settingup AWSCLI
if  dpkg --get-selections | grep awscli > 0
then
        echo "====================== AWSCLI already installed ======================"
else
        apt install awscli -y
        aws configure set aws_access_key_id #update your access key ID
        aws configure set aws_secret_access_key #update your secret access key
        aws configure set default.region us-east-1
        echo " =========== Installed and configured awscli============="
fi
echo "================== Uploading tar file to s3 bucket====================="
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
echo " ====================== End of task 2 ================"
