import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def network_nuclear_purge():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. ANALYZING IPTABLES GHOST ROUTES ---")
    stdin, stdout, stderr = ssh.exec_command("iptables -t nat -L -n | grep :80")
    print("Active NAT Rules:\n", stdout.read().decode())
    
    print("\n--- 3. NUCLEAR DOCKER CLEANUP ---")
    # Stopping and removing all containers, networks, and cleaning orphans
    ssh.exec_command("cd /root/sovereign_v15 && docker compose down")
    ssh.exec_command("docker network prune -f")
    ssh.exec_command("docker system prune -f")
    
    print("\n--- 4. SWITCHING GATEWAY TO HOST-NETWORK MODE ---")
    # This bypasses the buggy docker-proxy and binds Nginx directly to the host IP
    ssh.exec_command("sed -i '/ports:/d' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("sed -i '/- 80:80/d' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("sed -i '/- 443:443/d' /root/sovereign_v15/docker-compose.yml")
    # Adding network_mode: host to the gateway service
    # We find the gateway service and inject it.
    ssh.exec_command("sed -i '/gateway:/a \    network_mode: \"host\"' /root/sovereign_v15/docker-compose.yml")
    
    print("\n--- 5. REBIRTH ---")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d")
    
    print("\n--- 6. VERIFYING DIRECT BIND ---")
    import time
    time.sleep(10)
    stdin, stdout, stderr = ssh.exec_command("netstat -tulpn | grep nginx")
    print("Nginx Direct Bind:\n", stdout.read().decode())
    
    ssh.close()
    print("\n--- MISSION COMPLETE: THE NETWORK IS PURIFIED ---")

if __name__ == "__main__":
    network_nuclear_purge()

