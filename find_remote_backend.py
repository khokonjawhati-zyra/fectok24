import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_backend_server():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check what's inside /app (assuming it's mapped to backend folder)
    # Actually, check where the source for the docker container is.
    # From docker-compose, it's ./backend. Let's find it on the host.
    
    commands = [
        "ls -la /root/23226/backend", # Guessing based on the structure
        "find / -name sovereign_v15_backend -type d 2>/dev/null", # Find container workdir mapping
        "docker inspect sovereign_v15_backend | grep -A 10 'Mounts'"
    ]
    
    for cmd in commands:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_backend_server()

