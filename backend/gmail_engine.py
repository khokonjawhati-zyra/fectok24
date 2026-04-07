import os
import smtplib
import time
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Sovereign V15: Master Quantum Pulse Engine (Hybrid SMTP + OAuth2)
logger = logging.getLogger('QuantumSync')

class RobustSMTPBridge:
    def __init__(self):
        self.token_path = 'token.json'
        self.secret_path = 'client_secret.json'
        
        # SMTP Fallback Credentials
        self.user = os.getenv('SENDER_EMAIL', 'lailebegumyt@gmail.com')
        self.password = os.getenv('SENDER_PASSWORD', 'os.getenv("SENDER_PASSWORD")')
        self.smtp_server = "smtp.gmail.com"
        self.smtp_port = 587
        
        self.retry_limit = 3
        logger.info(f"RobustSMTPBridge: Master Engine Engaged [Hybrid Mode]")

    def send_email(self, sender_email, to_email, subject, body_html):
        """
        Sovereign V15: Secure Injection of Pulsed Identity (OAuth2 -> SMTP)
        """
        # Try OAuth2 Pulse First (Original Logic)
        if os.path.exists(self.token_path):
            try:
                logger.info(f"AUTH_PULSE: Attempting OAuth2 Injection for {to_email}...")
                creds = Credentials.from_authorized_user_file(self.token_path)
                
                # Refresh if expired
                if creds and creds.expired and creds.refresh_token:
                    creds.refresh(Request())
                
                service = build('gmail', 'v1', credentials=creds)
                message = MIMEMultipart()
                message['to'] = to_email
                message['subject'] = subject
                message.attach(MIMEText(body_html, 'html'))
                
                raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
                service.users().messages().send(userId='me', body={'raw': raw}).execute()
                
                logger.info(f"OAUTH2_PULSE_SUCCESS: Identity delivered to {to_email}")
                return True
            except Exception as e:
                logger.warning(f"OAUTH2_PULSE_FAIL: {e}. Falling back to SMTP...")

        # SMTP Fallback Protocol [A_114]
        for attempt in range(self.retry_limit):
            try:
                msg = MIMEMultipart()
                msg['From'] = f"Sovereign Security <{self.user}>"
                msg['To'] = to_email
                msg['Subject'] = subject
                msg.attach(MIMEText(body_html, 'html'))

                server = smtplib.SMTP(self.smtp_server, self.smtp_port, timeout=15)
                server.starttls()
                server.login(self.user, self.password)
                server.sendmail(self.user, to_email, msg.as_string())
                server.quit()

                logger.info(f"SMTP_PULSE_SUCCESS: Bridge delivered to {to_email} [Attempt {attempt + 1}]")
                return True
            except Exception as e:
                logger.error(f"SMTP_PULSE_RETRY [{attempt + 1}/{self.retry_limit}]: {e}")
                time.sleep(2)

        return False

# Master Pulse Instance
gmail_engine = RobustSMTPBridge()

