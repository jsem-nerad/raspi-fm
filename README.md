
Raspi-FM
=========

Raspi-FM is a lightweight and user-friendly FM transmitter project. This project allows you to broadcast audio over FM frequencies using a simple web interface accessible through a Wi-Fi access point. It is based on the [fm_transmitter](https://github.com/markondej/fm_transmitter) app made by [markondej](https://github.com/markondej/) that makes it possible to broadcast FM audio signal.




Overview
--------

The project includes:
- A Flask-based web application for controlling the FM transmitter.
- Scripts to set up a Wi-Fi access point for easy connection.
- Systemd services for seamless startup and management.
- Audio file playback, frequency management, and other utilities.
- All Prague FM stations list (I want to add custom stations list option)


Features
--------
1. **Web Interface**: Control the FM transmitter via a browser by connecting to the Wi-Fi AP and accessing `http://192.168.4.1:5000`.
2. **Audio Playback**: Select audio files to play on the FM transmitter.
3. **Custom Frequency**: Set the desired FM frequency for broadcasting.
4. **Predefined Stations**: Choose from a list of all Prague FM stations

To-Do
-------

- [ ] Bash installer script
- [ ] Broadcast start timer
- [ ] Custom stations list
- [ ] Phone bluetooth audio stream (this will be hard)
- [ ] Existing audio files managment (renaming, deleting)




### Systemd Services
- `raspifm-app.service`: Manages the Flask web app.
- `raspifm-wifi.service`: Handles the Wi-Fi access point setup.

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


