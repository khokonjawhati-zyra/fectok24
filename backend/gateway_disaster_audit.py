import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def global_gateway_dna_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Gateway DNA Pulse ---")
    
    # Check if container is even there
    _, out1, _ = ssh.exec_command('docker ps -a --filter "name=sovereign_v15_gateway" --format "{{.Names}} : {{.Status}}"')
    print(f"GATEWAY STATUS:\n{out1.read().decode()}")
    
    # Check if anything is on port 80/443 on host
    _, out2, _ = ssh.exec_command('netstat -lntp | grep -E ":80|:443"')
    print(f"HOST PORTS:\n{out2.read().decode()}")
    
    # Test nginx in container
    _, out3, _ = ssh.exec_command('docker exec sovereign_v15_gateway nginx -t')
    _, err3, _ = ssh.exec_command('docker exec sovereign_v15_gateway nginx -t')
    print(f"NGINX DNA TEST:\n{out3.read().decode()} {err3.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    global_gateway_dna_audit()

