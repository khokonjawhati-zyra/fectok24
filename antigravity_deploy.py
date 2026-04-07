import os

def generate_sovereign_dna():
    print("Antigravity: Initializing Absolute Mirror Sync...")
    
    # 1. GOLDEN NGINX DNA (Cloudflare-Universal & Asset-Safe)
    # This template handles base-href /admin/ automatically.
    nginx_conf = """
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    proxy_buffering off;
    client_max_body_size 500M;

    # Shared Proxy Headers for Absolute Parity
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    # ═══════════════════════════════════════════════════════════════
    # 1. ADMIN VAULT (vazo.fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {
        listen 80;
        listen 443 ssl;
        server_name vazo.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        # Resolver for Flutter base-href /admin/
        location /admin/ {
            proxy_pass http://admin_panel:8108/;
            proxy_set_header Host $host;
        }

        location / {
            proxy_pass http://admin_panel:8108/;
            proxy_set_header Host $host;
        }
    }

    # ═══════════════════════════════════════════════════════════════
    # 2. USER FACE & API GATEWAY (fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {
        listen 80;
        listen 443 ssl;
        server_name fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        # User Application
        location / {
            proxy_pass http://user_panel:3000;
            proxy_set_header Host $host;
        }

        # Global API & WS Pulse
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://backend_node:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }

        # Media Stream Tunnel
        location ^~ /stream/ {
            proxy_pass http://uplink_hub:8080;
            proxy_set_header Host $host;
        }
    }
}
"""

    # 2. Docker-Compose (The Unified Sovereign Mesh)
    docker_compose = """
version: '3.8'

services:
  # Pillar 1: Backend Engine
  backend_node:
    build: ./backend
    container_name: sovereign_v15_backend
    env_file:
      - .env
    volumes:
      - /var/lib/sovereign/auth:/app/auth_data
      - /var/www/html/media/videos:/app/vault/data
    restart: always

  # Pillar 2: Media Uplink
  uplink_hub:
    build: ./sovereign_media_hub/uplink
    container_name: sovereign_v15_uplink
    volumes:
      - /var/www/html/media/videos:/app/vault/data
    restart: always

  # Pillar 4: Admin Panel (Ghost-Locked)
  admin_panel:
    build: ./admin_panel
    container_name: sovereign_v15_admin
    expose:
      - "8108"
    restart: always

  # Pillar 5: User Panel (Main-Face)
  user_panel:
    build: ./user_panel
    container_name: sovereign_v15_user
    expose:
      - "3000"
    restart: always

  # Pillar 6: AI Processor Engine
  ai_processor:
    build: ./sovereign_media_hub/processor
    container_name: sovereign_v15_processor
    volumes:
      - /var/www/html/media/videos:/app/vault/data
    restart: always
    depends_on:
      - uplink_hub

  # Pillar 7: Stream Gateway (Nginx)
  nginx_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/www/html/media/videos:/usr/share/nginx/html/media:ro
    depends_on:
      - backend_node
      - admin_panel
      - user_panel
      - ai_processor
    restart: always

networks:
  default:
    name: sovereign_v15_mesh
"""

    with open("nginx.conf", "w", encoding="utf-8") as f:
        f.write(nginx_conf.strip())
    
    with open("docker-compose.yml", "w", encoding="utf-8") as f:
        f.write(docker_compose.strip())

    print("Sovereign DNA Files Generated Successfully!")
    print("Zero-Manual-Change Protocol: [READY]")

if __name__ == "__main__":
    generate_sovereign_dna()
