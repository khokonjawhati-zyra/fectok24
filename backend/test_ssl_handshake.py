import asyncio
import os
import sys

# Ensure the backend directory is in the path so we can import payout_bridge
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from payout_bridge import governor

async def sanity_check_sslcommerz():
    print("🚀 [SANITY CHECK] Initiating SSLCommerz Handshake Test...")
    print(f"--- Mode: {governor.payout_mode} ---")
    print(f"--- Store ID: {governor.gateways['sslcommerz']['key']} ---")
    
    # Simulate a deposit request
    # Amount: 10, User: SANITY_TEST_USER
    try:
        # We use initiate_sslcommerz_deposit directly for precision
        result = await governor.initiate_sslcommerz_deposit(amount=10.50, user_id="SANITY_TEST_USER", currency="BDT")
        
        print("\n--- [RESULT] ---")
        if result.get("status") == "SUCCESS":
            print("✅ SUCCESS! Gateway Handshake Perfect.")
            print(f"🌐 Payment URL: {result.get('payment_url')}")
            print("\nLogic: Connection established, Credentials verified, SSLCommerz returned a valid session.")
        else:
            print("❌ FAILED! Gateway rejected the request.")
            print(f"Message: {result.get('message')}")
            
    except Exception as e:
        print(f"🔥 CRITICAL ERROR during test: {e}")
    finally:
        await governor.close()

if __name__ == "__main__":
    # Run the async test
    asyncio.run(sanity_check_sslcommerz())
