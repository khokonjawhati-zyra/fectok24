import os.path
import base64
from email.mime.text import MIMEText
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def main():
    creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if creds.expired:
        print("Refreshing token...")
        try:
            creds.refresh(Request())
            with open('token.json', 'w') as token:
                token.write(creds.to_json())
            print("Token refreshed!")
        except Exception as e:
            print(f"Refresh FAILED: {e}")
            return

    service = build('gmail', 'v1', credentials=creds)
    
    # Try to send a test mail to the user themselves
    sender = "me"
    subject = "Sovereign OTP Engine Test"
    body = "Test email from Sovereign AI Engine. If you see this, Gmail integration is ONLINE."
    
    message = MIMEText(body)
    message['to'] = "khokonjawhati@gmail.com" # Assuming this is the admin
    message['subject'] = subject
    
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
    try:
        service.users().messages().send(userId=sender, body={'raw': raw}).execute()
        print("TEST EMAIL SENT SUCCESSFULLY!")
    except Exception as e:
        print(f"SEND FAILED: {e}")

if __name__ == '__main__':
    main()
