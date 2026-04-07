import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def verify_final():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- SOVEREIGN V15: LIVE CONTAINER FLEET ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
    print(stdout.read().decode())
    
    print("\n--- INFRASTRUCTURE HEALTH PULSE ---")
    # Check if backend is responding
    stdin, stdout, stderr = ssh.exec_command("curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/docs")
    status = stdout.read().decode()
    if status == '200':
        print("Backend API: [ONLINE] (200 OK)")
    else:
        print(f"Backend API: [ERROR] Status: {status}")
        
    ssh.close()

if __name__ == "__main__":
    verify_final()

