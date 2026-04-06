import os.path
from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials

SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def main():
    flow = InstalledAppFlow.from_client_secrets_file('client_secret.json', SCOPES)
    # Random port again to avoid 10048 error
    creds = flow.run_local_server(port=0, access_type='offline', prompt='consent')
    
    with open('token.json', 'w') as token:
        token.write(creds.to_json())
    print("সফলভাবে চিরস্থায়ী (Permanent) token.json জেনারেট হয়েছে!")

if __name__ == '__main__':
    main()
