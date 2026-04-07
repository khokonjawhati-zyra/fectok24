import paramiko
import os

HOST = "167.71.193.34"
USER = "root" 
PASS = "os.getenv("SERVER_PASS")" 

CONT_NAME = "sovereign_v15_backend"

def docker_deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=15)
        print(f"Connected to {HOST}. Starting Target Container Injection: {CONT_NAME}")
        
        sftp = ssh.open_sftp()
        # Uploading to host's /tmp first
        files = [
            ("c:/Users/Admin/23226/backend/ai_engine.py", "/tmp/ai_engine.py"),
            ("c:/Users/Admin/23226/backend/main.py", "/tmp/main.py"),
            ("c:/Users/Admin/23226/backend/user_interest_matrix.json", "/tmp/user_interest_matrix.json"),
            ("c:/Users/Admin/23226/backend/content_dna_ledger.json", "/tmp/content_dna_ledger.json")
        ]
        
        for local, remote in files:
            print(f"Uploading {os.path.basename(local)} -> Host /tmp")
            sftp.put(local, remote)
        
        sftp.close()
        
        # Injecting from Host /tmp to Container /app
        print(f"Surgically Injecting into {CONT_NAME}...")
        commands = [
            f"docker cp /tmp/ai_engine.py {CONT_NAME}:/app/ai_engine.py",
            f"docker cp /tmp/main.py {CONT_NAME}:/app/main.py",
            f"docker cp /tmp/user_interest_matrix.json {CONT_NAME}:/app/user_interest_matrix.json",
            f"docker cp /tmp/content_dna_ledger.json {CONT_NAME}:/app/content_dna_ledger.json",
            f"docker restart {CONT_NAME}"
        ]
        
        for cmd in commands:
            stdin, stdout, stderr = ssh.exec_command(cmd)
            print(f"EXEC: {cmd}")
            err = stderr.read().decode()
            if err: print(f"ERROR_LOG: {err}")
            
        print(f"IGNITION_SUCCESS: {CONT_NAME} is now running the 22-Phase AI Logic.")
        ssh.close()
    except Exception as e:
        print(f"DEPLOY_ERR: {e}")

if __name__ == "__main__":
    docker_deploy()

