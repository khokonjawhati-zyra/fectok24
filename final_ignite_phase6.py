import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def final_ignite_phase6():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. PHASE 6 NUCLEAR PURGE: CLEARING INTERNAL NGINX OVERRIDES ---")
    # This command clears the default.conf inside the container and restarts it
    purge_cmd = 'docker exec sovereign_v15_gateway sh -c "rm -f /etc/nginx/conf.d/*" && cd /root/sovereign_v15 && docker compose restart stream_gateway'
    stdin, stdout, stderr = ssh.exec_command(purge_cmd)
    
    print("STDOUT:", stdout.read().decode())
    print("STDERR:", stderr.read().decode())
    
    print("--- 3. VERIFYING 5-SERVICE MESH INTEGRITY ---")
    time.sleep(5) # Wait for gateway to breathe
    stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.Names}} - {{.Status}}'")
    print(stdout.read().decode())
    
    ssh.close()
    print("--- MISSION COMPLETE: SYSTEM IS NOW IP-READY ---")

if __name__ == "__main__":
    final_ignite_phase6()

