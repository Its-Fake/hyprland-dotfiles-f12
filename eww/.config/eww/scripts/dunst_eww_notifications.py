#!/usr/bin/env python3
import json
import subprocess
import sys
from datetime import datetime, timedelta

def get_notifications():
    try:
        # 1. Get the current system uptime in seconds
        with open('/proc/uptime', 'r') as f:
            system_uptime = int(float(f.readline().split()[0]))

        # 2. Get the notification history from dunst
        command = ["dunstctl", "history"]
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)

        notifications_data = data.get("data", [[]])[0]
        notif_list = []

        for n in notifications_data:
            summary = n.get("summary", {}).get("data", "")
            body = n.get("body", {}).get("data", "")
            
            # 3. Calculate the correct notification time
            notification_uptime = n.get("timestamp", {}).get("data", 0) / 1000000
            how_long_ago_seconds = int(system_uptime - notification_uptime)
            
            notification_time = datetime.now() - timedelta(seconds=how_long_ago_seconds)
            time = notification_time.strftime("%H:%M")

            notif_list.append({
                "id": n.get("id", {}).get("data", ""),
                "icon": "󰂚",
                "summary": summary,
                "body": body,
                "urgency": n.get("urgency", {}).get("data", "NORMAL"),
                "time": time
            })

        print(json.dumps({
            "notifications": notif_list,
            "notification_count": len(notif_list)
        }))

    except Exception as e:
        print(json.dumps({"notifications": [], "notification_count": 0}), file=sys.stderr)

if __name__ == "__main__":
    get_notifications()
