import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def global_port_80_reignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign 80 Re-Ignition ---")
    
    # Audit 1: Aggressive Purge of Host Port 80
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('iptables -I INPUT -p tcp --dport 80 -j ACCEPT')
    ssh.exec_command('service docker restart')
    
    # Audit 2: Final Mapping Sync
    ssh.exec_command('cd /root/sovereign && sed -i "s/8080:80/80:80/g" docker-compose.yml')
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate gateway')
    print("✅ Port 80 Bridge Forcefully Re-IGNITED.")
    
    # Final check for Port 80
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    global_port_80_reignition()

