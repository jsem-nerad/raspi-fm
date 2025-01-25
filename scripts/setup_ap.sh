#!/bin/bash

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
ssid=raspi-fm
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=flipfmsignal
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

sudo sed -i 's|#DAEMON_CONF="|DAEMON_CONF="/etc/hostapd/hostapd.conf|' /etc/default/hostapd

echo "Starting dnsmasq and hostapd..."
sudo systemctl start dnsmasq
sudo systemctl start hostapd

echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

echo "Configuring NAT..."
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o wlan0 -j ACCEPT

echo "Saving iptables rules..."
sudo mkdir -p /etc/iptables
sudo sh -c "iptables-save > /etc/iptables/rules.v4"

sudo ip addr add 192.168.4.1/24 dev wlan1
sudo ip link set wlan1 up

echo "Access point setup is complete!"
echo "Connect to SSID 'raspi-fm' with password 'flipfmsignal' and access the web app at http://192.168.4.1:5000"
