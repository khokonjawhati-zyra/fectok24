import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_config():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read nginx.conf
    stdin, stdout, stderr = ssh.exec_command('cat /etc/nginx/nginx.conf')
    config = stdout.read().decode()
    
    # Check docker status
    stdin, stdout, stderr = ssh.exec_command('docker ps')
    docker_ps = stdout.read().decode()
    
    ssh.close()
    return config, docker_ps

if __name__ == "__main__":
    config, docker_ps = read_config()
    print("--- NGX ---")
    print(config)
    print("--- DOCKER ---")
    print(docker_ps)

