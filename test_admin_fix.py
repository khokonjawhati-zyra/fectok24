import paramiko
import json

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def test_admin_init():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    cmd = 'curl -s -X POST http://127.0.0.1:5000/admin_auth_init -H "Content-Type: application/json" -d \'{"master_key":"FATHER_OF_ALL_LOGIC_V15", "pin":"161271", "hwid":"ADMIN_NODE_ALPHA_V15"}\''
    stdin, stdout, stderr = ssh.exec_command(cmd)
    res = stdout.read().decode()
    print(f"RESPONSE: {res}")
    
    # Check logs
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend | tail -n 10')
    print("\n--- LOGS ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    test_admin_init()

