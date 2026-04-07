import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_network_fix_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # PHASE 2: FINAL NETWORK FIX & IGNITION
    print("--- 1. BYPASSING DOCKER NETWORK BRIDGE ---")
    
    # Running build with --network=host to ensure apt-get update works
    build_cmd = f"cd {DEST_DIR} && docker compose build --network=host"
    print("--- 2. BUILDING IMAGES (NETWORK=HOST) ---")
    stdin, stdout, stderr = ssh.exec_command(build_cmd)
    
    # Streaming output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    # Once built, ignite the containers
    print("\n--- 3. IGNITING CONTAINERS ---")
    up_cmd = f"cd {DEST_DIR} && docker compose up -d"
    stdin, stdout, stderr = ssh.exec_command(up_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # FINAL VERIFICATION
    print("\n--- 4. FINAL STATUS CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_network_fix_ignition()

