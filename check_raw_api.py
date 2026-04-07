import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_raw_api():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Test POST /verify_token
    print("--- POST /verify_token (RAW) ---")
    stdin, stdout, stderr = ssh.exec_command('curl -s -X POST -H "Content-Type: application/json" -d "{}" http://127.0.0.1:5000/verify_token')
    print(stdout.read().decode())
    
    # 2. Test POST /admin_auth_init
    print("--- POST /admin_auth_init (RAW) ---")
    stdin, stdout, stderr = ssh.exec_command('curl -s -X POST -H "Content-Type: application/json" -d "{}" http://127.0.0.1:5000/admin_auth_init')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_raw_api()

