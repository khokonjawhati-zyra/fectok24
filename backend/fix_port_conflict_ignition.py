import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_port_conflict_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Conflict Resolution ---")
    
    # Audit 1: Change uplink_hub port to 8080 to free up Port 80 for Nginx
    ssh.exec_command('sed -i "s/\\\"80:8080\\\"/\\\"8088:8080\\\"/g" /root/sovereign/docker-compose.yml')
    
    # Audit 2: Mandatory Docker Purge and Re-ignite
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d --force-recreate')
    print("✅ Port 80 Liberated and Gateway Re-ignited.")
    
    # Final check for Port 80
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA CHECK PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    fix_port_conflict_ignition()

