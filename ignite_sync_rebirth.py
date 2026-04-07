import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def execute_blocking(ssh, cmd):
    print(f"Executing: {cmd}")
    stdin, stdout, stderr = ssh.exec_command(cmd)
    # Stream output and wait
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
        if stderr.channel.recv_stderr_ready():
            print(stderr.channel.recv_stderr(1024).decode(), end="")
    return stdout.channel.recv_exit_status()

def final_sync_rebirth():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Force Stop and Purge
    print("--- 1. SYNCHRONOUS PURGE ---")
    execute_blocking(ssh, f"cd {DEST_DIR} && docker compose down --rmi all --remove-orphans")
    
    # 2. Host Directory Assurance
    print("--- 2. HOST DIRECTORY ASSURANCE ---")
    execute_blocking(ssh, "mkdir -p /var/www/html/media/videos && mkdir -p /var/lib/sovereign/auth")
    
    # 3. Synchronous Forced Build & Up
    print("--- 3. SYNCHRONOUS FORCE IGNITION ---")
    execute_blocking(ssh, f"cd {DEST_DIR} && docker compose up -d --build")
    
    # 4. Final Pulse
    print("\n--- 4. FINAL STATUS HEARTBEAT ---")
    execute_blocking(ssh, "docker ps")
    
    print("\n--- 5. BACKEND HEALTH CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/docs")
    print(f"Backend API Status: {stdout.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    final_sync_rebirth()

