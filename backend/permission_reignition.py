import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def permission_reignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Permission Liberation ---")
    
    # 1. Liberate all permissions for Nginx to read the volumes
    ssh.exec_command('chmod -R 755 /root/sovereign/')
    ssh.exec_command('chmod -R 755 /root/sovereign/webuser_panel/')
    ssh.exec_command('chmod -R 755 /root/sovereign/webadmin_panel/')
    
    # 2. Re-ignite the stack
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    print("✅ System DNA Liberated & Ignited.")
    
    # Prove it with netstat
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    permission_reignition()

