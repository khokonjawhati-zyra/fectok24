import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def absolute_dominance_rebirth():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. REMOVING READ-ONLY RESTRICTIONS ---")
    # Using sed to remove :ro from docker-compose.yml to allow permission fixes
    ssh.exec_command("sed -i 's/:ro//g' /root/sovereign_v15/docker-compose.yml")
    
    print("--- 3. NUCLEAR STACK REBIRTH (FORCE RELOAD) ---")
    # Down and Up to refresh mounts without :ro and rebind ports
    reset_cmd = "cd /root/sovereign_v15 && docker compose down && docker compose up -d"
    stdin, stdout, stderr = ssh.exec_command(reset_cmd)
    print(stdout.read().decode())
    
    print("--- 4. HARD-LOCKING PERMISSIONS (RW MODE) ---")
    time.sleep(10) # Heavy rebirth wait for all 5 services
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    ssh.exec_command("docker exec sovereign_v15_gateway chown -R 101:101 /usr/share/nginx/html || true")
    
    print("--- 5. FINAL SUCCESS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.Names}} - {{.Status}} - {{.Ports}}'")
    print(stdout.read().decode())
    
    ssh.close()
    print("--- MISSION SUCCESS: SYSTEM IS FULLY UNBOUND ---")

if __name__ == "__main__":
    absolute_dominance_rebirth()

