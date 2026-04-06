import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_server_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Origin Audit ---")
    
    # 1. Check if server itself can see Nginx on localhost
    _, out1, _ = ssh.exec_command('curl -I http://localhost:80')
    print(f"LOCALHOST PORT 80 CURL:\n{out1.read().decode()}")
    
    # 2. Check Nginx Logs from Container
    _, out2, _ = ssh.exec_command('docker logs sovereign_v15_gateway --tail 50')
    print(f"GATEWAY LOGS:\n{out2.read().decode()}")
    
    # 3. Check if Port 80 is occupied by something invisible
    _, out3, _ = ssh.exec_command('ss -tulpn | grep :80')
    print(f"SOCKET STATUS:\n{out3.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    ultimate_server_audit()

