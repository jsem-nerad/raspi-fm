#!/bin/bash

set -e  # Exit on error

REPO_URL="https://github.com/vojtikDortik/raspi-fm.git"
INSTALL_DIR="/opt/raspifm"
SERVICE_DIR="/etc/systemd/system"
COMMAND_PATH="/usr/local/bin/raspifm"
LOG_FILE="/var/log/raspifm_installer.log"

log() {
  echo "[INFO] $1" | tee -a "$LOG_FILE"
}

error_exit() {
  echo "[ERROR] $1" >&2
  exit 1
}

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
  error_exit "This script must be run as root. Please use sudo."
fi

log "Starting Raspifm installer."

sudo apt update
sudo apt install -y dnsmasq hostapd git python3 python3-pip libraspberrypi-dev sox libsox-fmt-mp3

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo "[INFO] Git is not installed. Installing it now..."
    sudo apt install -y git
    if ! command -v git &> /dev/null; then
        echo "[ERROR] Failed to install git. Please install it manually and rerun the installer."
        exit 1
    fi
fi




# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
  log "Directory $INSTALL_DIR already exists. Trying to pull the latest changes."
  git -C "$INSTALL_DIR" pull
else
  log "Cloning the repository into $INSTALL_DIR."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi


chmod +x "$INSTALL_DIR/scripts/setup_ap.sh"
# Move systemd service files
log "Copying systemd service files."
cp "$INSTALL_DIR/systemd/raspifm-app.service" "$SERVICE_DIR"
cp "$INSTALL_DIR/systemd/raspifm-wifi.service" "$SERVICE_DIR"
chmod 644 "$SERVICE_DIR/raspifm-app.service" "$SERVICE_DIR/raspifm-wifi.service"

log "Reloading systemd daemon."
systemctl daemon-reload

# Move raspifm shell script to /usr/local/bin
log "Installing raspifm command."
cp "$INSTALL_DIR/raspifm" "$COMMAND_PATH"
chmod +x "$COMMAND_PATH"


# Create a Python virtual environment
echo "Creating Python virtual environment in $INSTALL_DIR..."
if command -v python3 >/dev/null 2>&1; then
    python3 -m venv "$INSTALL_DIR"
    echo "Virtual environment created successfully."

    # Activate the virtual environment
    source "$INSTALL_DIR/bin/activate"

    # Install Python dependencies
    echo "Installing Python dependencies..."
    pip3 install -r "$INSTALL_DIR/requirements.txt"

    # Deactivate the virtual environment
    deactivate
    echo "Python dependencies installed and virtual environment setup complete."
else
    echo "Python3 is not installed. Please install Python3 and rerun the installer."
    exit 1
fi





# Prompt user to start and enable services

echo "Starting and enabling raspifm.service."
systemctl start raspifm-app.service
systemctl enable raspifm-app.service

echo "Starting and enabling raspifm_wifi.service."
systemctl start raspifm-wifi.service
systemctl enable raspifm-wifi.service


# Clean-up and final message
echo "Installation complete."
cat <<EOF

========================================
Raspifm has been successfully installed!

You can use the following commands to manage the services:
  - Start the app:     sudo systemctl start raspifm-app.service
  - Stop the app:      sudo systemctl stop raspifm-app.service
  - Enable on boot:    sudo systemctl enable raspifm-app.service
  - Disable on boot:   sudo systemctl disable raspifm-app.service

Access the web interface at: http://<your-pi-ip>:5000
If connected to raspi-fm wifi: http://192.168.4.1:5000
========================================

EOF
