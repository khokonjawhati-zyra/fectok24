import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def master_rebuild_and_verify():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Master Rebuild ---")
    
    # 1. Total Wipe of zombie states
    ssh.exec_command('cd /root/sovereign && docker-compose down --volumes --remove-orphans')
    ssh.exec_command('docker system prune -f')
    
    # 2. Re-establish Port 80 Bridge correctly
    # Ensuring 80:80 is set for gateway and uplink is moved
    ssh.exec_command('sed -i "s/8080:80/80:80/g" /root/sovereign/docker-compose.yml')
    ssh.exec_command('sed -i "s/80:8080/8088:8080/g" /root/sovereign/docker-compose.yml')
    
    # 3. Final Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose up -d')
    print("✅ System DNA Liberated: IGNITION SUCCESSFUL.")
    
    ssh.close()

if __name__ == "__main__":
    master_rebuild_and_verify()

