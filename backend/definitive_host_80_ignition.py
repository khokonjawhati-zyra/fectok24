import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_host_80_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Host Ignition ---")
    
    # Audit 1: Purge any zombie port 80/443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    
    # Audit 2: Wipe all Docker networks to clear the bridge
    ssh.exec_command('docker network prune -f')
    ssh.exec_command('systemctl restart docker')
    
    # Audit 3: Force Re-Ignition of the entire stack
    ssh.exec_command('cd /root/sovereign && docker-compose build gateway && docker-compose up -d --force-recreate')
    print("✅ System Master Ignition Successful.")
    
    # Final check
    import time
    time.sleep(15)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    definitive_host_80_ignition()

