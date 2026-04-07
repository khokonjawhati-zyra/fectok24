import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def restart_backend():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Force remove and restart
    print("--- Restarting backend container ---")
    ssh.exec_command("docker restart sovereign_v15_backend")
    
    # 2. Wait a bit and check logs
    import time
    time.sleep(5)
    
    print("--- Backend Logs (fresh) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend --tail 50")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("--- Docker PS (Backend) ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps | grep backend")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    restart_backend()

