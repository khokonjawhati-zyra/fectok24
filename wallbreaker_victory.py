import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def wallbreaker_victory():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. BREAKING FIREWALL BARRIERS (UFW/IPTABLES) ---")
    # Opening all necessary ports for global access
    cmds = [
        "ufw allow 80/tcp",
        "ufw allow 81/tcp",
        "ufw allow 443/tcp",
        "ufw allow 5000/tcp",
        "ufw --force enable"
    ]
    for cmd in cmds:
        ssh.exec_command(cmd)
    
    print("\n--- 3. KILLING HOST-SIDE PHANTOM PROCESSES (Ghost Nginx) ---")
    # Ensuring no native Nginx is fighting with Docker for Port 80
    ssh.exec_command("systemctl stop nginx || true")
    ssh.exec_command("systemctl disable nginx || true")
    
    print("\n--- 4. RETURNING TO PORT 80 (The Universal Standard) ---")
    ssh.exec_command("sed -i 's/81:80/80:80/g' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d gateway")
    
    print("\n--- 5. FINAL MESH PERMISSION SYNC ---")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- MISSION ACCOMPLISHED: THE DOORS ARE OPEN ---")

if __name__ == "__main__":
    wallbreaker_victory()

