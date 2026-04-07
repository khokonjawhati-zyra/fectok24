import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def dictator_fix_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. CORRECTING CONTAINER PERMISSIONS (NUCLEAR) ---")
    # Alpine Nginx usually uses UID 101. Making files world-readable is the safest force-fix.
    cmds = [
        "docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html",
        "docker exec sovereign_v15_gateway chown -R 101:101 /usr/share/nginx/html || true",
        "docker restart sovereign_v15_gateway"
    ]
    
    for cmd in cmds:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    ssh.close()
    print("--- MISSION COMPLETE: PERMISSIONS HARD-LOCKED ---")

if __name__ == "__main__":
    dictator_fix_v15()

