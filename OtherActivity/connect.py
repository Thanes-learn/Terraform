import paramiko
hostname="3.138.199.149"
try:
    p=paramiko.SSHClient()
    p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("connecting "+hostname +" ")
    p.connect(hostname,port=22,username="monitor",password="admin@123")
    stdin,stdout,stderr=p.exec_command("systemctl statu httpd")
    if stdout is not None:
        out=stdout.readlines()
        err.stderr.readlines()
        out=" ".join(out)
        print(out)
        stdout.close()
        stderr.close()
    else:
        Err=stderr.readlines()
        Err=" ".join(Err)
        print("Command is invalid and recheck it "+ Err)
        stdout.close()
        stderr.close()
except:
    print ("conection error")