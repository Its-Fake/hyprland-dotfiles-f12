#!/usr/bin/env python3
import json
import subprocess
import sys
import os

def run_command(command):
    try:
        env = {'LC_ALL': 'C'}
        return subprocess.run(command, capture_output=True, text=True, check=True, env=env).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""

def get_power_status():
    status = {}

    # 1. Brightness (using brightnessctl correctly)
    current_brightness_str = run_command(["brightnessctl", "g"])
    max_brightness_str = run_command(["brightnessctl", "m"])

    if current_brightness_str and max_brightness_str:
        current_val = int(current_brightness_str)
        max_val = int(max_brightness_str)
        # Calculate percentage, ensuring no division by zero
        status['brightness'] = int((current_val / max_val) * 100) if max_val > 0 else 0
    else:
        status['brightness'] = 0

    # 2. Idle-Status (prüft, ob die Flag-Datei existiert)
    status['is_idle_paused'] = os.path.exists('/tmp/hypridle_paused')

    # 3. Energiemodus
    status['power_profile'] = run_command(["powerprofilesctl", "get"])

    # 4. Nachtmodus (prüft, ob der gammastep-Prozess läuft)
    status['is_night_light_on'] = run_command(["pgrep", "-x", "gammastep"]) != ""

    # 5. Rotation Toggle Status
    toggle_file = os.path.expanduser("~/.config/hypr/rotation-toggle")
    try:
        with open(toggle_file, "r") as f:
            # Wenn '1' in der Datei steht, ist es True, sonst False
            status['rotation_active'] = f.read().strip() == "1"
    except (FileNotFoundError, IOError):
        # Fallback, falls Datei nicht existiert
        status['rotation_active'] = False

    print(json.dumps(status))

if __name__ == "__main__":
    get_power_status()
