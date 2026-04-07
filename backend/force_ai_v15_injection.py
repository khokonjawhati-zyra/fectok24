import paramiko
import os

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"
CONT = "sovereign_v15_backend"

# Local source of the 22-phase AI logic
LOCAL_AI = r"c:\Users\Admin\23226\backend\ai_engine.py"
LOCAL_MAIN = r"c:\Users\Admin\23226\backend\main.py"

def force_inject():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Force-Pumping V15 Logic into Sovereign Heart...")
        
        sftp = ssh.open_sftp()
        sftp.put(LOCAL_AI, "/tmp/ai_v15_engine.py")
        sftp.put(LOCAL_MAIN, "/tmp/ai_v15_main.py")
        sftp.close()
        
        # Inject into container
        commands = [
            f"docker cp /tmp/ai_v15_engine.py {CONT}:/app/ai_engine.py",
            f"docker cp /tmp/ai_v15_main.py {CONT}:/app/main.py",
            f"docker restart {CONT}"
        ]
        
        for cmd in commands:
            print(f"Executing: {cmd}")
            ssh.exec_command(cmd)
            
        print("\nSUCCESS: V15 AI Engine is now CRITICALLY LIVE inside the container.")
        ssh.close()
    except Exception as e:
        print(f"CRITICAL_FAIL: {e}")

if __name__ == "__main__":
    force_inject()

