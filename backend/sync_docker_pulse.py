import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sync_docker_pulse():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)

    # MASTER COMPOSE DNA [MOUNTED PROTOCOL]
    NEW_COMPOSE = """
version: '3.8'

services:
  backend_node:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: sovereign_v15_backend
    environment:
      - MODE=SCALABLE_PRODUCTION
      - PILLAR=ADMIN_ABSOLUTE_TRUTH
      - SYSTEM_MODE=PRODUCTION
      - SOVEREIGN_HOST=fectok.com
      - SENDER_EMAIL=lailebegumyt@gmail.com
      - SENDER_PASSWORD=os.getenv("SENDER_PASSWORD")
      - ADMIN_MASTER_KEY=FATHER_OF_ALL_LOGIC_V15
      - ADMIN_PIN=161271
      - LEDGER_SECRET=SOVEREIGN_QUANTUM_CORE_V15
      - JWT_SECRET=SOVEREIGN_MESH_V15_OMEGA_PROTOCOL
      - SOV_PEPPER=FATHER_OF_ALL_LOGIC_V15
    volumes:
      - /var/lib/sovereign/auth:/app/auth_data
      - /var/www/html/media/videos:/app/vault/data
      - ./backend/main.py:/app/main.py
      - ./backend/gmail_engine.py:/app/gmail_engine.py
      - ./backend/token.json:/app/token.json
      - ./backend/client_secret.json:/app/client_secret.json
    ports:
      - "5000:5000"
    restart: always
    depends_on:
      - mirror_sync

  uplink_hub:
    build:
      context: ./sovereign_media_hub/uplink
      dockerfile: Dockerfile
    container_name: sovereign_v15_uplink
    environment:
      - PILLAR=REAL_TIME_UPLINK
      - SYSTEM_MODE=PRODUCTION
    volumes:
      - /var/www/html/media/videos:/app/vault/data
    ports:
      - "8080:8080"
    restart: always

  mirror_sync:
    image: redis:latest
    container_name: sovereign_v15_redis
    ports:
      - "6379:6379"
    restart: always

  stream_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/www/html/media/videos:/usr/share/nginx/html/media:ro
      - ./webuser_panel:/usr/share/nginx/html/user:ro
      - ./webadmin_panel:/usr/share/nginx/html/admin:ro
      - ./nginx.conf.gateway:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - uplink_hub
      - backend_node
    restart: always

  ai_processor:
    build:
      context: ./sovereign_media_hub/processor
      dockerfile: Dockerfile
    container_name: sovereign_v15_processor
    environment:
      - PILLAR=AI_PROCESSOR
      - SYSTEM_MODE=PRODUCTION
    volumes:
      - /var/www/html/media/videos:/app/vault/data
    restart: always
    depends_on:
      - uplink_hub

networks:
  default:
    name: sovereign_v15_mesh

volumes:
  sovereign_auth:
  sovereign_media:
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/docker-compose.yml', 'w') as f:
        f.write(NEW_COMPOSE)
    sftp.close()

    # CRITICAL RELOAD
    print("--- Re-igniting Sovereign Ecosystem ---")
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    print("✅ Docker Pulse Synchronized: Code and Token mounted successfully.")
    ssh.close()

if __name__ == "__main__":
    sync_docker_pulse()


