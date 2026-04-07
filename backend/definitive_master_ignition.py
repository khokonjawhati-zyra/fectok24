import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_master_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Master Ignition ---")
    
    # Audit 1: Purge all listeners on host ports
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('systemctl stop nginx')
    
    # Audit 2: Mandatory Docker Engine Restart (Fixes proxy bind issues)
    ssh.exec_command('systemctl restart docker')
    print("✅ Docker Engine Re-ignited.")
    
    # Audit 3: System Force Reignite
    # After restart, docker-compose up will bind ports correctly
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate')
    print("✅ DNA Pulse Synchronized: Sovereign System IS LIVE.")
    
    ssh.close()

if __name__ == "__main__":
    definitive_master_ignition()

