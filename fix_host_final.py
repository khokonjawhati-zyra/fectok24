import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_host_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Create missing host directories that are mapped as volumes
    print("--- 1. CREATING HOST DIRECTORIES ---")
    ssh.exec_command("mkdir -p /var/www/html/media/videos && mkdir -p /var/lib/sovereign/auth")
    
    # 2. Restart backend
    print("--- 2. RESTARTING BACKEND (SOVEREIGN PULSE) ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose restart backend_node"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Wait for completion & print
    stdout.channel.recv_exit_status()
    print(stdout.read().decode())
    
    # 3. Final Verification
    print("\n--- 3. LIVE STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    # Check if backend is finally up
    print("\n--- 4. BACKEND HEALTH CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/docs")
    print(f"Backend API Status: {stdout.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    final_host_fix()

