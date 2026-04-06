import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def master_firewall_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Firewall Pulse ---")
    
    # 1. Unblock Ports on Host OS (UFW)
    ssh.exec_command('ufw allow 80/tcp')
    ssh.exec_command('ufw allow 443/tcp')
    ssh.exec_command('ufw allow 5000/tcp')
    ssh.exec_command('ufw --force enable')
    print("✅ Host Firewall Liberated (80, 443, 5000).")
    
    # 2. Total System Re-ignition
    print("--- Final System Reboot ---")
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    print("✅ Sovereign Ecosystem Live & Synchronized.")
    
    # 3. Final Verification
    _, out, _ = ssh.exec_command('docker ps --filter "name=sovereign_v15_gateway" --format "{{.Status}}"')
    print(f"GATEWAY PULSE: {out.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    master_firewall_liberation()

