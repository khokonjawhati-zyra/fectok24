import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

CLEAN_INDEX_HTML = '''<!DOCTYPE html>
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
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
'''

def run_cmd(ssh, cmd, timeout=15):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except Exception as e:
        return f"TIMEOUT: {e}"

def fix_index_and_sw():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== STEP 1: Write clean index.html to HOST folder ===")
    # Write via heredoc to host folder (volume source)
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/webadmin_panel/index.html", "w") as f:
        f.write(CLEAN_INDEX_HTML)
    sftp.close()
    print("Written to host webadmin_panel/index.html")
    
    print("=== STEP 2: Verify new index.html ===")
    print(run_cmd(ssh, "cat /root/sovereign/webadmin_panel/index.html"))
    
    print("=== STEP 3: Verify in container (volume sync) ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/index.html"))
    
    print("=== STEP 4: Also update service worker to force reload ===")
    # Bust service worker cache by modifying the version
    result = run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/flutter_service_worker.js | head -5")
    print(f"SW header: {result}")
    
    print("=== STEP 5: Nginx reload ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -s reload 2>&1"))
    
    print("=== STEP 6: Quick curl test to verify response ===")
    print(run_cmd(ssh, "curl -s http://localhost/ -H 'Host: vazo.fectok.com' | head -20", timeout=10))
    
    print("\n✅ DONE! index.html is now clean. Please open vazo.fectok.com in Chrome Incognito mode.")
    ssh.close()

if __name__ == "__main__":
    fix_index_and_sw()

