import os
import json
import subprocess
import signal
import threading
import wave


class FM_Transmitter:
    def __init__(self, stations_file="stations.json", audio_folder="../audio_files"):
        self.stations_file = stations_file
        self.audio_folder = audio_folder
        self.fm_process = None
        self.lock = threading.Lock()

    def load_stations(self):
        """Load stations from the stations JSON file."""
        if not os.path.exists(self.stations_file):
            return []
        with open(self.stations_file, 'r') as f:
            data = json.load(f)
            return data.get("stations", [])

    def scan_audio_files(self):
        """Scan the audio folder for .wav files and return their details."""
        if not os.path.exists(self.audio_folder):
            os.makedirs(self.audio_folder)  # Create folder if it doesn't exist

        audio_files = []
        for file_name in os.listdir(self.audio_folder):
            if file_name.endswith(".wav"):
                file_path = os.path.join(self.audio_folder, file_name)
                try:
                    # Get file size and duration
                    file_size = os.path.getsize(file_path) / (1024 * 1024)
                    with wave.open(file_path, 'r') as wav_file:
                        duration = wav_file.getnframes() / float(wav_file.getframerate())
                    minutes, seconds = divmod(int(duration), 60)
                    formatted_duration = f"{minutes}:{seconds:02}"
                    audio_files.append({
                        "name": file_name,
                        "size": f"{file_size:.2f} MB",
                        "duration": formatted_duration
                    })
                except Exception as e:
                    print(f"Error processing {file_name}: {e}")
        return audio_files

    def play_audio(self, file_path, frequency):
        """Start transmitting audio on a given frequency."""
        if not os.path.exists(file_path):
            return "Error: Audio file not found.", 400

        command = f"sudo ./fm_transmitter/fm_transmitter -f {frequency} {file_path} -r"
        try:
            with self.lock:
                if self.fm_process is None:
                    self.fm_process = subprocess.Popen(
                        command, shell=True, preexec_fn=os.setsid
                    )
                    return f"Started transmitting on {frequency} MHz.", 200
                else:
                    return "Error: Transmission already in progress.", 400
        except Exception as e:
            return f"Unexpected error: {e}", 500

    def stop_audio(self):
        """Stop the current audio transmission."""
        with self.lock:
            if self.fm_process is not None:
                try:
                    os.killpg(os.getpgid(self.fm_process.pid), signal.SIGTERM)
                    self.fm_process = None
                    return "Transmission stopped.", 200
                except Exception as e:
                    return f"Error stopping transmission: {e}", 500
            else:
                return "Error: No active transmission to stop.", 400
