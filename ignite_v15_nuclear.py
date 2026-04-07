import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_nuclear_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Host Port Audit - Stopping ANY process on port 80/443
    print("--- 1. HOST PORT AUDIT (ENSURING PORT 80/443 FREEDOM) ---")
    ssh.exec_command("fuser -k 80/tcp ; fuser -k 443/tcp ; systemctl stop nginx")
    
    # 2. Hardcoding Mirrors to Internal DO Mirror (Sovereign Level Stability)
    print("--- 2. PATCHING DOCKERFILES (DIGITALOCEAN INTERNAL MIRRORS) ---")
    mirror_patch = "sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' Dockerfile"
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/uplink && {mirror_patch}")
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/processor && {mirror_patch}")
    
    # 3. Direct Build & Up with Detailed Logging
    print("--- 3. IGNITING 5-SERVICE ENGINE (NUCLEAR FORCE) ---")
    # Using 'docker-compose' (with dash) as backup if 'docker compose' fails
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
    
    ssh.close()

if __name__ == "__main__":
    final_nuclear_ignition()

