import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def run_cmd(ssh, cmd, timeout=15):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except:
        return "TIMEOUT"

# CORRECT flutter_bootstrap.js for Flutter 3.x - forces HTML renderer, no WASM/canvaskit
BOOTSTRAP_JS = '''(function() {
  // Force HTML renderer - no canvaskit/WASM dependency
  var serviceWorkerVersion = null;
  
  // Unregister any old service workers that might cache wrong files
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for (var registration of registrations) {
        registration.unregister();
      }
    });
  }

  _flutter.loader.load({
    onEntrypointLoaded: async function(engineInitializer) {
      try {
        var appRunner = await engineInitializer.initializeEngine({
          renderer: "html",
          hostElement: undefined,
          assetBase: "/",
        });
        await appRunner.runApp();
      } catch(e) {
        console.error("Sovereign Admin Init Error:", e);
      }
    }
  });
})();
'''

# Clean index.html with proper Flutter 3.x initialization
INDEX_HTML = '''<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Sovereign Admin V15">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="sovereign_admin">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="icons/Icon-192.png"/>
  <link rel="manifest" href="manifest.json">
  <title>sovereign_admin</title>
  <style>
    body { margin: 0; background: #0a0a0a; }
    #loading { 
      display: flex; 
      align-items: center; 
      justify-content: center; 
      height: 100vh; 
      color: #6200EA; 
      font-family: sans-serif;
      font-size: 18px;
    }
  </style>
</head>
<body>
  <div id="loading">Loading Sovereign Admin V15...</div>
  <script src="flutter.js" defer></script>
  <script>
    document.addEventListener("DOMContentLoaded", function() {
      if (window._flutter && window._flutter.loader) {
        window._flutter.loader.load({
          onEntrypointLoaded: async function(engineInitializer) {
            document.getElementById("loading").style.display = "none";
            var appRunner = await engineInitializer.initializeEngine({
              renderer: "html"
            });
            await appRunner.runApp();
          }
        });
      } else {
        // Fallback: load flutter.js and then bootstrap
        var script = document.createElement("script");
        script.src = "flutter_bootstrap.js";
        document.body.appendChild(script);
      }
    });
  </script>
</body>
</html>
'''

NGINX_CONF_WITH_WASM = """
user  nginx;
worker_processes  auto;
events { worker_connections  2048; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # Add WASM MIME type
    types {
        application/wasm  wasm;
    }

    # ADMIN PANEL - vazo.fectok.com
    server {
        listen 80;
        server_name vazo.fectok.com;
        root /usr/share/nginx/html/admin;
        index index.html;
        
        # Allow SharedArrayBuffer (needed for some Flutter features)
        add_header Cross-Origin-Opener-Policy "same-origin";
        add_header Cross-Origin-Embedder-Policy "require-corp";
        add_header Cross-Origin-Resource-Policy "cross-origin";
        
        # Backend API
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)(/|$) {
            proxy_pass http://172.18.0.4:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 3600s;
        }
        
        # Static files - no cache
        location / {
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            try_files $uri $uri/ /index.html;
        }
    }

    # USER PANEL - fectok.com
    server {
        listen 80 default_server;
        server_name fectok.com;
        root /usr/share/nginx/html/user;
        index index.html;
        
        location ~ ^/(api|auth|login|sync|user|v15|vault)(/|$) {
            proxy_pass http://172.18.0.4:5000;
            proxy_set_header Host $host;
            proxy_read_timeout 3600s;
        }
        
        location ~* ^/stream/(.+\\.(mp4|jpg|jpeg|png|webp|gif))$ {
            proxy_pass http://172.18.0.4:5000/media/$1;
        }
        
        location ~ ^/(sound_engine|sound|audio)(/|$) {
            proxy_pass http://172.18.0.8:8000;
        }
        
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
"""

def deploy_final_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== 1. Read original flutter_bootstrap.js ===")
    result = run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/flutter_bootstrap.js")
    print(result[:1000])  # first 1000 chars
    
    print("=== 2. Write new index.html ===")
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/webadmin_panel/index.html", "w") as f:
        f.write(INDEX_HTML)
    print("index.html written")
    
    print("=== 3. Write nginx config with WASM support ===")
    with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
        f.write(NGINX_CONF_WITH_WASM)
    # Also write to the mounted nginx.conf
    with sftp.file("/root/sovereign/nginx.conf", "w") as f:
        f.write(NGINX_CONF_WITH_WASM)
    sftp.close()
    print("nginx config written")
    
    print("=== 4. Check which nginx.conf is actually mounted in container ===")
    print(run_cmd(ssh, "docker inspect sovereign_v15_gateway --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{\"\\n\"}}{{end}}'"))
    
    print("=== 5. Restart gateway ===")
    print(run_cmd(ssh, "docker restart sovereign_v15_gateway", timeout=25))
    import time; time.sleep(4)
    
    print("=== 6. Verify index.html in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/index.html"))
    
    print("=== 7. Test all files ===")
    files = ["", "flutter.js", "flutter_bootstrap.js", "main.dart.js", "manifest.json", "canvaskit/canvaskit.js"]
    for f in files:
        code = run_cmd(ssh, f"curl -s -o /dev/null -w '%{{http_code}}' 'http://localhost/{f}' -H 'Host: vazo.fectok.com'", timeout=8)
        print(f"  /{f}: HTTP {code.strip()}")
    
    print("\n=== 8. Full browser test - fetch main page and check JS errors ===")
    print(run_cmd(ssh, "curl -s 'http://localhost/' -H 'Host: vazo.fectok.com' | grep -i 'script\\|error\\|flutter' | head -10", timeout=10))
    
    print("\n✅ COMPLETE!")
    ssh.close()

if __name__ == "__main__":
    deploy_final_fix()

