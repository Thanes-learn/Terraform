import requests
import paramiko
from requests.exceptions import HTTPError


def command(Level,command,hostname,user,passwd):
    try:
        p = paramiko.SSHClient()
        p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print("Connecting "+hostname + "  "+Level)
        p.connect(hostname, port=22, username="monitor",
                  password="admin@123")
        stdin, stdout, stderr = p.exec_command("./test.sh")
        if stdout.channel.recv_exit_status() == 0:

            # print(f'STDOUT: {stdout.read().decode("utf8")}')
            send_mail("Server has been restarted")
        else:
            # print(f'STDERR: {stderr.read().decode("utf8")}')
            send_mail("Command not executing "+ command+" --informing Team "+ level)
        stdin.close()
        stdout.close()
        stderr.close()
        p.close()
    except Exception as err:
        send_mail("SSH service is not available "+ hostname + " --informing Team "+ Level +str(err))


def send_mail(msg):
    print(msg)
    return


hostname = "3.138.199.149"
URL = "http://"+hostname
try:
    response = requests.get(URL)
    if response.status_code != 200:

        try:
            command("Trying","./test.sh",hostname,"monitor","admin@123")
        except:
            send_mail("connection Error--inform Team")
    else:
        print("server up and runnign")
except Exception as err:
    print("Unidentified Error   and informing Team further investigation  "+str(err))
    command("Retring","./test.sh",hostname,"monitor","admin@123")
