import asyncio
import json
import sys
import os

# Set paths
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

async def run_test():
    try:
        from main import imperial_finance, manager, user_auth
        from ai_engine import ai_brain
        
        print("Starting [Safe-Inject] Manual Batch Execution Test...")
        
        # Initial Balances
        u_id = "SOV_TEST_777"
        ref_id = "SOV_89173"
        
        def print_bal(uid):
            b = manager.get_user_balance(uid)
            if not b:
                print(f"Balance for {uid}: NOT_FOUND")
                return
            print(f"Balance for {uid}: USD:{b.get('USD', 0)}, BDT:{b.get('BDT', 0)}, COINS:{b.get('COINS', 0)}")

        print_bal(u_id)
        print_bal(ref_id)
        
        # 1. Process Batch
        batch_res = await imperial_finance.process_batch(
            admin_id="MASTER_ADMIN",
            otp_verified=True, 
            ai_brain=ai_brain
        )
        
        # Filter results to avoid big logs
        log_res = { "status": batch_res.get("status"), "item_count": len(batch_res.get("details", [])) }
        print(f"Batch Execution Result: {json.dumps(log_res, indent=2)}")
        
        # 2. Handle Logic for Referrer rewarding (MLM) as done in main.py
        from main import mlm
        
        for item in batch_res.get("details", []):
            u_id_item = item.get("user_id")
            currency = item.get("currency", "BDT")
            amount = float(item.get("amount", 0.0))
            
            if item.get("status") == "PAID":
                print(f"Item PAID: {u_id_item} | Amount: {amount} {currency}")
                
                # MLM Distribution
                ref_currency = item.get("original_currency", currency)
                ref_amount = float(item.get("original_amount", amount))
                ref_tax = float(item.get("original_tax_amount", 0.0))
                
                print(f"Processing MLM: RefAmt: {ref_amount}, RefTax: {ref_tax} {ref_currency}")
                
                commission_report = mlm.process_withdrawal_commission(
                    u_id_item, 
                    ref_amount, 
                    ref_currency, 
                    bypass_deduction=True,
                    fixed_commission=ref_tax
                )
                
                if commission_report:
                    print(f"MLM Success: Referrer {commission_report.get('referrer')} credited with {commission_report.get('amount')}")
            
            elif item.get("status") in ["FAILED", "REJECTED_BY_AI"]:
                print(f"Item FAILED/REJECTED: {u_id_item} | Error: {item.get('error')}")

        # Save changes
        manager._save_ledger()
        print("Test cycle complete. Finalizing archive...")
        archived = imperial_finance.finalize_and_archive()
        print(f"Archived {archived} items.")
        
        # Final Balances
        print_bal(u_id)
        print_bal(ref_id)

    except Exception as e:
        print(f"CRITICAL TEST ERROR: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(run_test())
