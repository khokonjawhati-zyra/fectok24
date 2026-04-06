import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def debug_admin_white_screen():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS)
    print("=" * 60)
    print("STEP 1: Nginx error log (last 30 lines)")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway tail -30 /var/log/nginx/error.log 2>&1 || cat /var/log/nginx/error.log 2>&1")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 2: Admin access log (last 20 lines)")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway tail -20 /var/log/nginx/admin_realtime.log 2>&1")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 3: Check admin index.html content")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/index.html")
    content = out.read().decode()
    print(content[:2000])  # first 2000 chars

    print("=" * 60)
    print("STEP 4: Check admin folder file list")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 5: Check main.dart.js exists and size")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/main.dart.js 2>&1")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 6: Check flutter.js exists")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/flutter.js /usr/share/nginx/html/admin/flutter_bootstrap.js 2>&1")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 7: Check nginx config is loaded (test)")
    print("=" * 60)
    _, out, err = ssh.exec_command("docker exec sovereign_v15_gateway nginx -t 2>&1")
    print(out.read().decode())
    print(err.read().decode())

    print("=" * 60)
    print("STEP 8: Check docker volume mapping")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker inspect sovereign_v15_gateway | python3 -c \"import sys,json; d=json.load(sys.stdin); [print(m) for m in d[0].get('Mounts',[])]\" 2>&1")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 9: Check real path of admin files on HOST")
    print("=" * 60)
    _, out, _ = ssh.exec_command("ls -la /root/sovereign/webadmin_panel/ 2>&1 | head -20")
    print(out.read().decode())

    print("=" * 60)
    print("STEP 10: Check assets folder")
    print("=" * 60)
    _, out, _ = ssh.exec_command("docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/assets/ 2>&1 | head -10")
    print(out.read().decode())

    ssh.close()
    print("DEBUG COMPLETE")

if __name__ == "__main__":
    debug_admin_white_screen()

