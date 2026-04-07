import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_ignite_nuclear():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Kill Port 80/443 Conflicts
    print("--- 1. LIBERATING PORTS 80/443 ---")
    ssh.exec_command("fuser -k 80/tcp ; fuser -k 443/tcp ; systemctl stop nginx")
    
    # 2. Overwrite Dockerfiles with internal mirrors
    print("--- 2. INJECTING INTERNAL MIRRORS ---")
    
    uplink_docker = """FROM python:3.11-slim-bookworm
WORKDIR /app
# Internal DO Mirror + IPv4 Force
RUN sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' /etc/apt/sources.list.d/debian.sources || sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' /etc/apt/sources.list
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir flask flask-cors requests python-dotenv
COPY . .
CMD ["python", "uplink_server.py"]
"""
    
    processor_docker = """FROM python:3.12-slim-bookworm
# Internal DO Mirror + IPv4 Force
RUN sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' /etc/apt/sources.list.d/debian.sources || sed -i 's/deb.debian.org/mirrors.digitalocean.com/g' /etc/apt/sources.list
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get upgrade -y && apt-get install -y ffmpeg libsm6 libxext6 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install python-dotenv
COPY . .
ENV IS_DOCKER=True
ENV PYTHONUNBUFFERED=1
CMD ["python", "-u", "processor_engine.py"]
"""
    
    ssh.exec_command(f"echo '{uplink_docker}' > {DEST_DIR}/sovereign_media_hub/uplink/Dockerfile")
    ssh.exec_command(f"echo '{processor_docker}' > {DEST_DIR}/sovereign_media_hub/processor/Dockerfile")
    
    # 3. Ignite
    print("--- 3. NUCLEAR IGNITION (5 SERVICES) ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Live output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
        if stderr.channel.recv_stderr_ready():
            print(stderr.channel.recv_stderr(1024).decode(), end="")
            
    print("\n--- 4. FINAL STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_ignite_nuclear()

