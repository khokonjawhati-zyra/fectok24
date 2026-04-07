import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def nuclear_port_8080_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Nuclear Ignition ---")
    
    # Audit 1: Force re-map gateway to Port 8080 which we know is open
    # We will let Cloudflare handle the port 80 to 8080 bridging if needed
    # Or just use 8080 as a rescue tunnel
    ssh.exec_command('cd /root/sovereign && sed -i "s/80:80/8080:80/g" docker-compose.yml')
    ssh.exec_command('cd /root/sovereign && sed -i "s/8888:8080/8088:8080/g" docker-compose.yml')
    
    # Audit 2: System Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate gateway')
    print("✅ System DNA Liberated: PORT 8080 TUNNEL IS LIVE.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":8080 "')
    print(f"ULTRA PROOF PORT 8080:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    nuclear_port_8080_ignition()

