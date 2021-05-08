#!/bin/bash
STATUS=$(ssh -i adminSSH.pem ec2-user@3.138.199.149 systemctl status httpd | grep "Active" | awk '{ print substr($3,2,length($3)-2)}')
echo $STATUS

if [ $STATUS != 'running' ]
then
$(ssh -i adminSSH.pem ec2-user@3.138.199.149 sudo systemctl start httpd)>> logs.txt
$(ssh -i adminSSH.pem ec2-user@3.138.199.149 sleep 5)
STATUS=$(ssh -i adminSSH.pem ec2-user@3.138.199.149 systemctl status httpd | grep "Active" | awk '{ print substr($3,2,length($3)-2)}')
echo $STATUS + "restarted"
else
echo "Server Up and Runniing"
fi
#ssh -o "StrictHostKeyChecking=no" -i /some/location/private_key fkafka@prague.corp.myco.com "ls /tmp"

