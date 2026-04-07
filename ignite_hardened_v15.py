import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_hardened_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. PULL LATEST HARDENED CONFIGS
    print("--- 1. SYNCING HARDENED CONFIGS FROM GITHUB ---")
    sync_cmd = f"cd {DEST_DIR} && git reset --hard && git pull origin main"
    stdin, stdout, stderr = ssh.exec_command(sync_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 2. FORCE RE-IGNITION
    print("--- 2. FORCING REBUILD & IGNITION (3-SERVICE MESH) ---")
    # Using 'docker compose' as we confirmed it's the right command
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Streaming build output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    print("\n--- 3. IGNITION COMPLETE. FINAL STATUS CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_hardened_ignition()

