import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def audit_host_mirrors():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. HOST SOURCES.LIST ---")
    stdin, stdout, stderr = ssh.exec_command("cat /etc/apt/sources.list")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    audit_host_mirrors()

