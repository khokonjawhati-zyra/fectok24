import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def verify_v15_deployment():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. SOVEREIGN V15 CONTAINER AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    print("--- 2. BACKEND API PULSE (PORT 5000) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend --tail 50")
    print(stdout.read().decode())
    
    print("--- 3. NETWORK PORT MAP ---")
    stdin, stdout, stderr = ssh.exec_command("netstat -tulpn | grep LISTEN")
    print(stdout.read().decode())
    
    print("--- 4. NGINX CONFIG TEST ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -t")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    verify_v15_deployment()

