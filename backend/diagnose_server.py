import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def diagnose():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected to Sovereign Core...")
        
        # 1. Check Video Count
        cmd1 = "docker exec sovereign_v15_backend sqlite3 /app/sovereign_v15.db \"SELECT COUNT(*) FROM media;\""
        stdin, stdout, stderr = ssh.exec_command(cmd1)
        count = stdout.read().decode().strip()
        print(f"Video Count in DB: {count}")
        
        # 2. Check Sample Categories
        cmd2 = "docker exec sovereign_v15_backend sqlite3 /app/sovereign_v15.db \"SELECT category FROM media WHERE category IS NOT NULL LIMIT 5;\""
        stdin, stdout, stderr = ssh.exec_command(cmd2)
        cats = stdout.read().decode().strip()
        print(f"Sample Categories: {cats}")
        
        # 3. Check Latest Logs for AI Brain calls
        cmd3 = "docker logs sovereign_v15_backend --tail 20"
        stdin, stdout, stderr = ssh.exec_command(cmd3)
        logs = stdout.read().decode().strip()
        print("\n--- Latest Backend Logs ---")
        print(logs)
        
        ssh.close()
    except Exception as e:
        print(f"DIAGNOSE_ERR: {e}")

if __name__ == '__main__':
    diagnose()

