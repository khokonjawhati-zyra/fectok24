import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def cat_docker_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Crash Audit ---")
    
    # Audit 1: Find why containers are crashing
    # We will try to start them and immediately grab logs
    ssh.exec_command('cd /root/sovereign && docker-compose up -d')
    import time
    time.sleep(10) # Wait for crash
    
    _, out1, _ = ssh.exec_command('docker-compose logs --tail 100')
    print(f"CRASH LOGS:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    cat_docker_logs()

