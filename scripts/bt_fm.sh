#!/bin/bash

cleanup() {
    echo -e "\nCleaning up..."
    sudo systemctl stop bluetooth
    sudo modprobe -r snd-aloop
    pulseaudio --kill
    echo "Bluetooth and loopback device stopped."
    exit 0
}

trap cleanup SIGINT

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

echo "Checking and installing dependencies if needed..."
if ! dpkg -l | grep -q pulseaudio; then
    sudo apt update && sudo apt install -y pulseaudio pulseaudio-module-bluetooth bluez-tools sox libsox-fmt-mp3
fi

if ! lsmod | grep -q snd_aloop; then
    echo "Loading snd-aloop module..."
    sudo modprobe snd-aloop
    echo "snd-aloop" | sudo tee -a /etc/modules
fi

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

if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --start
fi

if ! systemctl is-active --quiet bluetooth; then
    sudo systemctl start bluetooth
fi

echo "Setting up Bluetooth..."

bluetoothctl <<EOF
power on
agent KeyboardDisplay
default-agent
discoverable on
pairable on
EOF

echo "Bluetooth is now discoverable. Pair your phone and connect it as an audio device."
echo "Waiting for connection..."
while ! pactl list sources | grep -q "bluez_source"; do
    sleep 2
done

echo "Bluetooth device connected."

read -p "Enter the FM frequency you want to transmit (e.g., 100.6): " FM_FREQ

echo "Starting FM transmitter on $FM_FREQ MHz..."
echo "Use Ctrl+C to stop."
arecord -D hw:1,1,0 -c 1 -d 0 -r 22050 -f S16_LE | sudo ./fm_transmitter -f $FM_FREQ - &

wait
