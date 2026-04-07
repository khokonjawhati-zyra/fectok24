import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def inspect_mounts():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Inspecting Gateway Mounts...")
        
        # Simpler inspect command
        cmd = "docker inspect sovereign_v15_gateway --format '{{json .Mounts}}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print("\n--- Gateway Mounts (JSON) ---\n")
        print(stdout.read().decode().strip())
        
        ssh.close()
    except Exception as e:
        print(f"MOUNT_ERR: {e}")

if __name__ == "__main__":
    inspect_mounts()

