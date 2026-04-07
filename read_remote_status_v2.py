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
    
    # Read nginx sites-enabled
    stdin, stdout, stderr = ssh.exec_command('ls /etc/nginx/sites-enabled/')
    sites = stdout.read().decode()
    
    # Check docker status
    stdin, stdout, stderr = ssh.exec_command('docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"')
    docker_ps = stdout.read().decode()
    
    ssh.close()
    return config, sites, docker_ps

if __name__ == "__main__":
    config, sites, docker_ps = read_config()
    with open('remote_status_full.txt', 'w', encoding='utf-8') as f:
        f.write("--- NGX CONFIG ---\n")
        f.write(config)
        f.write("\n--- SITES ENABLED ---\n")
        f.write(sites)
        f.write("\n--- DOCKER PS ---\n")
        f.write(docker_ps)
    print("Remote status written to remote_status_full.txt")

