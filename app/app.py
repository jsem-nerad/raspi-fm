from flask import Flask, render_template, request, jsonify
from fm_transmitter import FM_Transmitter
import os
from werkzeug.utils import secure_filename
import subprocess
import tempfile

app = Flask(__name__)

app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = 'audio_files'

# Ensure the upload folder exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)



# Initialize FM_Transmitter instance
fm = FM_Transmitter()


ALLOWED_EXTENSIONS = {'wav', 'mp3'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def convert_to_wav(input_path, output_path):
    """Convert audio file to WAV format using sox with specific parameters"""
    try:
        subprocess.run([
            'sox',
            input_path,
            '-r', '22050',  # Sample rate
            '-c', '1',      # Channels (mono)
            '-b', '16',     # Bit depth
            '-t', 'wav',    # Output format
            output_path
        ], check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Conversion error: {e.stderr.decode()}")
        return False
    except Exception as e:
        print(f"Unexpected error during conversion: {e}")
        return False

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'message': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'message': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        original_ext = filename.rsplit('.', 1)[1].lower()
        wav_filename = filename.rsplit('.', 1)[0] + '.wav'
        wav_path = os.path.join(app.config['UPLOAD_FOLDER'], wav_filename)
        
        try:
            if original_ext == 'mp3':
                # Save the uploaded MP3 to a temporary file
                with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_file:
                    file.save(temp_file.name)
                    # Convert the MP3 to WAV
                    if not convert_to_wav(temp_file.name, wav_path):
                        os.unlink(temp_file.name)
                        return jsonify({'message': 'Error converting MP3 to WAV'}), 500
                    os.unlink(temp_file.name)
            else:  # WAV file
                file.save(wav_path)
            
            return jsonify({'message': f'File uploaded and converted successfully as {wav_filename}'}), 200
        
        except Exception as e:
            return jsonify({'message': f'Error processing file: {str(e)}'}), 500
    else:
        return jsonify({'message': 'Invalid file type. Only .wav and .mp3 files are allowed'}), 400





@app.route('/start', methods=['POST'])
def start():
    data = request.json

    audio_file = data.get('audio_file')

    if not audio_file:
        return jsonify({'message': "Error: No audio file selected."}), 400

    file_path = os.path.join(fm.audio_folder, audio_file)





    frequency = data.get('frequency')
    if not frequency:
        station_name = data.get('station')
        stations = fm.load_stations()
        station = next((s for s in stations if s['name'] == station_name), None)

        if not station:
            return jsonify({'message': f"Error: Station '{station_name}' not found."}), 400

        frequency = station['frequency']
    message, status = fm.play_audio(file_path, frequency)
    return jsonify({'message': message}), status

@app.route('/stop', methods=['POST'])
def stop():
    message, status = fm.stop_audio()
    return jsonify({'message': message}), status

@app.route('/')
def home():
    stations = fm.load_stations()
    audio_files = fm.scan_audio_files()
    return render_template('index.html', stations=stations, audio_files=audio_files)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

