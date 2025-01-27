#!/bin/bash

CONFIG_FILE="/opt/raspifm/config.ini"

# Function to extract values from config.ini
get_config_value() {
  local key=$1
  awk -F '=' -v key="$key" '$1 ~ key {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$CONFIG_FILE"
}

# Ensure the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[ERROR] Config file not found at $CONFIG_FILE"
  exit 1
fi

# Extract SSID and password from config.ini
SSID=$(get_config_value "ssid")
PASSWORD=$(get_config_value "password")

if [ -z "$SSID" ] || [ -z "$PASSWORD" ]; then
  echo "[ERROR] SSID or password is missing in $CONFIG_FILE"
  exit 1
fi

echo "Stopping conflicting services..."
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

echo "Ensuring hostapd is unmasked..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

echo "Creating virtual interface..."
sudo iw dev wlan0 interface add wlan1 type __ap

echo "Configuring dnsmasq..."
cat <<EOF | sudo tee /etc/dnsmasq.conf
interface=wlan1
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

sudo systemctl restart dnsmasq

echo "Configuring hostapd..."
cat <<EOF | sudo tee /etc/hostapd/hostapd.conf
interface=wlan1
driver=nl80211
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

sudo sed -i 's|#DAEMON_CONF="|DAEMON_CONF="/etc/hostapd/hostapd.conf|' /etc/default/hostapd

echo "Starting dnsmasq and hostapd..."
sudo systemctl start dnsmasq
sudo systemctl start hostapd

sudo ip addr add 192.168.4.1/24 dev wlan1
sudo ip link set wlan1 up

echo "Access point setup is complete!"
echo "Connect to SSID '$SSID' with password '$PASSWORD' and access the web app at http://192.168.4.1:5000"
