import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
LOCAL_CONF = r'c:\Users\Admin\23226\sovereign_v15_master_optimized.conf'
REMOTE_TEMP_CONF = '/tmp/nginx_v15_optimized.conf'
REMOTE_FINAL_CONF = '/etc/nginx/nginx.conf'

def deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    sftp = ssh.open_sftp()
    print(f"Uploading {LOCAL_CONF} to {REMOTE_TEMP_CONF}...")
    sftp.put(LOCAL_CONF, REMOTE_TEMP_CONF)
    sftp.close()
    
    print("Testing Nginx configuration...")
    # We test it by temporarily swapping just for the test or by using -c
    # But since it's a full nginx.conf, we can use nginx -t -c
    stdin, stdout, stderr = ssh.exec_command(f"nginx -t -c {REMOTE_TEMP_CONF}")
    test_out = stdout.read().decode()
    test_err = stderr.read().decode()
    
    print(test_out)
    print(test_err)
    
    if "syntax is ok" in test_err and "test is successful" in test_err:
        print("Test successful! Applying configuration...")
        # Backup old config
        ssh.exec_command(f"cp {REMOTE_FINAL_CONF} {REMOTE_FINAL_CONF}.bak")
        # Replace
        ssh.exec_command(f"cp {REMOTE_TEMP_CONF} {REMOTE_FINAL_CONF}")
        # Reload
        stdin, stdout, stderr = ssh.exec_command("systemctl reload nginx")
        print("Nginx reloaded.")
        print(stdout.read().decode())
        print(stderr.read().decode())
    else:
        print("ERROR: Nginx configuration test failed. Deployment aborted.")
        
    ssh.close()

if __name__ == "__main__":
    deploy()

