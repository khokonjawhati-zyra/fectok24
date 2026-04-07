import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def debug_startup():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Run it manually on host to see what's wrong
    cmd = 'cd /root/sovereign/backend && export $(cat .env | xargs) && python3 main.py'
    print(f"--- Running: {cmd} ---")
    stdin, stdout, stderr = ssh.exec_command(cmd)
    
    # Read output with a timeout
    import time
    time.sleep(5)
    out = stdout.read().decode()
    err = stderr.read().decode()
    print("STDOUT:", out)
    print("STDERR:", err)
    
    ssh.close()

if __name__ == "__main__":
    debug_startup()

