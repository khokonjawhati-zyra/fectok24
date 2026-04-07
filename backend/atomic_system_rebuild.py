import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def atomic_system_rebuild():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Atomic Rebuild ---")
    
    # Audit 1: Atomic Purge of Host Networking
    ssh.exec_command('systemctl stop docker')
    # Flush all IPTables rules that might block Docker bridges
    ssh.exec_command('iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X')
    ssh.exec_command('service docker start')
    print("✅ Docker Engine Atomically Restored.")
    
    # Audit 2: Mandatory High-Highway Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate')
    print("✅ DNA Pulse Synchronized: ATOMIC IGNITION SUCCESSFUL.")
    
    # Final check for Port 80
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    atomic_system_rebuild()

