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

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo "[INFO] Git is not installed. Installing it now..."
    sudo apt install -y git
    if ! command -v git &> /dev/null; then
        echo "[ERROR] Failed to install git. Please install it manually and rerun the installer."
        exit 1
    fi
fi

if ! command -v dnsmasq &> /dev/null; then
  sudo apt install -y dnsmasq
fi
if ! command -v hostapd &> /dev/null; then
  sudo apt install -y hostapd
fi

chmod +x "$INSTALL_DIR/scripts/setup_ap.sh"


# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
  log "Directory $INSTALL_DIR already exists. Pulling latest changes."
  git -C "$INSTALL_DIR" pull
else
  log "Cloning the repository into $INSTALL_DIR."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

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

# Install Python dependencies
log "Installing Python dependencies."
if ! command -v python3 &> /dev/null; then
  sudo apt install -y python3
fi

if ! command -v pip3 &> /dev/null; then
  log "pip3 not found. Installing..."
  sudo apt install -y python3-pip
fi


# Create a Python virtual environment
echo "Creating Python virtual environment in $INSTALL_DIR..."
if command -v python3 >/dev/null 2>&1; then
    python3 -m venv "$INSTALL_DIR"
    echo "Virtual environment created successfully."

    # Activate the virtual environment
    source "$INSTALL_DIR/venv/bin/activate"

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
read -p "Do you want to start and enable the Raspifm services? [y/N]: " START_SERVICES
if [[ "$START_SERVICES" =~ ^[Yy]$ ]]; then
  log "Starting and enabling raspifm.service."
  systemctl start raspifm-app.service
  systemctl enable raspifm-app.service

  log "Starting and enabling raspifm_wifi.service."
  systemctl start raspifm-wifi.service
  systemctl enable raspifm-wifi.service
else
  log "Skipping service startup. You can start them manually with systemctl commands."
fi

# Clean-up and final message
log "Installation complete."
cat <<EOF

========================================
Raspifm has been successfully installed!

You can use the following commands to manage the services:
  - Start the app:     sudo systemctl start raspifm.service
  - Stop the app:      sudo systemctl stop raspifm.service
  - Enable on boot:    sudo systemctl enable raspifm.service

Access the web interface at: http://<your-pi-ip>:5000
========================================

EOF
