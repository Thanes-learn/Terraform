import requests
import paramiko
import smtplib
import ssl
import MySQLdb
import logging
from requests.exceptions import HTTPError

def sql_update(web_status):
    
    try:
        db = MySQLdb.connect(host="mysqlinsta.c065vc4pnlfy.us-east-2.rds.amazonaws.com",
                     user="root",
                     passwd="rtsawsadmin")
        cur = db.cursor()
        sql = "insert into LOGS.WEB_LOGS(log_msg) values('"+web_status+"')"
        cur.execute(sql) 
        db.commit()
        data = cur.fetchone()
        db.close()
    except Exception as e:
        print("Database connectivity issue \n DB_ERROR"+str(e)+"\n")




def send_mail(MSG):
    # cofigue email server setting here
    SMTP_USER = "AKIAXXUAKECXLOFBYVAH"
    SMTP_PASSWORD = "BIx2ZzS+9kGvGn+LWZ5RoSqGrbW7gpPWx83tvdwJVz1h"

    # Sender and Reciver Emails
    FROM = "thanesh.aws@gmail.com"
    SYSTM_TEAM = ['thanesh.aws@gmail.com', 'thanesh.aws@gmail.com']
    BODY = "Web Server is not functioning and take nessary steps now"

    # Configuring email text
    email_text = """\
    From: %s
    To: %s
    Subject: %s

    %s
    """ % (FROM, ", ".join(SYSTM_TEAM), MSG, BODY)
    print("Intitilizing mail process")
    # We are using Try block to find error in this prcocess
    # It will help us to find the other issues occure here
    try:
        print("Connecting SMTP Server")
        server = smtplib.SMTP_SSL('email-smtp.us-east-2.amazonaws.com', 465)
        server.ehlo()
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.sendmail(FROM, SYSTM_TEAM, email_text)
        server.close()
        print(MSG)
    except Exception as e:
        # Display error if system unable to mail
        print("Failed to connect SMTP Server ...\nError --:"+str(e)+"\n")


def command(hostname, user, passwd,url):
    # We are using paramiko libery to make ssh conec to web server
    # If there is problem try block will show issue with connectivity
    try:
        p = paramiko.SSHClient()
        p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print("Trying"+" "+hostname + " ")
        p.connect(hostname, port=22, username=user, password=passwd)
        print(" User : "+user+" ")
        transport = p.get_transport()
        session = transport.open_session()
        session.set_combine_stderr(True)
        session.get_pty()
        session.exec_command("sudo systemctl restart httpd")
        stdin = session.makefile('wb', -1)
        stdout = session.makefile('rb', -1)
        stdin.write("admin@123"+'\n')
        stdin.flush()
        sql_update("Service has been restarted")
        print("Service has been restarted")
        response =requests.get(url)
        if response.status_code != 200:
            print("Communicate System Team")
            sql_update("Communicate System Team")
            send_mail("Communicate System Team")
        else:
            sql_update("Service is available")
            print("Service is available")

    except Exception as e:
        print("conection error\nERROR---:"+str(e)+"\n")
        raise


hostname = "18.219.236.228"
URL = "http://"+hostname

try:
    response = requests.get(URL,verify=False)
    if response.status_code != 200:
        print(response.status_code)
        try:
            print("Connecting "+hostname)
            command(hostname, "monitor", "admin@123",URL)
        except:
            print("problem status coded  \nResponse :"+response + "\n")
            send_mail("connection Error--inform Team")
    else:
        print("server up and running")
        sql_update("server up and running")
except Exception as err:
    sql_update("Unidentified Error and informing Team further investigation")
    print("Unidentified Error and informing Team further investigation  \nERROR--:"+str(err)+" \n")
    command(hostname, "monitor", "admin@123",URL)

