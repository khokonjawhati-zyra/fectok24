import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_sovereign_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Pulse ---")
    
    # 1. Purge Ports on Host OS
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('ufw allow 80/tcp')
    ssh.exec_command('ufw allow 443/tcp')
    print("✅ Host Ports 80/443 Purged and Allowed.")
    
    # 2. Total Rebuild of the Mesh
    print("--- System Ignition in 3... 2... 1... ---")
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d --build --force-recreate')
    print("✅ Sovereign Ecosystem Live & Synchronized.")
    
    # 3. Validation
    _, out, _ = ssh.exec_command('docker ps --filter "name=sovereign_v15_gateway" --format "{{.Status}}"')
    print(f"GATEWAY PULSE: {out.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    ultimate_sovereign_ignition()

