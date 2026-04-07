import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_port_remap():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Port Re-map ---")
    
    # Audit 1: Force Re-map Port in docker-compose.yml
    # This was likely mapping 8080:80 instead of 80:80
    ssh.exec_command('sed -i "s/8080:80/80:80/g" /root/sovereign/docker-compose.yml')
    ssh.exec_command('sed -i "s/8443:443/443:443/g" /root/sovereign/docker-compose.yml')
    
    # Audit 2: Re-ignite Gateway Stack
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate gateway')
    print("✅ Port 80 Bridge Re-ignited.")
    
    # Final check
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80"')
    print(f"ULTRA CHECK PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    definitive_port_remap()

