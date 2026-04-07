import paramiko
import time

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

# Clean index.html that forces HTML renderer (no canvaskit/WASM needed)
CLEAN_INDEX = '''<!DOCTYPE html>
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
  <title>sovereign_admin</title>
</head>
<body>
  <script>
    // Force HTML renderer - no canvaskit/WASM required
    window.flutterConfiguration = {
      renderer: "html"
    };
    window._flutter = window._flutter || {};
    window._flutter.buildConfig = {
      engineRevision: "",
      builds: [{
        compileTarget: "dart2js",
        renderer: "html",
        mainJsPath: "main.dart.js"
      }]
    };
  </script>
  <script src="flutter.js" defer></script>
  <script>
    window.addEventListener('load', function() {
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

MANIFEST_JSON = '''{
  "name": "sovereign_admin",
  "short_name": "sovereign_admin",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0a0a0a",
  "theme_color": "#6200EA",
  "description": "Sovereign V15 Admin Panel",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}
'''

def complete_flutter_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)

    print("=== 1. Check what files SOURCE folder has ===")
    print(run_cmd(ssh, "ls -la /opt/sovereign/core/webadmin_panel/"))
    print(run_cmd(ssh, "ls /opt/sovereign/core/webadmin_panel/assets/ 2>&1 | head -5"))

    print("=== 2. Check if manifest.json exists in source ===")
    print(run_cmd(ssh, "cat /opt/sovereign/core/webadmin_panel/manifest.json 2>&1"))

    print("=== 3. Copy ALL files from source to host folder ===")
    print(run_cmd(ssh, "cp -rf /opt/sovereign/core/webadmin_panel/. /root/sovereign/webadmin_panel/"))
    print(run_cmd(ssh, "ls /root/sovereign/webadmin_panel/"))

    print("=== 4. Write HTML renderer index.html ===")
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/webadmin_panel/index.html", "w") as f:
        f.write(CLEAN_INDEX)
    with sftp.file("/root/sovereign/webadmin_panel/manifest.json", "w") as f:
        f.write(MANIFEST_JSON)
    sftp.close()
    print("Written index.html + manifest.json")

    print("=== 5. Verify container has files after sync ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/"))

    print("=== 6. Test manifest.json 200 ===")
    print(run_cmd(ssh, "curl -s -o /dev/null -w '%{http_code}' http://localhost/manifest.json -H 'Host: vazo.fectok.com'", timeout=10))

    print("=== 7. Nginx reload ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -s reload"))

    print("\n✅ COMPLETE! Now test vazo.fectok.com in Incognito!")
    ssh.close()

if __name__ == "__main__":
    complete_flutter_fix()

