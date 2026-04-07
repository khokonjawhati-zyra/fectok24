import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_sovereign_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Pulse ---")
    
    # 1. Force Kill everything on 80/443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('systemctl stop nginx')
    
    # 2. Re-create the Mesh (Clean up first)
    print("--- Re-igniting the Stack ---")
    ssh.exec_command('cd /root/sovereign && docker-compose down')
    ssh.exec_command('cd /root/sovereign && docker-compose up -d')
    
    # 3. Final Verification of Socket Port 80
    import time
    time.sleep(10)
    _, out, _ = ssh.exec_command('netstat -lntp | grep ":80"')
    print(f"PORT 80 LIVE PULSE:\n{out.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    definitive_sovereign_ignition()

