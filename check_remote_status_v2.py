import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_ssh_cmd(cmd):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    _in, out, err = ssh.exec_command(cmd)
    res = out.read().decode()
    err_res = err.read().decode()
    ssh.close()
    return res, err_res

if __name__ == "__main__":
    print("--- DOCKER PS ---")
    print(run_ssh_cmd("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")[0])
    print("--- NETSTAT 80/443 ---")
    print(run_ssh_cmd("netstat -tulnp | grep -E '80|443'")[0])
    print("--- NGINX STATUS ---")
    print(run_ssh_cmd("systemctl status nginx --no-pager")[0])

