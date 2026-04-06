import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def find_server_logic():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Searching Server endpoints ---")
    # Using simple list of commands to avoid quote issues
    cmds = [
        "grep -n 'recover_pulse' /root/sovereign/backend/main.py",
        "grep -n 'admin_auth_init' /root/sovereign/backend/main.py",
        "grep -n 'gmail_engine.send_email' /root/sovereign/backend/main.py"
    ]
    
    for cmd in cmds:
        _, out, _ = ssh.exec_command(cmd)
        print(f"CMD RESULT [{cmd}]:\n{out.read().decode()}")
        
    ssh.close()

if __name__ == "__main__":
    find_server_logic()

