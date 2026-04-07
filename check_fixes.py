import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def find_fixes():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Search for governor.close
    stdin, stdout, stderr = ssh.exec_command('grep -n -C 2 "if governor:" /root/sovereign/backend/main.py')
    print("--- governor.close check ---")
    print(stdout.read().decode())
    
    # 2. Search for khokonjawhati
    stdin, stdout, stderr = ssh.exec_command('grep -n "khokonjawhati@gmail.com" /root/sovereign/backend/main.py')
    print("--- Admin OTP check ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    find_fixes()

