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

def deep_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)

    print("=== 1. flutter_bootstrap.js FULL ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/flutter_bootstrap.js"))

    print("=== 2. Test main.dart.js accessible via nginx ===")
    print(run_cmd(ssh, "curl -s -o /dev/null -w '%{http_code}' http://localhost/main.dart.js -H 'Host: vazo.fectok.com'", timeout=10))

    print("=== 3. Test flutter.js accessible ===")
    print(run_cmd(ssh, "curl -s -o /dev/null -w '%{http_code}' http://localhost/flutter.js -H 'Host: vazo.fectok.com'", timeout=10))

    print("=== 4. Test flutter_bootstrap.js accessible ===")
    print(run_cmd(ssh, "curl -s -o /dev/null -w '%{http_code}' http://localhost/flutter_bootstrap.js -H 'Host: vazo.fectok.com'", timeout=10))

    print("=== 5. manifest.json ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/manifest.json"))

    print("=== 6. Nginx error log ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /var/log/nginx/error.log 2>/dev/null | tail -20 || echo 'no error log'", timeout=10))

    ssh.close()

if __name__ == "__main__":
    deep_check()

