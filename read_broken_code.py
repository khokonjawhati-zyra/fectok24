import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_broken_code():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    stdin, stdout, stderr = ssh.exec_command('sed -n "5170,5200p" /root/sovereign/backend/main.py')
    print(stdout.read().decode())
    ssh.close()

if __name__ == "__main__":
    read_broken_code()

