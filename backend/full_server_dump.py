import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def full_dump():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Dumping Source from Container...")
        
        # Extract files from container to host tmp then sftp
        ssh.exec_command("docker cp sovereign_v15_backend:/app/main.py /tmp/remote_main.py")
        ssh.exec_command("docker cp sovereign_v15_backend:/app/ai_engine.py /tmp/remote_ai.py")
        
        sftp = ssh.open_sftp()
        sftp.get("/tmp/remote_main.py", "c:/Users/Admin/23226/backend/REMOTE_MAIN_AUDIT.py")
        sftp.get("/tmp/remote_ai.py", "c:/Users/Admin/23226/backend/REMOTE_AI_AUDIT.py")
        sftp.close()
        
        print("DUMP_SUCCESS: Files are now local for deep inspection.")
        ssh.close()
    except Exception as e:
        print(f"DUMP_ERR: {e}")

if __name__ == "__main__":
    full_dump()

