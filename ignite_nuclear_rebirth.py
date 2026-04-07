import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_nuclear_rebirth():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Total System Purge to clear any cached errors
    print("--- 1. SYSTEM NUCLEAR PURGE ---")
    ssh.exec_command(f"cd {DEST_DIR} && docker compose down --rmi all --remove-orphans")
    
    # 2. Host Directory Assurance
    print("--- 2. HOST DIRECTORY ASSURANCE ---")
    ssh.exec_command("mkdir -p /var/www/html/media/videos && mkdir -p /var/lib/sovereign/auth")
    
    # 3. Forced Rebuild and Ignition
    print("--- 3. NUCLEAR FORCE IGNITION (5 SERVICES) ---")
    # Using 'docker compose build' first to catch any errors
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Wait for execution and stream output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
        if stderr.channel.recv_stderr_ready():
            print(stderr.channel.recv_stderr(1024).decode(), end="")
            
    # FINAL VERIFICATION
    print("\n--- 4. FINAL STATUS HEARTBEAT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    # Check if backend is finally up
    print("\n--- 5. BACKEND HEALTH CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/docs")
    print(f"Backend API Status: {stdout.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    final_nuclear_rebirth()

