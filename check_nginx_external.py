import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_nginx_external():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Test POST /verify_token via localhost:443 (Nginx)
    print("--- POST /verify_token (via Nginx) ---")
    # We use -H "Host: fectok.com" to trigger the right server block
    stdin, stdout, stderr = ssh.exec_command('curl -s -k -X POST -H "Host: fectok.com" -H "Content-Type: application/json" -d "{}" https://127.0.0.1/verify_token')
    print(stdout.read().decode())
    
    # 2. Test POST /admin_auth_init via localhost:443 (Nginx)
    print("--- POST /admin_auth_init (via Nginx) ---")
    stdin, stdout, stderr = ssh.exec_command('curl -s -k -X POST -H "Host: vazo.fectok.com" -H "Content-Type: application/json" -d "{}" https://127.0.0.1/admin_auth_init')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_nginx_external()

