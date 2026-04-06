import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def read_main_py():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Reading main.py from Backend Container...")
        
        # Read the file from inside the container
        stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_backend cat /app/main.py")
        content = stdout.read().decode()
        if not content:
            print("Failed to read from container. Trying host /root/sovereign/main.py...")
            stdin, stdout, stderr = ssh.exec_command("cat /root/sovereign/main.py")
            content = stdout.read().decode()
            
        print("\n--- main.py CONTENT ---\n")
        print(content[:2000] + "\n... (truncated if too long)")
        
        ssh.close()
    except Exception as e:
        print(f"READ_ERR: {e}")

if __name__ == "__main__":
    read_main_py()

