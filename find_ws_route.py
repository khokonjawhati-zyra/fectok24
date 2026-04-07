import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def find_ws_route():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read the whole main.py to be sure
    print("Reading main.py...")
    stdin, stdout, stderr = ssh.exec_command('cat /opt/sovereign/core/backend/main.py')
    content = stdout.read().decode()
    
    import re
    ws_matches = re.findall(r'@app\.websocket\(".*"\)', content)
    print("WebSocket matches found:", ws_matches)
    
    # Also find where client_type is used
    client_type_usage = re.findall(r'def .*\(.*client_type.*\)', content)
    print("client_type usage:", client_type_usage)

    ssh.close()

if __name__ == "__main__":
    find_ws_route()

