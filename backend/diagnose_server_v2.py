import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def diagnose_v2():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected to Sovereign Core...")
        
        # 1. Check Video Count via Python
        cmd1 = "docker exec sovereign_v15_backend python3 -c 'import sqlite3; conn = sqlite3.connect(\"/app/sovereign_v15.db\"); c = conn.cursor(); c.execute(\"SELECT COUNT(*) FROM media\"); print(c.fetchone()[0]); conn.close()'"
        stdin, stdout, stderr = ssh.exec_command(cmd1)
        count = stdout.read().decode().strip()
        print(f"Video Count in DB: {count}")
        
        # 2. Check Sample Categories via Python
        cmd2 = "docker exec sovereign_v15_backend python3 -c 'import sqlite3; conn = sqlite3.connect(\"/app/sovereign_v15.db\"); c = conn.cursor(); c.execute(\"SELECT category FROM media WHERE category IS NOT NULL LIMIT 5\"); print(c.fetchall()); conn.close()'"
        stdin, stdout, stderr = ssh.exec_command(cmd2)
        cats = stdout.read().decode().strip()
        print(f"Sample Categories: {cats}")
        
        ssh.close()
    except Exception as e:
        print(f"DIAGNOSE_ERR: {e}")

if __name__ == '__main__':
    diagnose_v2()

