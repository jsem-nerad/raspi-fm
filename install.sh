#!/bin/bash

set -e

REPO_URL="https://github.com/vojtikDortik/raspi-fm.git"
INSTALL_DIR="/opt/raspifm"
SERVICE_DIR="/etc/systemd/system"
COMMAND_PATH="/usr/local/bin/raspifm"
LOG_FILE="/var/log/raspifm_installer.log"

log() {
  echo "[INFO] $1" | tee -a "$LOG_FILE"
}

error_exit() {
  echo "[ERROR] $1" >&2 | tee -a "$LOG_FILE"
  exit 1
}

# Check for root permissions
if [ "$EUID" -ne 0 ]; then error_exit "Script must be run as root."; fi

log "Starting Raspifm installer."

# Update and install dependencies in parallel where possible
apt update &
wait
apt install -y dnsmasq hostapd git python3 python3-pip libraspberrypi-dev sox libsox-fmt-mp3 &
wait

# Clone or update repository efficiently
if [ -d "$INSTALL_DIR" ]; then
  log "Directory $INSTALL_DIR exists. Checking for updates."
  git -C "$INSTALL_DIR" fetch && git -C "$INSTALL_DIR" pull || error_exit "Failed to update repository."
else
  log "Cloning repository into $INSTALL_DIR."
  git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || error_exit "Failed to clone repository."
fi

# Copy and set up systemd services if not already configured
for service in raspifm-app raspifm-wifi; do
  cp "$INSTALL_DIR/systemd/${service}.service" "$SERVICE_DIR/"
  chmod 644 "$SERVICE_DIR/${service}.service"
done

log "Reloading systemd daemon."
systemctl daemon-reload

# Install Python virtual environment and dependencies efficiently
if [ ! -d "$INSTALL_DIR/bin" ]; then python3 -m venv "$INSTALL_DIR"; fi

source "$INSTALL_DIR/bin/activate"
pip3 install --no-cache-dir --upgrade pip setuptools wheel &&
pip3 install --no-cache-dir -r "$INSTALL_DIR/requirements.txt" || error_exit "Failed to install Python dependencies."
deactivate

# Start and enable services only if necessary
for service in raspifm-app raspifm-wifi; do
  systemctl is-active --quiet ${service}.service || systemctl start ${service}.service
  systemctl is-enabled --quiet ${service}.service || systemctl enable ${service}.service
done

log "Installation complete!"
