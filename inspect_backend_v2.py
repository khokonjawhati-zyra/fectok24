import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_remote_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check docker inspect for the backend container
    commands = [
        'docker inspect sovereign_v15_backend | grep -i port',
        'docker ps | grep backend',
        'netstat -tulpn',
        'cat /root/sovereign/backend/main.py | grep -E "app\.post|app\.get"'
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

