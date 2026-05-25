#!/usr/bin/env python3
import json
import subprocess
import sys
import os
import re

def run_command(command):
    """Führt einen Shell-Befehl mit der korrekten Umgebung aus."""
    try:
        env = {
            'LC_ALL': 'C',
            'PATH': os.environ.get('PATH'),
            'XDG_RUNTIME_DIR': os.environ.get('XDG_RUNTIME_DIR')
        }
        return subprocess.run(command, capture_output=True, text=True, check=True, env=env).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""

def get_pactl_devices(device_type):
    """Ermittelt Geräte und ihren 'active' Status (ohne Filterung)."""
    raw_list = run_command(["pactl", "list", device_type])
    default_device_name = run_command(["pactl", f"get-default-{device_type.rstrip('s')}"])
    
    devices = []
    running_device_id = None
    default_device_id = None

    current_device = {}
    for line in raw_list.splitlines():
        line = line.strip()
        if line.startswith("Sink #") or line.startswith("Source #"):
            if current_device:
                devices.append(current_device)
            current_device = {"id": int(re.search(r'#(\d+)', line).group(1))}
        
        if line.startswith("State:"):
            if "RUNNING" in line:
                running_device_id = current_device.get("id")
        elif line.startswith("Name:"):
            current_device["name"] = line.split(":", 1)[1].strip()
        elif line.startswith("Description:"):
            current_device["description"] = line.split(":", 1)[1].strip()

    if current_device:
        devices.append(current_device)

    # Finde die ID des Default-Geräts aus der vollen Liste
    for dev in devices:
        if dev.get("name") == default_device_name:
            default_device_id = dev.get("id")
            break
            
    active_device_id = running_device_id if running_device_id is not None else default_device_id

    # Weise den 'is_active' Status der vollen Liste zu
    for dev in devices:
        dev["is_active"] = (dev.get("id") == active_device_id)

    # Gib die volle, ungefilterte Liste zurück
    return devices

def get_audio_status():
    """Sammelt alle Audio- und Bluetooth-Informationen."""
    status = {}

    # 1. Lautstärke und Stumm-Status
    volume_str = run_command(["pamixer", "--get-volume"])
    status['volume'] = int(volume_str) if volume_str else 0
    mute_str = run_command(["pamixer", "--get-mute"])
    status['is_muted'] = mute_str == "true"
    source_volume_str = run_command(["pamixer", "--default-source", "--get-volume"])
    status['source_volume'] = int(source_volume_str) if source_volume_str else 0
    source_mute_str = run_command(["pamixer", "--default-source", "--get-mute"])
    status['source_is_muted'] = source_mute_str == "true"

    # 2. Audio Ein-/Ausgabegeräte
    status['sinks'] = get_pactl_devices("sinks")
    status['sources'] = get_pactl_devices("sources")

    # 3. Erweiterter Bluetooth-Teil
    all_devices_raw = run_command(["bluetoothctl", "devices"])
    paired_devices_raw = run_command(["bluetoothctl", "devices", "Paired"])
    bt_connected_raw = run_command(["bluetoothctl", "info"])
    
    paired_devices = []
    discoverable_devices = []
    
    paired_macs = set()
    for line in paired_devices_raw.splitlines():
        parts = line.split(maxsplit=2)
        if len(parts) >= 3:
            mac = parts[1]
            name = parts[2]
            paired_macs.add(mac)
            is_connected = f"Device {mac}" in bt_connected_raw and "Connected: yes" in bt_connected_raw
            paired_devices.append({"mac": mac, "name": name, "is_connected": is_connected})

    for line in all_devices_raw.splitlines():
        parts = line.split(maxsplit=2)
        if len(parts) >= 3:
            mac = parts[1]
            name = parts[2]
            if mac not in paired_macs:
                discoverable_devices.append({"mac": mac, "name": name})

    status['bluetooth_devices'] = paired_devices
    status['discoverable_devices'] = discoverable_devices

    print(json.dumps(status))

if __name__ == "__main__":
    get_audio_status()