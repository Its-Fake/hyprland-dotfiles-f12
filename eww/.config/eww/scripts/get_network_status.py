#!/usr/bin/env python3
import json
import subprocess
import sys

def run_command(command):
    """Executes a shell command and returns the output."""
    try:
        env = {'LC_ALL': 'C'}
        return subprocess.run(command, capture_output=True, text=True, check=True, env=env).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""

def get_network_status():
    """Gathers all network information and outputs it as JSON."""
    status = {}

    # 1. Airplane Mode Status (unchanged)
    radios = run_command(["nmcli", "-t", "-f", "WIFI", "radio"])
    status["airplane_mode"] = "disabled" in radios

    # 2. Universal Primary Connection Logic
    active_cons = run_command(["nmcli", "-t", "-f", "NAME,TYPE", "con", "show", "--active"]).splitlines()
    
    primary_connection_name = ""
    primary_connection_type = "Disconnected"

    # Prioritize Ethernet connection
    for line in active_cons:
        if "ethernet" in line:
            primary_connection_name = line.split(':')[0]
            primary_connection_type = "ethernet"
            break
    
    # If no Ethernet, look for Wi-Fi
    if not primary_connection_name:
        for line in active_cons:
            if "802-11-wireless" in line:
                primary_connection_name = line.split(':')[0]
                primary_connection_type = "wifi"
                break
    
    status["primary_connection_name"] = primary_connection_name
    status["primary_connection_type"] = primary_connection_type
    
    # 3. Wi-Fi Specifics
    wifi_radio_status = run_command(["nmcli", "-t", "-f", "WIFI", "radio"])
    wifi_on = wifi_radio_status == "enabled"
    status["wifi_on"] = wifi_on
    
    wifi_networks = []
    if wifi_on:
        scan_raw = run_command(["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL", "dev", "wifi", "list"])
        ssids_seen = set()
        for line in scan_raw.splitlines():
            parts = line.split(':', 2)
            if len(parts) >= 3 and parts[0] and parts[0] not in ssids_seen:
                ssids_seen.add(parts[0])
                wifi_networks.append({
                    "ssid": parts[0],
                    "security": parts[1] != "",
                    "signal": int(parts[2])
                })
    status["wifi_networks"] = sorted(wifi_networks, key=lambda x: x['signal'], reverse=True)

    # 4. VPN List
    all_cons_raw = run_command(["nmcli", "-t", "-f", "NAME,TYPE", "con", "show"])
    active_cons_raw = run_command(["nmcli", "-t", "-f", "NAME", "con", "show", "--active"])
    available_vpns = []
    for line in all_cons_raw.splitlines():
        if "wireguard" in line:
            vpn_name = line.split(':')[0]
            available_vpns.append({
                "name": vpn_name,
                "is_active": vpn_name in active_cons_raw
            })
    status["vpns"] = available_vpns

    print(json.dumps(status))

if __name__ == "__main__":
    get_network_status()
