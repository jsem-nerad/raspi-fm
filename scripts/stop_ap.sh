#!/bin/bash

echo "Stopping access point..."

# Stop dnsmasq and hostapd services
echo "Stopping dnsmasq and hostapd services..."
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

# Disable hostapd to prevent it from starting at boot
echo "Disabling hostapd..."
sudo systemctl disable hostapd

# Remove the virtual interface created for the access point
if iw dev wlan1 info > /dev/null 2>&1; then
  echo "Removing virtual interface wlan1..."
  sudo iw dev wlan1 del
else
  echo "Virtual interface wlan1 does not exist, skipping removal."
fi

# Restore default dnsmasq configuration if it was modified
if [ -f /etc/dnsmasq.conf ]; then
  echo "Restoring default dnsmasq configuration..."
  sudo rm -f /etc/dnsmasq.conf
fi

# Reset IP address and bring down the interface if still active
if ip addr show wlan1 > /dev/null 2>&1; then
  echo "Resetting IP address and bringing down wlan1..."
  sudo ip addr flush dev wlan1
  sudo ip link set wlan1 down
else
  echo "Interface wlan1 is not active, skipping IP reset."
fi

# Notify user of completion
echo "Access point has been stopped successfully."
