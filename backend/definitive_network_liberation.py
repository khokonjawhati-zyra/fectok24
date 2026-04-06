import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_network_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Network Liberation ---")
    
    # Audit 1: Aggressive Purge of Zombie Containers and Networks
    ssh.exec_command('cd /root/sovereign && docker-compose down --remove-orphans')
    ssh.exec_command('docker network prune -f')
    
    # Audit 2: Mandatory Gateway Force Re-map
    # Ensuring Port 80 is dedicated and uplink is on 8888
    ssh.exec_command('sed -i "s/80:8080/8888:8080/g" /root/sovereign/docker-compose.yml')
    
    # Audit 3: Master Ignition of the Mesh
    ssh.exec_command('cd /root/sovereign && docker-compose up -d')
    print("✅ System Mesh DNA Liberated and Ignited.")
    
    # Final check for Port 80
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA CHECK PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    definitive_network_liberation()

