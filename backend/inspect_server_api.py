import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inspect_server_endpoint():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Search for endpoint in main.py
    cmd = "grep -n -C 5 '/recover_pulse' /root/sovereign/backend/main.py"
    _, out, _ = ssh.exec_command(cmd)
    print(f"--- Server Main.py Endpoint Check ---\n{out.read().decode()}")
    
    # 2. Check for GmailEngine init
    cmd2 = "grep 'GmailEngine' /root/sovereign/backend/main.py | head -n 5"
    _, out2, _ = ssh.exec_command(cmd2)
    print(f"--- GmailEngine Injection Check ---\n{out2.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    inspect_server_endpoint()

