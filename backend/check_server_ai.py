import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def check_server_ai():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print(f"Connected to {HOST}...")
        
        # Find where main.py is and peek inside the GET_LATEST_MEDIA action
        stdin, stdout, stderr = ssh.exec_command("find / -name main.py 2>/dev/null | grep -v 'bk' | head -n 1")
        main_path = stdout.read().decode().strip()
        print(f"Main.py Path: {main_path}")
        
        if main_path:
            cmd = f"grep -A 40 'GET_LATEST_MEDIA' {main_path}"
            stdin, stdout, stderr = ssh.exec_command(cmd)
            print("--- GET_LATEST_MEDIA Implementation ---")
            print(stdout.read().decode())
        
        ssh.close()
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    check_server_ai()

