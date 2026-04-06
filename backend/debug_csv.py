import os
import sys

# Add current dir to path if needed
sys.path.append('/app')

try:
    from main import mlm, _generate_bank_csv_bytes, bank_vault
    
    # Manually check items in mlm.pending_tx_map
    print(f"DEBUG: Found {len(mlm.pending_tx_map)} pending txs total.")
    
    csv_data = _generate_bank_csv_bytes()
    print("--- CSV CONTENT START ---")
    print(csv_data.decode('utf-8-sig'))
    print("--- CSV CONTENT END ---")
    
except Exception as e:
    print(f"ERROR: {e}")
