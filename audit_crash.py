import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def audit_backend_crash():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- BACKEND ERROR LOGS ---")
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend")
    # Read stderr first as crash usually goes there
    print(stderr.read().decode())
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    audit_backend_crash()

