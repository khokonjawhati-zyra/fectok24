import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def deep_port80_inspection():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Inspecting Port 80 and Gateway...")
        
        # 1. Check current containers
        stdin, stdout, stderr = ssh.exec_command("docker ps -a --filter 'name=gateway'")
        print("\nAll Gateway Containers:\n", stdout.read().decode())
        
        # 2. Check process on 80
        stdin, stdout, stderr = ssh.exec_command("lsof -i :80")
        print("\nLSOF Port 80:\n", stdout.read().decode())
        
        # 3. Aggressive Kill
        print("\nAggresively liberating Port 80...")
        ssh.exec_command("docker stop sovereign_v15_gateway || true")
        ssh.exec_command("docker rm sovereign_v15_gateway || true")
        ssh.exec_command("systemctl stop nginx || true")
        ssh.exec_command("fuser -k 80/tcp || true")
        
        # 4. Try starting and capture stderr
        print("\nAttempting to start Gateway on Port 80...")
        run_cmd = (
            "docker run -d --name sovereign_v15_gateway "
            "-p 80:80 "
            "-v /root/sovereign/nginx.conf.gateway:/etc/nginx/nginx.conf:ro "
            "nginx:alpine"
        )
        stdin, stdout, stderr = ssh.exec_command(run_cmd)
        err = stderr.read().decode()
        if err:
            print(f"DOCKER_ERR: {err}")
        else:
            print("DOCKER_SUCCESS: Container id: " + stdout.read().decode().strip())
            
        time.sleep(2)
        stdin, stdout, stderr = ssh.exec_command("docker ps --filter 'name=gateway'")
        print("\nRunning Gateway:\n", stdout.read().decode())
        
        ssh.close()
    except Exception as e:
        print(f"INSPECT_ERR: {e}")

if __name__ == "__main__":
    deep_port80_inspection()

