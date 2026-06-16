import psutil
import json
import time
import os

print("Hardware Bridge running... writing to hardware_stats.json")
print("Press Ctrl+C to stop.")

# This creates the file in the exact same folder the script is run from
save_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "hardware_stats.json")

try:
    while True:
        # Gather the real stats
        data = {
            "cpu": psutil.cpu_percent(interval=None),
	        "cores": psutil.cpu_count(logical=False),
	        "threads": psutil.cpu_count(), 
            "mem": psutil.virtual_memory().percent
        }
        
        # Write them to the JSON file
        with open(save_path, "w") as f:
            json.dump(data, f)
            
        # Wait 1 second
        time.sleep(1)
        
except KeyboardInterrupt:
    print("\nBridge stopped.")
