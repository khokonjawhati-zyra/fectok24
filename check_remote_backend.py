import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_remote_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    commands = [
        'docker ps -a',
        'netstat -tulpn | grep 8108',
        'netstat -tulpn | grep 5000',
        'head -n 20 /root/sovereign/backend/main.py',
        'cat /root/sovereign/backend/.env'
    ]
    
    for cmd in commands:
        print(f"--- Running: {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
        print("\n")
        
    ssh.close()

if __name__ == "__main__":
    run_remote_check()

