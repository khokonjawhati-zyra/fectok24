import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def deep_db_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Verifying Database Content DNA...")
        
        # Check if they have category/target_profession
        cmd = "docker exec sovereign_v15_backend python3 -c 'import sqlite3; conn = sqlite3.connect(\"/app/sovereign_v15.db\"); c = conn.cursor(); c.execute(\"SELECT category, target_profession FROM media LIMIT 5\"); print(c.fetchall()); conn.close()'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip()
        print(f"Sample Data: {results}")
        
        if "None" in results or "[]" in results:
            print("!! GAP: Videos have NO CATEGORY or DNA metadata. AI ranking will be uniform (Random) !!")
        else:
            print("A_111: Videos have DNA metadata. AI should be ranking them by interest.")
            
        ssh.close()
    except Exception as e:
        print(f"DB_AUDIT_ERR: {e}")

if __name__ == "__main__":
    deep_db_audit()

