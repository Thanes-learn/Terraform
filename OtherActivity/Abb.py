import paramiko
hostname="3.138.199.149"
try:
    p=paramiko.SSHClient()
    p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("connecting "+hostname +" ")
    p.connect(hostname,port=22,username="monitor",password="admin@123")

    transport=p.get_transport()
    session=transport.open_session()
    session.set_combine_stderr(True)
    session.get_pty()
    session.exec_command("sudo -k  systemctl start httpd")
    stdin=session.makefile('wb',-1)
    stderr=session.makefile('rb',-1)
    stdin.write("admin@123"+'\n')
    stdin.flush()
    for line in stderr.read().splitlines():
        print(line)

    
except:
    print ("conection error")
    raise