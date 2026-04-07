import urllib.request
import urllib.error

def test_login_endpoint():
    url = "http://167.71.193.34/login" # Use direct IP to avoid local host issues
    print(f"Testing {url} (Direct IP, GET)...")
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            content_type = response.headers.get('Content-Type', '')
            print(f"Status: {response.getcode()}")
            print(f"Content-Type: {content_type}")
            if "text/html" in content_type:
                 print("FAIL: Received HTML instead of JSON/API Response.")
            else:
                 print("SUCCESS: Endpoint responded.")
                 print(response.read().decode())
    except urllib.error.HTTPError as e:
        print(f"HTTP Status: {e.code}")
        # 405 is expected for GET on a POST endpoint
        content_type = e.headers.get('Content-Type', '')
        print(f"Content-Type: {content_type}")
        if "application/json" in content_type:
             print("SUCCESS: 405 Method Not Allowed received AS JSON. Routing is CORRECT.")
        else:
             print("FAIL: Received something else (Likely HTML Error).")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_login_endpoint()
