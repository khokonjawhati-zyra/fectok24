import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def cat_a_auth():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Lines 5175 to 5195 with cat -A to see everything
    stdin, stdout, stderr = ssh.exec_command('sed -n "5175,5195p" /root/sovereign/backend/main.py | cat -e')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    cat_a_auth()

