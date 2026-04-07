import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def deploy_main_final():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("Uploading main_final.py to remote...")
    sftp = ssh.open_sftp()
    # Destination must be /root/sovereign/backend/main.py
    sftp.put('main_final.py', '/root/sovereign/backend/main.py')
    sftp.close()
    
    print("Rebuilding and restarting backend (FINAL BUILD)...")
    restart_cmd = """
    docker stop sovereign_v15_backend || true
    docker rm sovereign_v15_backend || true
    cd /root/sovereign/backend
    docker build -t sovereign-backend_node:latest .
    docker run -d --name sovereign_v15_backend --network host sovereign-backend_node:latest uvicorn main:app --host 0.0.0.0 --port 5000 --workers 1
    """
    stdin, stdout, stderr = ssh.exec_command(restart_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    deploy_main_final()

