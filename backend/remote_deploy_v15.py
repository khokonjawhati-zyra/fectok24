import paramiko
import os

HOST = "167.71.193.34"
USER = "root" 
PASS = "os.getenv("SERVER_PASS")" 

def remote_deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        print(f"Connecting to {HOST} as {USER}...")
        ssh.connect(HOST, username=USER, password=PASS, timeout=15)
        print("REMOTE_AUTH_SUCCESS: Sovereign Engine Connected.")
        
        remote_base = "/root/sovereign/backend"
        print(f"Targeting Node: {remote_base}")
        
        # 1. SFTP Connection
        sftp = ssh.open_sftp()
        
        try:
            print("Injecting A_111: ai_engine.py -> Remote...")
            sftp.put("c:/Users/Admin/23226/backend/ai_engine.py", f"{remote_base}/ai_engine.py")
            
            print("Injecting A_101: main.py -> Remote...")
            sftp.put("c:/Users/Admin/23226/backend/main.py", f"{remote_base}/main.py")
            
            # Seed Brains (Critical for immediate order change)
            print("Seeding A_111: user_interest_matrix.json -> Remote...")
            sftp.put("c:/Users/Admin/23226/backend/user_interest_matrix.json", f"{remote_base}/user_interest_matrix.json")
            
            print("Seeding A_115: content_dna_ledger.json -> Remote...")
            sftp.put("c:/Users/Admin/23226/backend/content_dna_ledger.json", f"{remote_base}/content_dna_ledger.json")
        except Exception as sftp_e:
            print(f"SFTP_ERROR: {sftp_e}")
            raise sftp_e
        finally:
            sftp.close()
        
        # 2. Remote Ignition (Global Reload)
        print("IGNITING REMOTE ENGINE (Sovereign V15)...")
        # Ensure we kill uvicorn from the specific path if possible, or all of them
        # And ensure we run it from the correct folder
        ignite_command = f"cd {remote_base} && pkill -f uvicorn || true"
        ssh.exec_command(ignite_command)
        
        # Give it a second to die
        import time
        time.sleep(2)
        
        # Start new one
        start_command = f"cd {remote_base} && nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 5000 > backend.log 2>&1 &"
        ssh.exec_command(start_command)
        
        print(f"REMOTE_IGNITION_COMPLETE: V15 Logic Live at {remote_base}")
        ssh.close()
        return True
    except Exception as e:
        print(f"REMOTE_ERROR: {e}")
        return False

if __name__ == "__main__":
    remote_deploy()

