import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def diag_v15_robust():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. FULL CONTAINER LIST (EXITED INCLUDED) ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps -a")
    print(stdout.read().decode())
    
    print("--- 2. DOCKER COMPOSE LOGS (ERROR SCAN) ---")
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker-compose logs --tail 50")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("--- 3. DIRECTORY INTEGRITY CHECK ---")
    # Checking for critical web folders referenced in docker-compose
    cmds = [
        f"ls -ld {DEST_DIR}/backend",
        f"ls -ld {DEST_DIR}/sovereign_media_hub",
        f"ls -ld {DEST_DIR}/webuser_panel",
        f"ls -ld {DEST_DIR}/webadmin_panel"
    ]
    for cmd in cmds:
        print(f"--- FOLDER CHECK: {cmd} ---")
        _, out, err = ssh.exec_command(cmd)
        print(out.read().decode(), err.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    diag_v15_robust()

