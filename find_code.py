import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def find_code():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Search for governor.close
    stdin, stdout, stderr = ssh.exec_command('grep -n -C 5 "governor.close" /root/sovereign/backend/main.py')
    print("--- governor.close search ---")
    print(stdout.read().decode())
    
    # 2. Search for admin_auth_init
    stdin, stdout, stderr = ssh.exec_command('grep -n -A 20 "admin_auth_init" /root/sovereign/backend/main.py')
    print("--- admin_auth_init search ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    find_code()

