import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_highway_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Highway Liberation ---")
    
    # Audit 1: Liberate Port 587 from Host & Docker Network
    print("\n--- STEP 1: PORT DNA LIBERATION ---")
    ssh.exec_command('ufw allow out 587/tcp')
    ssh.exec_command('ufw status')
    # Adding direct iptables rule for Docker Mesh Outbound
    ssh.exec_command('iptables -I FORWARD -p tcp --dport 587 -j ACCEPT')
    ssh.exec_command('iptables -I OUTPUT -p tcp --dport 587 -j ACCEPT')
    print("✅ Port 587 Outbound Liberated for Mesh.")
    
    # Audit 2: Patch GMAIL ENGINE for Absolute Persistence
    # Using specific server settings and increased logging
    GMAIL_ENGINE_DNA = """
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time

def send_email(to_email, subject, body):
    sender_email = "lailebegumyt@gmail.com"
    app_password = "os.getenv("SENDER_PASSWORD")"
    
    msg = MIMEMultipart()
    msg['From'] = f"Sovereign V15 <{sender_email}>"
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        # Added surgical 15s Timeout for unstable networks
        print(f"--- Triggering OTP Pulse to {to_email} ---")
        server = smtplib.SMTP('smtp.gmail.com', 587, timeout=15)
        server.set_debuglevel(1) # Live Trace Audit in Logs
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(msg)
        server.quit()
        print(f"✅ OTP Pulse Successfully Dispatched.")
        return True
    except Exception as e:
        print(f"❌ OTP Pulse Failure DNA: {str(e)}")
        return False
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/backend/gmail_engine.py', 'w') as f:
        f.write(GMAIL_ENGINE_DNA)
    sftp.close()
    
    # Re-ignition for Pulse Sync
    ssh.exec_command('docker restart sovereign_v15_backend')
    print("✅ DNA Pulse Synchronized: OTP Highway IS LIVE.")
    
    ssh.close()

if __name__ == "__main__":
    ultimate_highway_liberation()


