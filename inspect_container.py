import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inspect_failed_container():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Check if the container is running
    print("--- Docker PS ---")
    stdin, stdout, stderr = ssh.exec_command('docker ps -a --filter name=sovereign_v15_backend')
    print(stdout.read().decode())
    
    # 2. Check logs with --tail
    print("--- Last 50 lines of logs ---")
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend --tail 50')
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 3. Check what's inside the container filesystem
    print("--- main.py check inside container ---")
    stdin, stdout, stderr = ssh.exec_command('docker run --rm sovereign-backend_node:latest ls -l /app/main.py')
    print(stdout.read().decode())
    
    # 4. Try running uvicorn manually inside a temp container
    print("--- Manual run test ---")
    stdin, stdout, stderr = ssh.exec_command('docker run --rm sovereign-backend_node:latest uvicorn main:app --host 0.0.0.0 --port 5000')
    time.sleep(5)
    print("STDOUT:", stdout.read().decode())
    print("STDERR:", stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    inspect_failed_container()

