import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_mesh_remap():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Mesh Re-map ---")
    
    # 1. Surgical Reconstruction of docker-compose.yml
    # Ensuring webuser_panel is on ROOT /usr/share/nginx/html
    NEW_COMPOSE = """
version: '3.8'

services:
  backend_node:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: sovereign_v15_backend
    environment:
      - SENDER_EMAIL=lailebegumyt@gmail.com
      - SENDER_PASSWORD=os.getenv("SENDER_PASSWORD")
    volumes:
      - /var/lib/sovereign/auth:/app/auth_data
      - /var/www/html/media/videos:/app/vault/data
      - ./backend/main.py:/app/main.py
      - ./backend/gmail_engine.py:/app/gmail_engine.py
    ports:
      - "5000:5000"
    restart: always

  uplink_hub:
    build:
      context: ./sovereign_media_hub/uplink
      dockerfile: Dockerfile
    container_name: sovereign_v15_uplink
    ports:
      - "8088:8080"
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
      - ./webuser_panel:/usr/share/nginx/html:ro
      - ./webadmin_panel:/usr/share/nginx/html/admin:ro
      - ./nginx.conf.gateway:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend_node
    restart: always

networks:
  default:
    name: sovereign_v15_mesh
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/docker-compose.yml', 'w') as f:
        f.write(NEW_COMPOSE)
    sftp.close()
    
    # 2. Master Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d --force-recreate')
    print("✅ DNA Pulse Synchronized: MESH RE-MAPPED TO ROOT.")
    
    ssh.close()

if __name__ == "__main__":
    definitive_mesh_remap()


