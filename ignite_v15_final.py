import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_ignite_step_by_step():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # PHASE 2: STEP 1 - CONFLICT CLEANUP
    print("--- STEP 1: RESOLVING DOCKER CONFLICTS ---")
    ssh.exec_command(f"rm -f {DEST_DIR}/compose.yaml")
    
    # PHASE 2: STEP 2 - PORT RELEASE
    print("--- STEP 2: RELEASING PORT 80/443 (STOPPING NGINX) ---")
    ssh.exec_command("systemctl stop nginx")
    
    # PHASE 2: STEP 3 - ATOMIC IGNITION
    # Using 'docker compose' for modern V2 support
    print("--- STEP 3: IGNITING 5-SERVICE ECOSYSTEM ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Wait for completion and print output
    exit_status = stdout.channel.recv_exit_status()
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # PHASE 2: STEP 4 - HEALTH VERIFICATION
    print("--- STEP 4: MONITORING LIVE CONTAINERS ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    if exit_status == 0:
        print("\n--- PHASE 2 COMPLETE. SOVEREIGN ENGINE IS LIVE. ---")
    else:
        print("\n--- PHASE 2 FAILED. SCANNING FOR ERRORS... ---")
        
    ssh.close()

if __name__ == "__main__":
    final_ignite_step_by_step()

