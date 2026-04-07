import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_nginx_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Nginx Error Logs ---")
    stdin, stdout, stderr = ssh.exec_command("tail -n 20 /var/log/nginx/error.log")
    print(stdout.read().decode())
    
    print("--- Nginx Access Logs ---")
    stdin, stdout, stderr = ssh.exec_command("tail -n 20 /var/log/nginx/access.log")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_nginx_logs()

