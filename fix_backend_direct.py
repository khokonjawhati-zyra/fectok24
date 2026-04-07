import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def direct_backend_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Overwriting the backend Dockerfile directly on the server
    print("--- 1. OVERWRITING BACKEND DOCKERFILE ON SERVER ---")
    
    dockerfile_content = """FROM python:3.12-slim-bookworm
WORKDIR /app

# Sovereign V15: Security Hardening Pulse
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \\
    gcc \\
    python3-dev \\
    libssl-dev \\
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \\
    fastapi \\
    uvicorn[standard] \\
    httpx \\
    pydantic \\
    python-dotenv \\
    websockets \\
    requests \\
    google-api-python-client \\
    google-auth-httplib2 \\
    google-auth-oauthlib \\
    PyJWT \\
    passlib \\
    pycryptodome \\
    stripe \\
    python-multipart

RUN mkdir -p /app/vault/data

# Copy local code
COPY . .

# Sovereign V15: Expose Backend Pulse
EXPOSE 5000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
"""
    # Escaping backslashes for bash
    bash_content = dockerfile_content.replace("\\", "\\\\").replace("'", "'\\''")
    ssh.exec_command(f"echo '{bash_content}' > {DEST_DIR}/backend/Dockerfile")
    
    # 2. Final Ignition of the backend
    print("--- 2. REBUILDING & RESTARTING BACKEND ---")
    ignite_cmd = f"cd {DEST_DIR} && docker compose up -d --build backend_node"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Stream output
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    # Final verification
    print("\n--- 3. STATUS PULSE ---")
    stdin, stdout, stderr = ssh.exec_command("docker ps")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    direct_backend_fix()

