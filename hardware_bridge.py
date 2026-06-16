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
            "cpu_each": psutil.cpu_percent(interval=1, percpu=True),
            "cpu_stats": psutil.cpu_stats(),
            "cpu_freq": psutil.cpu_freq(),
	        "cores": psutil.cpu_count(logical=False),
	        "threads": psutil.cpu_count(),
            "mem_percent": psutil.virtual_memory().percent,
            "mem_stats": psutil.virtual_memory(),
            "disk_count": len(psutil.disk_partitions()),
            "net_stats": psutil.net_io_counters(),
            "temps": psutil.sensors_temperatures(fahrenheit=False)
        }
        # may need to breakdown stats further and label accordingly
        # in future use more granular stat info about processes
        # for now keep system stats as agnostic for broader compatibility
        
        # Write them to the JSON file
        with open(save_path, "w") as f:
            json.dump(data, f)
            
        # Wait 1 second
        time.sleep(1)
        
except KeyboardInterrupt:
    print("\nBridge stopped.")
