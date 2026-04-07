import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def absolute_force_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Force IPv4 and Reliable Mirrors in Dockerfiles
    print("--- 1. PATCHING DOCKERFILES (IPV4 FORCE + FASTLY) ---")
    patch_cmd = "sed -i 's/apt-get update/apt-get -o Acquire::ForceIPv4=true update/g' Dockerfile"
    
    # Patching Uplink
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/uplink && sed -i 's/deb.debian.org/cdn-fastly.deb.debian.org/g' Dockerfile && {patch_cmd}")
    # Patching Processor
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/processor && sed -i 's/deb.debian.org/cdn-fastly.deb.debian.org/g' Dockerfile && {patch_cmd}")
    
    # 2. Re-Ignite with Maximum Bypass
    print("--- 2. IGNITING 5-SERVICE MESH (FORCED BYPASS) ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose build --network=host --pull && docker compose up -d"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Wait for completion & print
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    # FINAL STATUS CHECK
    print("\n--- 3. FINAL STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    absolute_force_ignition()

