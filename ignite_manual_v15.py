import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_manual_ignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Manual Build for each service to overcome compose networking issues
    print("--- 1. BUILDING CUSTOM IMAGES ---")
    
    # Build Backend
    print("Building Backend...")
    ssh.exec_command(f"cd {DEST_DIR}/backend && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-backend_node .")
    
    # Build Uplink
    print("Building Uplink...")
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/uplink && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-uplink_hub .")
    
    # Build Processor
    print("Building Processor...")
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/processor && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-ai_processor .")
    
    # 2. Mashup and Start
    print("--- 2. STARTING ECOSYSTEM ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Live output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
        if stderr.channel.recv_stderr_ready():
            print(stderr.channel.recv_stderr(1024).decode(), end="")
            
    print("\n--- 3. FINAL STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_manual_ignite()

