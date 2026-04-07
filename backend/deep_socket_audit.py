import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def deep_socket_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Network Socket Pulse ---")
    
    # 1. Check what is listening on port 80 and 443
    _, out, _ = ssh.exec_command('netstat -tulpn | grep -E ":80|:443"')
    print(f"ACTIVE LISTENERS:\n{out.read().decode()}")
    
    # 2. Check if Docker Proxy is alive
    _, out2, _ = ssh.exec_command('ps aux | grep docker-proxy')
    print(f"DOCKER PROXY STATUS:\n{out2.read().decode()}")
    
    # 3. Check for UFW rules specifically
    _, out3, _ = ssh.exec_command('ufw status numbered')
    print(f"FIREWALL RULES:\n{out3.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    deep_socket_audit()

