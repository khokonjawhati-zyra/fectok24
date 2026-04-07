import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def patch_backend():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Patch DummyFinance.close to be async
    print("Patching main.py to fix TypeError in shutdown...")
    # Replace 'def close(self): pass' with 'async def close(self): pass'
    patch_cmd = "sed -i 's/def close(self): pass/async def close(self): pass/g' /opt/sovereign/core/backend/main.py"
    ssh.exec_command(patch_cmd)
    
    # 2. Also ensure governor.close() is handled safely if governor is None (though it shouldn't be)
    # The existing code is:
    # if governor:
    #     await governor.close()
    
    # 3. Restart the backend container
    print("Restarting backend container...")
    ssh.exec_command('docker restart sovereign_v15_backend')
    
    ssh.close()
    print("Patch applied and container restarted.")

if __name__ == "__main__":
    patch_backend()

