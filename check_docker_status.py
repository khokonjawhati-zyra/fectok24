import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_docker():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Docker PS ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps -a")
    print(stdout.read().decode())
    
    print("--- Backend Logs (last 50 lines) ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs --tail 50 sovereign_v15_backend")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_docker()

