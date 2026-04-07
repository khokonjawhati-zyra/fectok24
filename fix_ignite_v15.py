import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def fix_and_ignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. PHASE 1: CONFLICT RESOLUTION
    print("--- 1. PURGING CONFLICTING COMPOSE FILES ---")
    ssh.exec_command(f"rm -f {DEST_DIR}/compose.yaml")
    
    # 2. PHASE 2: FORCED ARCHITECTURE IGNITION
    print("--- 2. RELEASING HOST PORTS (STOPPING NGINX) ---")
    ssh.exec_command("systemctl stop nginx")
    
    print("--- 3. IGNITING 5-SERVICE ECOSYSTEM (FORCE REBUILD) ---")
    ignite_cmd = f"cd {DEST_DIR} && docker-compose -f docker-compose.yml up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Streaming output to visualize the build
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    print("\n--- 4. IGNITION COMPLETE. RUNNING STATUS CHECK... ---")
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker-compose ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    fix_and_ignite()

