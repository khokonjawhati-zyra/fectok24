import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def migration_8080_rescue():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Migration ---")
    
    # Audit 1: Explicitly map all entrance ports to 8080 rescue tunnel
    ssh.exec_command('cd /root/sovereign && sed -i "s/80:80/8080:80/g" docker-compose.yml')
    ssh.exec_command('cd /root/sovereign && sed -i "s/443:443/8443:443/g" docker-compose.yml')
    
    # Audit 2: Mandatory High-Highway Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate')
    print("✅ System DNA Migrated to Rescue Tunnel 8080.")
    
    # Final check
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":8080 "')
    print(f"ULTRA PROOF PORT 8080:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    migration_8080_rescue()

