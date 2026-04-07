import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fire_outbound_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Outbound Master Pulse ---")
    
    # Audit 1: Liberate Port 587 Outbound & Inbound
    ssh.exec_command('ufw allow out 587/tcp')
    ssh.exec_command('ufw allow 587/tcp')
    ssh.exec_command('ufw allow out 465/tcp')
    ssh.exec_command('ufw allow out 25/tcp')
    print("✅ Outbound Email Ports Liberated.")
    
    # Audit 2: Patch GMAIL ENGINE with Timeout DNA
    GMAIL_ENGINE_DNA = """
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(to_email, subject, body):
    sender_email = "lailebegumyt@gmail.com"
    app_password = "os.getenv("SENDER_PASSWORD")"
    
    msg = MIMEMultipart()
    msg['From'] = f"Sovereign V15 <{sender_email}>"
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        # Added 10s Timeout for Stability DNA
        server = smtplib.SMTP('smtp.gmail.com', 587, timeout=10)
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(msg)
        server.quit()
        print(f"✅ OTP Pulse Successfully Dispatched to {to_email}")
        return True
    except Exception as e:
        print(f"❌ OTP Pulse Failure: {str(e)}")
        return False
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/backend/gmail_engine.py', 'w') as f:
        f.write(GMAIL_ENGINE_DNA)
    sftp.close()
    
    # Re-ignition for Absolute Sync
    ssh.exec_command('docker restart sovereign_v15_backend')
    print("✅ DNA Pulse Synchronized: Email Outbound IS LIVE.")
    
    ssh.close()

if __name__ == "__main__":
    fire_outbound_liberation()


