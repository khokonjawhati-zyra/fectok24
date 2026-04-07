import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def direct_main_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Patching main.py on the server directly to handle missing directory
    print("--- 1. PATCHING main.py DIRECTLY ON SERVER ---")
    
    # We use sed to inject the fix before the StaticFiles mount
    # Starlette StaticFiles check is at line 242 (approx)
    
    inject_cmd = "sed -i 's/app.mount(\"\/media\", StaticFiles(directory=SOV_DNA.storage), name=\"media\")/import os\\nos.makedirs(SOV_DNA.storage, exist_ok=True)\\napp.mount(\"\/media\", StaticFiles(directory=SOV_DNA.storage), name=\"media\")/g' " + f"{DEST_DIR}/backend/main.py"
    
    ssh.exec_command(inject_cmd)
    
    # 2. Restarting Backend
    print("--- 2. RESTARTING BACKEND ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose restart backend_node"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Final verification
    print("\n--- 3. STATUS PULSE ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    direct_main_fix()

