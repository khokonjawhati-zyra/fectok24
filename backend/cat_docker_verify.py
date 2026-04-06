import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def cat_docker_verify():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Docker Verify ---")
    
    # 1. Check all running containers
    _, out1, _ = ssh.exec_command('docker ps --format "{{.Names}} : {{.Ports}}"')
    print(f"RUNNING CONTAINERS:\n{out1.read().decode()}")
    
    # 2. Check if netstat sees anything at all
    _, out2, _ = ssh.exec_command('netstat -lntp')
    print(f"GLOBAL LISTENERS:\n{out2.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    cat_docker_verify()

