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
cp "$INSTALL_DIR/services/raspifm.service" "$SERVICE_DIR"
cp "$INSTALL_DIR/services/raspifm_wifi.service" "$SERVICE_DIR"
chmod 644 "$SERVICE_DIR/raspifm.service" "$SERVICE_DIR/raspifm_wifi.service"

log "Reloading systemd daemon."
systemctl daemon-reload

# Move raspifm shell script to /usr/local/bin
log "Installing raspifm command."
cp "$INSTALL_DIR/raspifm.sh" "$COMMAND_PATH"
chmod +x "$COMMAND_PATH"

# Install Python dependencies
log "Installing Python dependencies."
if ! command -v python3 &> /dev/null; then
  error_exit "Python3 is not installed. Please install Python3 and re-run the installer."
fi

if ! command -v pip3 &> /dev/null; then
  log "pip3 not found. Installing..."
  apt update && apt install -y python3-pip
fi

pip3 install -r "$INSTALL_DIR/requirements.txt"

# Prompt user to start and enable services
read -p "Do you want to start and enable the Raspifm services? [y/N]: " START_SERVICES
if [[ "$START_SERVICES" =~ ^[Yy]$ ]]; then
  log "Starting and enabling raspifm.service."
  systemctl start raspifm.service
  systemctl enable raspifm.service

  log "Starting and enabling raspifm_wifi.service."
  systemctl start raspifm_wifi.service
  systemctl enable raspifm_wifi.service
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
