import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_correct_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Purge
    print("--- 1. PURGING SYSTEM ---")
    ssh.exec_command(f"cd {DEST_DIR} && docker compose down --remove-orphans")
    
    # 2. Sequential Build without --dns (using host network)
    services = [
        ("backend", f"{DEST_DIR}/backend", "sovereign_v15-backend_node"),
        ("uplink", f"{DEST_DIR}/sovereign_media_hub/uplink", "sovereign_v15-uplink_hub"),
        ("processor", f"{DEST_DIR}/sovereign_media_hub/processor", "sovereign_v15-ai_processor")
    ]
    
    print("--- 2. BUILDING CUSTOM ENGINES ---")
    for name, path, tag in services:
        print(f"Building {name}...")
        # Patching mirrors and building with --network=host (dns inherited from host)
        cmd = f"cd {path} && " \
              f"sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' Dockerfile && " \
              f"sed -i 's/cdn-fastly.deb.debian.org/mirrors.digitalocean.com/g' Dockerfile && " \
              f"docker build --network=host -t {tag} ."
        stdin, stdout, stderr = ssh.exec_command(cmd)
        
        # Blocking wait
        exit_status = stdout.channel.recv_exit_status()
        if exit_status != 0:
            print(f"ERROR: {name} build failed with status {exit_status}")
            print(stderr.read().decode())
        else:
            print(f"{name} build successful.")

    # 3. Ignition
    print("--- 3. IGNITING MESH ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    stdout.channel.recv_exit_status()
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 4. Verification
    print("\n--- 4. FINAL STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_correct_ignition()

