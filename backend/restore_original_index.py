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

def restore_original():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)

    print("=== Original index.html from source ===")
    print(run_cmd(ssh, "cat /opt/sovereign/core/webadmin_panel/index.html"))

    print("=== Restore ORIGINAL index.html ===")
    print(run_cmd(ssh, "cp /opt/sovereign/core/webadmin_panel/index.html /root/sovereign/webadmin_panel/index.html"))

    print("=== Create manifest.json (was missing from source) ===")
    sftp = ssh.open_sftp()
    manifest = '''{
  "name": "sovereign_admin",
  "short_name": "sovereign_admin",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0a0a0a",
  "theme_color": "#6200EA",
  "description": "Sovereign V15 Admin",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}'''
    with sftp.file("/root/sovereign/webadmin_panel/manifest.json", "w") as f:
        f.write(manifest)
    sftp.close()

    print("=== Verify container files ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/"))

    print("=== Verify index.html in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/index.html"))

    print("=== Test ALL critical files via nginx ===")
    files = ["", "flutter.js", "flutter_bootstrap.js", "main.dart.js", "manifest.json", "flutter_service_worker.js"]
    for f in files:
        url = f"http://localhost/{f}"
        code = run_cmd(ssh, f"curl -s -o /dev/null -w '%{{http_code}}' '{url}' -H 'Host: vazo.fectok.com'", timeout=8)
        print(f"  {f or 'index.html'}: {code.strip()}")

    print("=== nginx reload ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -s reload"))

    print("\n✅ Check vazo.fectok.com now - press Ctrl+Shift+R (hard refresh without cache)")
    ssh.close()

if __name__ == "__main__":
    restore_original()

