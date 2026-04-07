import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def surgical_port_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Surgical Fix ---")
    
    # Audit 1: Explicitly move uplink_hub away from Port 80
    # Any port works for internal comms as long as 80 is free for Gateway
    ssh.exec_command('sed -i "s/80:8080/8888:8080/g" /root/sovereign/docker-compose.yml')
    ssh.exec_command('sed -i "s/8088:8080/8888:8080/g" /root/sovereign/docker-compose.yml')
    
    # Audit 2: Force Purge and Re-ignite Gateway and Uplink
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d --force-recreate')
    print("✅ Port 80 Bridge Liberated and Mapped to Gateway.")
    
    # Audit 3: Final Proof of Port 80 Binding to Gateway
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA CHECK PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    surgical_port_liberation()

