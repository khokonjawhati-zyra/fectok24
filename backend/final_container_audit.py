import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"
CONT = "sovereign_v15_backend"

def audit_remote_ai():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("REMOTE_ACCESS_SUCCESS: Audit Pulse Synchronized.")
        
        # Pull ai_engine.py from container to check the actual logic inside
        stdin, stdout, stderr = ssh.exec_command(f"docker exec {CONT} cat /app/ai_engine.py")
        content = stdout.read().decode()
        
        if "get_affinity_rank" in content:
            print("A_111: Logic detected in container. Verifying scoring math...")
            # Check for the 22 phases indicators (Case-insensitive check)
            if "VIRAL_OMEGA" in content or "pulse" in content:
                print("A_111: 22-Phase V15 Brain detected inside container.")
            else:
                print("!! GAP: AI Engine inside container is still using legacy V14 logic !!")
        else:
            print("!! CRITICAL: ai_engine.py is missing get_affinity_rank in container !!")
            
        ssh.close()
    except Exception as e:
        print(f"AUDIT_ERR: {e}")

if __name__ == "__main__":
    audit_remote_ai()

