import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_targeted_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Run targeted checks to confirm backend port and status
    commands = [
        'docker ps --filter "name=sovereign_v15_backend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"',
        'netstat -tulpn | grep -E "5000|8108"',
        'docker logs sovereign_v15_backend --tail 50'
    ]
    
    for cmd in commands:
        print(f"--- Running: {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
        print("\n")
        
    ssh.close()

if __name__ == "__main__":
    run_targeted_check()

