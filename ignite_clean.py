import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ignite_clean_reset():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # Upload fixed nginx.conf first
    print("--- 2. UPLOADING STRUCTURAL NGINX FIX ---")
    sftp = ssh.open_sftp()
    sftp.put(r'c:\Users\Admin\23226\nginx.conf', '/root/sovereign_v15/nginx.conf')
    sftp.close()
    
    print("--- 3. NUCLEAR STACK RESET (Down -v && Up -d) ---")
    # This cleans volumes to ensure no old configs are cached and rebuilds networking
    reset_cmd = 'cd /root/sovereign_v15 && docker compose down -v && docker compose up -d'
    stdin, stdout, stderr = ssh.exec_command(reset_cmd)
    
    print("STDOUT:", stdout.read().decode())
    print("STDERR:", stderr.read().decode())
    
    print("--- 4. FINAL MESH VERIFICATION ---")
    time.sleep(10) # Heavy rebirth wait
    stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.Names}} - {{.Status}} - {{.Ports}}'")
    print(stdout.read().decode())
    
    ssh.close()
    print("--- MISSION COMPLETE: SYSTEM IS REBORN ---")

if __name__ == "__main__":
    ignite_clean_reset()

