#!/bin/bash
echo "Upload logs to S3"
hostname="18.216.48.95"
from="thanesh.aws@gmail.com"
to="thanesh.aws@gmail.com"
subject=""
S3_URL="s3://logs-terrafrom-backup-files/logs/"
echo "connecting Server $hostname  "
ssh -o "StrictHostKeyChecking=no" -i adminSSH.pem ec2-user@$hostname 'ls -l';
SSH_STATUS=$?
if [ $SSH_STATUS != "0" ]
then
    echo "SSH Connectivity Error"
else
    echo "Compressing logs and web contents"
    File_name=
    ssh -o "StrictHostKeyChecking=no" -i adminSSH.pem ec2-user@$hostname 'rm -rf *.zip;sudo zip -r logs.zip /var/log/httpd /var/www/html/;ls -l *.zip'
    SSH_STATUS=$?
    if [ $SSH_STATUS != "0" ]
    then
        echo "Error in Commpressing"
        return
    else
        echo "File Tranfering"
        scp -i adminSSH.pem ec2-user@$hostname:~/*.zip .
        SSH_STATUS=$?
        if [ $SSH_STATUS != "0" ]
        then
            echo "Error in File Transfer"
        else
            echo "File Transferd"
        fi
    fi
fi
echo  "Connecting Amazon Simple Storage Service(s3)" 
mv logs.zip logs_$(date +%F-%H).zip
aws s3 cp logs_$(date +%F-%H).zip $S3_URL
S3_STATUS=$?
if [ $S3_STATUS != "0" ]
then
    subject="Error in s3 file upload"
    echo $subject
    mailx  -s "$subject" -r "$from" -c "$to"
else
    echo "File upload sucessfully"
    aws s3 ls  $S3_URL |grep logs_$(date +%F-%H).zip
    rm -f *.zip
fi