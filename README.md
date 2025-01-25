
Raspi-FM
=========

Raspi-FM is a lightweight and user-friendly FM transmitter project designed for Raspberry Pi devices. This project allows you to broadcast audio over FM frequencies using a simple web interface accessible through a Wi-Fi access point. It is based on the [fm_transmitter](https://github.com/markondej/fm_transmitter) app made by [markondej](https://github.com/markondej/) that makes it possible to broadcast FM audio signal.




Overview
--------

The project includes:
- A Flask-based web application for controlling the FM transmitter.
- Scripts to set up a Wi-Fi access point for easy connection.
- Systemd services for seamless startup and management.
- Audio file playback, frequency management, and other utilities.

# the rest of the readme is for prepared for future: the install script and command line usage isn't working yet, but you can try it using cloning this repo for now. 


Features
--------
1. **Web Interface**: Control the FM transmitter via a browser by connecting to the Wi-Fi AP and accessing `http://192.168.4.1:5000`.
2. **Audio Playback**: Select audio files to play on the FM transmitter.
3. **Custom Frequency**: Set the desired FM frequency for broadcasting.
4. **Easy Setup**: A single bash installer handles all dependencies and configuration.
5. **Command-Line Utility**: Use commands like `raspifm start` and `raspifm stop` to manage the transmitter easily.

Installation
------------

1. Download and run the installer script:
   ```
   curl -fsSL https://github.com/yourusername/raspi-fm/install.sh | sh
   ```
2. Follow the on-screen prompts to complete the setup.
3. After installation, connect to the "Raspi-FM" Wi-Fi network and navigate to `http://192.168.4.1:5000` in your browser.

Usage
-----

### Commands
The following commands are available after installation:
- `raspifm start` - Starts the FM transmitter and web app.
- `raspifm stop` - Stops the FM transmitter and web app.
- `raspifm status` - Checks the status of the transmitter.
- `raspifm configure` - Reconfigures Wi-Fi settings or audio file directories.

### Systemd Services
- `raspifm-web.service`: Manages the Flask web app.
- `raspifm-ap.service`: Handles the Wi-Fi access point setup.

### Adding Audio Files
Place your audio files in the `audio_files/` directory located in the project folder. You can also upload it using the web UI.




## License
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
This project is licensed under the [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/). 

You are free to:
- **Share** — copy and redistribute the material in any medium or format.

Under the following terms:
- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- **NonCommercial** — You may not use the material for commercial purposes.
- **NoDerivatives** — If you remix, transform, or build upon the material, you may not distribute the modified material.


