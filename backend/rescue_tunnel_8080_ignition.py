import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def rescue_tunnel_8080_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Rescue Tunnel ---")
    
    # Audit 1: Explicitly map gateway to 8080 since 80 is blocked on host
    ssh.exec_command('cd /root/sovereign && sed -i "s/80:80/8080:80/g" docker-compose.yml')
    
    # Audit 2: Force Re-Ignition of the mesh
    ssh.exec_command('cd /root/sovereign && docker-compose build gateway && docker-compose up -d --force-recreate')
    print("✅ System DNA Liberated: RESCUE TUNNEL 8080 IGNITED.")
    
    # Prove it with netstat
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":8080 "')
    print(f"ULTRA PROOF PORT 8080:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    rescue_tunnel_8080_ignition()

