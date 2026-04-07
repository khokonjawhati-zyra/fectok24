import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_uvicorn_raw():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check if uvicorn is installed on host
    stdin, stdout, stderr = ssh.exec_command('uvicorn --version')
    if "not found" in stderr.read().decode():
        print("Uvicorn not found on host, installing...")
        ssh.exec_command('pip3 install uvicorn fastapi httpx pydantic python-dotenv websockets python-multipart pycryptodome')
    
    # Run uvicorn on port 8108 (to avoid conflict) in background
    print("Starting uvicorn on port 8108 raw on host...")
    cmd = 'nohup uvicorn main:app --host 0.0.0.0 --port 8108 > /root/uvicorn.log 2>&1 &'
    ssh.exec_command(f'cd /root/sovereign/backend && {cmd}')
    
    import time
    time.sleep(3)
    stdin, stdout, stderr = ssh.exec_command('cat /root/uvicorn.log')
    print("--- LOGS ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    run_uvicorn_raw()

