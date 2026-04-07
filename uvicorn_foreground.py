import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_foreground_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Try running the command inside the docker root to see what happens
    print("--- Running uvicorn manually ---")
    stdin, stdout, stderr = ssh.exec_command('cd /root/sovereign/backend && uvicorn main:app --host 0.0.0.0 --port 5000')
    
    import time
    time.sleep(5)
    print("STDOUT:", stdout.read().decode())
    print("STDERR:", stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    run_foreground_check()

