#!/usr/bin/env python3
import subprocess
import json
import re

def get_history():
    try:
        # Holt die ersten 10 Einträge
        result = subprocess.run("cliphist list | head -n 50", shell=True, capture_output=True, text=True).stdout.strip()
    except Exception:
        print(json.dumps([]))
        return

    history_list = []
    
    if result:
        for line in result.splitlines():
            parts = line.split("\t", 1)
            if len(parts) == 2:
                clip_id = parts[0]
                raw_content = parts[1].strip()
                
                # Prüfen, ob es Binärdaten (Bild) sind
                # Format ist meist: [[ binary data 2.3 MiB png ]]
                if raw_content.startswith("[[ binary data"):
                    match = re.search(r'binary data (.*?) (.*?) \]\]', raw_content)
                    if match:
                        size = match.group(1)
                        fmt = match.group(2)
                        display_text = f"Image ({fmt.upper()} - {size})"
                    else:
                        display_text = "Image"
                else:
                    # Normaler Text
                    display_text = raw_content

                history_list.append({"id": clip_id, "content": display_text})

    print(json.dumps(history_list))

if __name__ == "__main__":
    get_history()