<h1 align="center" style="font-size: 40px">Raspi-FM</h1>


  <p align="center">
    <img src="https://raw.githubusercontent.com/jsem-nerad/raspi-fm/refs/heads/main/images/logo.png" style="width: 30%; height: auto;">
    <br />
    FM Transmitter Web UI and Controls Built with Python and Bash
    <br />
    <br />
    <a href="https://github.com/jsem-nerad/raspi-fm/issues/new?labels=bug&template=bug-report---.md">Report a Bug</a>
    ·
    <a href="https://github.com/jsem-nerad/raspi-fm/issues/new?labels=enhancement&template=feature-request---.md">Request a Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about">About</a></li>
    <li>
      <a href="#features">Features</a>
    </li>
    <li>
      <a href="#installation">Installation</a>
    </li>
    <li><a href="#supported-devices">Supported devices</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#to-do">To-Do</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>


# About

Raspi-FM is a lightweight and user-friendly FM transmitter project based on the [fm_transmitter](https://github.com/markondej/fm_transmitter) app made by [markondej](https://github.com/markondej/) that makes it possible to broadcast an FM audio signal.


# Features

1. **Web Interface**: Control the FM transmitter via a browser by connecting to the Wi-Fi AP and accessing `http://192.168.4.1:5000`.
2. **Audio Playback**: Select audio files to play on the FM transmitter.
3. **Custom Frequency**: Set the desired FM frequency for broadcasting.
4. **Predefined Stations**: Choose from a list of all Prague FM stations (I want to add custom stations list option)


<img src="https://raw.githubusercontent.com/jsem-nerad/raspi-fm/refs/heads/main/images/webapp.png" style="width: 400px; height: auto;">



# Installation
> The installation process can take over 15 minutes, so please be patient.

To install Raspi-FM, run the following command on your Raspberry Pi::
```bash
curl -fsSL https://raw.githubusercontent.com/jsem-nerad/raspi-fm/refs/heads/main/install.sh | sudo bash
```



### Supported devices
I tested this only on my Pi Zero W, but it should work on most Raspberry Pi models with Wi-Fi, except the Pi 5 and Pi 4.

<br>
<br>


# Usage
After successful installation:
1. Connect to the Pi using WiFi. You should see the SSID raspi-fm, which you can connect to using the password flipfmsignal.
2. Then open your web browser and go to its default IP address on port 5000: http://192.168.4.1:5000 
3. If you experience issues connecting to Wi-Fi or accessing its IP address, try turning off your mobile data (if you are using a phone) and/or disabling auto-connect for known nearby Wi-Fi networks.
4. Now you can choose a frequency, select an audio file, and click 'Start Transmission'.

<br>

## Command control
The general syntax for command control is as follows:
```bash
raspifm [service] <command>
```

## Services
You can manage the following services:

- `app` - Controls the web UI application.
- `wifi` - Controls the Wi-Fi access point.

## Commands
You can use the following commands alone or specify a service:
| Command   | Description                                                                 |
|-----------|-----------------------------------------------------------------------------|
| `status`    | Show the status of all services.                                           |
| `start`     | Start the specified service(s).                                            |
| `stop`      | Stop the specified service(s).                                             |
| `enable`    | Enable the specified service(s) to start automatically at system startup.  |
| `disable`   | Disable the specified service(s) from starting automatically at system startup. |
| `restart`   | Restart the specified service(s) by stopping and starting them.                  |



## Additional Commands
| Command          | Description                                        | Example Usage                              |
|------------------|----------------------------------------------------|-------------------------------------------|
| `wifi password`  | Set a new password for the Wi-Fi access point.     | `raspifm wifi password <new_password>`    |
| `wifi ssid`      | Set a new SSID (network name) for the Wi-Fi access point. | `raspifm wifi ssid <new_ssid>`           |
| `config`         | Open the config.ini file for manual configuration. | `raspifm config`                          |


#### Or you can just type `raspifm` to get hint

<img src="https://raw.githubusercontent.com/jsem-nerad/raspi-fm/refs/heads/main/images/screenshot.png" style="width: 80%; height: auto;">

<br>
<br>
<br>


# To-Do

- [x] Bash installer script
- [ ] Broadcast start timer
- [ ] Custom stations list
- [ ] Phone bluetooth audio stream (this will be hard)
- [ ] Existing audio file management (renaming, deleting)


<br>
<br>
<br>


---

# How does it work?

If you're interested, here's an overview of how this project works.


## Files
```
Raspi-FM                           - Main app directory - on default /opt/raspifm
├── app
│   ├── static
│   │   └── styles.css             - Web ui CSS
│   ├── templates
│   │   └── index.html             - Web ui HTML
│   ├── app.py                     - Main flask app - the web ui
│   ├── fm_transmitter             - App for transmitting audio files using FM
│   ├── fm_transmitter.py          - My custom library for controling the fm_transmitter app
│   └── stations.json              - List of stations with frequencies
├── audio_files                    - Directory for audio files
│   └── ...
├── scripts
│   ├── setup_ap.sh                - Script to start the access point
│   └── stop_ap.sh                 - Script to stop the access point
├── systemd
│   ├── raspifm-app.service        - Systemd service that starts app.py in Python venv
│   └── raspifm-wifi.service       - Systemd service that starts the access point using setup_ap.sh
├── config.ini                     - Configuration file
├── install.sh
├── raspifm                        - The shell file for interacting using command line
└── requirements.txt               - Python library requirements
```

<br>

## Installation

To make raspi-fm work properly, there needs to be quite a lot of things installed on the system and also some files placed in different locations of the system, so that is why I made a separate application for installing, rather than telling you to just clone the repo.

The installer code gets read from the GitHub repo and then gets executed using bash with sudo:

`curl -fsSL https://...../install.sh | sudo bash`

When the install.sh script is executed, the following steps occur:"
1. Check if it was executed using sudo
2. Update using `apt update`
3. Install the following packages:
   
| Package            | Reason |
|--------------------|-------------|
| dnsmasq           | WiFi AP  |
| hostapd           | WiFi AP |
| git               | Cloning this repo  |
| python3           | Web-UI |
| python3-pip       | Python packages  |
| libraspberrypi-dev| fm_transmiter |
| sox               | Convert audio |
| libsox-fmt-mp3    | Convert audio |

4. Clone this repository to /opt/raspifm
5. Copy service files to /etc/systemd/system
6. Add the `raspifm` command to PATH
7. Make some files executable
8. Create a Python venv
9. Install Python libraries from `requirements.txt`
10. Enable and start the raspi-fm services.

And that's it. This whole install process usually takes over 15 minutes on my Pi Zero W with a slow network connection.

<br>

## Scripts

Right now, there are 2 bash scripts that are actively being used - it is the `setup_ap.sh` and `stop_ap.sh` and as the names suggests, those scripts are being used to turn the WiFi access point on and off. 

### `setup_ap.sh`
This script uses `dnsmasq` and `hostapd` to host a WiFi access point, so your device can connect to your Raspberry Pi via Wi-Fi. The access point is hosted on interface `wlan1` that is made on top of standard `wlan0` used for connecting to WiFi. It is using the `config.ini` to set the SSID and password of the access point. DHCP is used to assign IP's to connected devices and its range is from `192.168.4.2` to `192.168.4.20` and the IP of the Pi itself is `192.168.4.1`.

### `stop_ap.sh`
Basically all this does is, that it just reverts all the changes of `setup_ap.sh`, so for example it removes `wlan1` interface, restores original hostapd config file, stops hostapd and dnsmasq...

## Python code

There are two Python files in my project - `app.py` and `fm_transmitter.py`. Those files are ran in a Python venv, so it doesn't interfere with the system Python installation.

### `fm_transmitter.py`

This is my custom made Python library used to control the fm_transmitter app. 



### `app.py`

This is the main app, that is running in the background to serve the web-ui controls. On default, it uses port 5000 to serve the website, so it doesn't colide with ports you may have opened before, but you can change that on the bottom of the code to any port you want.

---

<br>
<br>

# ⚠️ Legal Disclaimer ⚠️
This application is developed solely for educational purposes to demonstrate technical concepts. Using this application to broadcast FM radio signals is illegal in many countries, including the Czech Republic, without proper licensing and authorization. The author does not condone or encourage any unlawful use of this software.
By using this repository, you agree that you are solely responsible for ensuring compliance with all applicable laws and regulations in your jurisdiction. The author assumes no liability for any misuse or legal consequences resulting from the use of this software. This disclaimer makes it clear that the project is intended for learning only and warns users about the legal implications of misuse.


# License
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
This project is licensed under the [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/). 

You are free to:
- **Share** — copy and redistribute the material in any medium or format.

Under the following terms:
- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- **NonCommercial** — You may not use the material for commercial purposes.
- **NoDerivatives** — If you remix, transform, or build upon the material, you may not distribute the modified material.



