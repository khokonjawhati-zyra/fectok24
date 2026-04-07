import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_backend():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Check if backend is listening on 5000
    print("--- Checking port 5000 on localhost ---")
    stdin, stdout, stderr = ssh.exec_command("curl -v http://localhost:5000/api/v15/ping")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 2. Check logs for any startup errors
    print("--- Backend Logs (Last 100) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend --tail 100")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 3. Check connectivity from server to external
    print("--- Pinging external for DNS check ---")
    stdin, stdout, stderr = ssh.exec_command("ping -c 3 8.8.8.8")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_backend()

