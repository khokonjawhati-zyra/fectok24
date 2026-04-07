import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_nginx_config():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Try finding common nginx config paths
    commands = [
        'cat /etc/nginx/nginx.conf',
        'cat /etc/nginx/conf.d/default.conf',
        'ls -R /etc/nginx/sites-enabled/',
        'cat /etc/nginx/sites-enabled/default',
        'docker exec sovereign_v15_nginx cat /etc/nginx/nginx.conf'
    ]
    
    for cmd in commands:
        print(f"--- Running: {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        out = stdout.read().decode()
        err = stderr.read().decode()
        if out: print(out)
        if err: print(f"Error: {err}")
        print("\n")
        
    ssh.close()

if __name__ == "__main__":
    read_nginx_config()

