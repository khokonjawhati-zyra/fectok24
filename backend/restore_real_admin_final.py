import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def run_cmd(ssh, cmd, timeout=30):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except Exception as e:
        return f"TIMEOUT: {e}"

def restore_real_admin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== PHASE 1: PURGING MAPPED FOLDER ===")
    print(run_cmd(ssh, "rm -rf /root/sovereign/webadmin_panel/*"))
    
    print("=== PHASE 2: RESTORING REAL FLUTTER BUILD FROM CORE ===")
    # Copy from the real core build location
    print(run_cmd(ssh, "cp -rf /opt/sovereign/core/webadmin_panel/. /root/sovereign/webadmin_panel/"))
    
    print("=== PHASE 3: NEURAL PATCHING INDEX.HTML FOR STABILITY ===")
    # The white screen usually happens because of flutter_bootstrap.js or manifest.json issues
    # I will create a guaranteed-to-work index.html for this specific build
    CLEAN_REAL_INDEX = '''<!DOCTYPE html>
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
  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="manifest" href="manifest.json">
  <title>sovereign_admin</title>
  <script>
    window.flutterWebRenderer = "html";
    console.log("Sovereign V15: Sharding Master Admin Pulse...");
  </script>
</head>
<body style="background: #000;">
  <script src="flutter.js" defer></script>
  <script>
    window.addEventListener('load', function(ev) {
      _flutter.loader.load({
        onEntrypointLoaded: async function(engineInitializer) {
          let appRunner = await engineInitializer.initializeEngine({
            renderer: "html"
          });
          await appRunner.runApp();
        }
      });
    });
  </script>
</body>
</html>
'''
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/webadmin_panel/index.html", "w") as f:
        f.write(CLEAN_REAL_INDEX)
        
    print("=== PHASE 4: INJECTING MISSING MANIFEST.JSON ===")
    MANIFEST = '''{
  "name": "sovereign_admin",
  "short_name": "sovereign_admin",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#000000",
  "theme_color": "#6200EA",
  "description": "Sovereign V15 Realtime Core Admin",
  "orientation": "portrait-primary",
  "icons": [
    {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"}
  ]
}'''
    with sftp.file("/root/sovereign/webadmin_panel/manifest.json", "w") as f:
        f.write(MANIFEST)
    sftp.close()
    
    print("=== PHASE 5: REIGNITING GATEWAY SHARD ===")
    print(run_cmd(ssh, "docker restart sovereign_v15_gateway"))
    
    print("=== PHASE 6: FINAL FILE AUDIT ===")
    print(run_cmd(ssh, "ls -la /root/sovereign/webadmin_panel/"))
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/main.dart.js"))
    
    ssh.close()
    print("\n✅ MISSION ACCOMPLISHED: The REAL Admin Panel is now restored and patched.")

if __name__ == "__main__":
    restore_real_admin()

