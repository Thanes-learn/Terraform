import paramiko
import requests
hostname = "3.138.199.149"
code = 0
try:
    res = requests.get("http://"+hostname)
    code = res.status_code
    print("Server up  and runningcls")
except:
    #print (code)

    if code != 200:
        try:
            p = paramiko.SSHClient()
            p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            print("connecting "+hostname + " ")
            p.connect(hostname, port=22, username="monitor",
                      password="admin@123")
            stdin, stdout, stderr = p.exec_command("./test.sh")
            if stdout.channel.recv_exit_status() == 0:
               # print(f'STDOUT: {stdout.read().decode("utf8")}')
                print("Server has been restarted")
            else:
               # print(f'STDERR: {stderr.read().decode("utf8")}')
                print("Sending email to System Teams")
            stdin.close()
            stdout.close()
            stderr.close()
            p.close()
        except:
            print("conection error")
            print("Sending email to System Teams")
    else:
        print("Server is up and running ")
