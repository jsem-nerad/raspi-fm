#!/bin/bash

# Function to clean up on exit
cleanup() {
    echo -e "\nCleaning up..."
    sudo systemctl stop bluetooth
    sudo modprobe -r snd-aloop
    pulseaudio --kill
    echo "Bluetooth and loopback device stopped."
    exit 0
}

# Trap Ctrl+C to run the cleanup function
trap cleanup SIGINT

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

# Update system and install necessary packages only if not already installed
echo "Checking and installing dependencies if needed..."
if ! dpkg -l | grep -q pulseaudio; then
    sudo apt update && sudo apt install -y pulseaudio pulseaudio-module-bluetooth bluez-tools sox libsox-fmt-mp3
fi

# Load snd-aloop module if not already loaded
if ! lsmod | grep -q snd_aloop; then
    echo "Loading snd-aloop module..."
    sudo modprobe snd-aloop
    echo "snd-aloop" | sudo tee -a /etc/modules
fi

# Configure ALSA loopback device if not already configured
ALSA_CONF="/etc/asound.conf"
if [ ! -f "$ALSA_CONF" ] || ! grep -q "loopback" "$ALSA_CONF"; then
    echo "Configuring ALSA loopback device..."
    cat <<EOL | sudo tee /etc/asound.conf
pcm.!default {
    type plug
    slave.pcm "loopback"
}

pcm.loopback {
    type hw
    card 1
    device 0
}
EOL
fi

# Restart PulseAudio if not already running
if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --start
fi

# Start Bluetooth service if not already running
if ! systemctl is-active --quiet bluetooth; then
    sudo systemctl start bluetooth
fi

echo "Setting up Bluetooth..."

# Explicitly set up the Bluetooth agent
bluetoothctl <<EOF
power on
agent KeyboardDisplay
default-agent
discoverable on
pairable on
EOF

echo "Bluetooth is now discoverable. Pair your phone and connect it as an audio device."
echo "Waiting for connection..."

# Wait for a Bluetooth audio source connection
while ! pactl list sources | grep -q "bluez_source"; do
    sleep 2
done

echo "Bluetooth device connected."

# Ask the user for the FM frequency
read -p "Enter the FM frequency you want to transmit (e.g., 100.6): " FM_FREQ

# Start FM transmitter
echo "Starting FM transmitter on $FM_FREQ MHz..."
echo "Use Ctrl+C to stop."
arecord -D hw:1,1,0 -c 1 -d 0 -r 22050 -f S16_LE | sudo ./fm_transmitter -f $FM_FREQ - &

# Wait for Ctrl+C to clean up
wait
