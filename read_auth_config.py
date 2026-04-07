import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_auth_config():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    stdin, stdout, stderr = ssh.exec_command('cat /root/sovereign/backend/user_auth.py')
    print(stdout.read().decode())
    ssh.close()

if __name__ == "__main__":
    read_auth_config()

