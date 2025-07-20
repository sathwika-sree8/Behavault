from flask import Flask, request, jsonify
import csv
import os
import json
from datetime import datetime
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
LOG_FILE = 'session_logs.csv'
BEHAVIOR_DATA_FILE = 'behavior_data.json'

def log_session(data):
    file_exists = os.path.isfile(LOG_FILE)
    with open(LOG_FILE, mode='a', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=data.keys())
        if not file_exists:
            writer.writeheader()
        writer.writerow(data)

def analyze_features(data):
    # Pick only numerical values from data for scoring
    features = [v for v in data.values() if isinstance(v, (int, float))]
    score = sum(features)
    if score > 40:
        return "high"
    elif score > 20:
        return "medium"
    else:
        return "low"

def notify_admin(severity, data):
    # Placeholder for admin notification logic
    print(f"Admin notified: Severity {severity} detected for session: {data}")

@app.route('/predict', methods=['POST'])
def predict():
    content = request.json

    # Load existing data or start with empty list
    if os.path.exists(BEHAVIOR_DATA_FILE):
        with open(BEHAVIOR_DATA_FILE, 'r') as f:
            try:
                existing_data = json.load(f)
                if not isinstance(existing_data, list):
                    existing_data = [existing_data]
            except json.JSONDecodeError:
                existing_data = []
    else:
        existing_data = []

    # Add timestamp to the new entry
    content_with_time = {
        'timestamp': datetime.utcnow().isoformat(),
        **content
    }

    # Append and write back
    existing_data.append(content_with_time)
    with open(BEHAVIOR_DATA_FILE, 'w') as f:
        json.dump(existing_data, f, indent=2)

    # Your analysis and response logic continues...
    severity = analyze_features(content)
    log_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'severity': severity,
        'features': str(content)
    }
    log_session(log_data)

    if severity in ['medium', 'high']:
        notify_admin(severity, log_data)

    return jsonify({'anomaly': severity})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000, debug=True)
