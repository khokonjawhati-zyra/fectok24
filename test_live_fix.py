import requests

def test_login_endpoint():
    url = "https://fectok.com/login"
    try:
        # We send a GET to check if it's at least NOT a 404/HTML
        print(f"Testing {url} (GET)...")
        r = requests.get(url, timeout=10)
        print(f"Status: {r.status_code}")
        print(f"Content-Type: {r.headers.get('Content-Type')}")
        if "text/html" in r.headers.get('Content-Type', ''):
             print("FAIL: Received HTML instead of JSON/API Response.")
        else:
             print("SUCCESS: Endpoint responded (Method Not Allowed likely as JSON).")
             print(r.text)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_login_endpoint()
