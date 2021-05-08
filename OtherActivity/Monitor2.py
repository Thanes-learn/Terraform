import os
import smtplib
import requests
import logging
import bs4

EMAIL_USER=''
EMAIL_PASSWORD=''
TO_EMAIL='thaneshsliit@gmail.com'
SUUBJECT='Idenfied Server is not respoding'
URL='http://127.0.0.1'
try:
response=requests.get(URL,timeout=3)
logging.info('Checking URL '+URL+' ')
if response.status_code !=200:
    logging.warn('Web URL is down')
    Restart()
    send_email()
    else:
         logging.error('Web URL is UP')
except:
logging.critical('Automaton script function and please look')


def reboot_server(ip,user,passwd):
    os.execv()


