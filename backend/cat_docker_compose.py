import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def cat_docker_compose():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Compose DNA ---")
    _, out1, _ = ssh.exec_command('cat /root/sovereign/docker-compose.yml')
    print(out1.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    cat_docker_compose()

