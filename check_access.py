import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_nginx_access():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Search for last 20 access log entries with 405
    print("--- Access Log (405 entries) ---")
    stdin, stdout, stderr = ssh.exec_command('grep " 405 " /var/log/nginx/access.log | tail -n 20')
    print(stdout.read().decode())
    
    # 2. Check if uvicorn logs show anything for those requests
    print("--- Docker Logs (Backend) ---")
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend --tail 50')
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_nginx_access()

