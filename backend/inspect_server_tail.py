import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inspect_server_main_tail():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Check the auth/recover endpoints definition towards the end
    cmd = "tail -n 200 /root/sovereign/backend/main.py"
    _, out, _ = ssh.exec_command(cmd)
    print(f"--- Server Main.py TAIL DNA ---\n{out.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    inspect_server_main_tail()

