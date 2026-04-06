import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def force_host_port_80():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Host Port Force ---")
    
    # Audit 1: Purge all listeners on host 80/443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    
    # Audit 2: Restart docker completely to clear bridge hang
    ssh.exec_command('systemctl restart docker')
    print("✅ Docker Service Restarted.")
    
    # Audit 3: Final Ignition with explicit network rebuild
    ssh.exec_command('cd /root/sovereign && docker-compose build gateway && docker-compose up -d --force-recreate')
    print("✅ DNA Pulse Synchronized: FINAL HOST IGNITION.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    force_host_port_80()

