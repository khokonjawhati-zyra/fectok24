import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def audit_full_build():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- STARTING FULL BUILD AUDIT ---")
    # Using 'docker compose build' to see the exact layer failure
    stdin, stdout, stderr = ssh.exec_command("cd /root/sovereign_v15 && docker compose build --no-cache")
    
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
        if stderr.channel.recv_stderr_ready():
            print(stderr.channel.recv_stderr(1024).decode(), end="")
            
    ssh.close()

if __name__ == "__main__":
    audit_full_build()

