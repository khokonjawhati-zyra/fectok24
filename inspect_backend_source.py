import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inspect_backend():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    commands = [
        "docker inspect sovereign_v15_backend | grep -i 'WorkingDir'",
        "ls -la /opt/sovereign/core/backend"
    ]
    
    for cmd in commands:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    inspect_backend()

