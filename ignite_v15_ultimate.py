import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_ultimate_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Fixing Docker DNS & Internal Mirrors
    print("--- 1. PATCHING DOCKERFILES WITH RELIABLE MIRRORS ---")
    # Using 'cdn-fastly.deb.debian.org' which is much more stable on DO nodes
    patch_cmd = f"sed -i 's/deb.debian.org/cdn-fastly.deb.debian.org/g' {DEST_DIR}/sovereign_media_hub/uplink/Dockerfile && " \
                f"sed -i 's/deb.debian.org/cdn-fastly.deb.debian.org/g' {DEST_DIR}/sovereign_media_hub/processor/Dockerfile"
    ssh.exec_command(f"cd {DEST_DIR} && {patch_cmd}")
    
    # 2. Sequential Build with Explicit DNS and Network
    print("--- 2. BUILDING SEQUENTIALLY WITH DNS BYPASS ---")
    
    # Build Backend
    print("Building Backend Node...")
    ssh.exec_command(f"cd {DEST_DIR}/backend && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-backend_node .")
    
    # Build Uplink
    print("Building Uplink Hub...")
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/uplink && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-uplink_hub .")
    
    # Build Processor
    print("Building AI Processor Engine...")
    ssh.exec_command(f"cd {DEST_DIR}/sovereign_media_hub/processor && docker build --network=host --dns 8.8.8.8 -t sovereign_v15-ai_processor .")
    
    # 3. Final Mesh Ignition
    print("--- 3. IGNITING 5-SERVICE MESH ---")
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker compose up -d")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("\n--- DEPLOYMENT SUCCESSFUL. SOVEREIGN ENGINE ACTIVE. ---")
    ssh.close()

if __name__ == "__main__":
    final_ultimate_ignition()

