#!/bin/bash
Code=$(curl -LI http://18.223.44.113 -o /dev/null -w '%{http_code}\n' -s ) 
echo "HTTP_STATUS :$Code"
from="thanesh.aws@gmail.com"
to="thanesh.aws@gmail.com"
subject=""
if [ "$Code" = "200" ]
then
    echo "Server up and running" #&> logs.log
else
    echo "Web is not accesable -- restarting Apache web service" #&> logs.log
    SSH_STATUS=$(ssh -o "StrictHostKeyChecking=no" -i adminSSH.pem ec2-user@18.223.44.113 sudo systemctl restart httpd 2>>err.log)
    SSH_STATUS=$?
    if [ "$SSH_STATUS" == "255" ]
    then
        echo "SSH Coontivity is not available"
        echo "Sending mail to System Team"
    else
        Command_STATUS=$(ssh -o "StrictHostKeyChecking=no" -i adminSSH.pem ec2-user@18.223.44.113 sudo systemctl restart httpd 2>>err.log) 
        Command_STATUS=$?
        if ["$Command_STATUS" -ne "0"]
        then
            subject="Problem in restart Script"
            echo $subject 
            mailx  -s "$subject" -r "$from" -c "$to"
        fi    
        $(ssh -o "StrictHostKeyChecking=no" -i adminSSH.pem ec2-user@18.223.44.113 sleep 10) 
        STATUS=$(curl -LI http://18.223.44.113 -o /dev/null -w '%{http_code}\n' -s )
        if [ "$STATUS" != "200" ]
        then
            subject="Server restart process is not fixing"
            echo $subject 
            mailx  -s "$subject" -r "$from" -c "$to" 
        else
            subject= "Web is Available --Service has been restarted"
            echo $subject 
            #mailx  -s "$subject" -r "$from" -c "$to"    
            
        fi
    fi
fi
