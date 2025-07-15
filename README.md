# Behavault – Behavioral Anomaly Detection System 🔐

Behavault is a cross-platform system that detects suspicious user behavior in real-time using behavioral biometrics. Built with **Flutter (frontend SDK)** and **FastAPI (backend)** powered by **Isolation Forest**, it tracks user interactions like keystrokes, touches, motion, navigation, and location to determine anomalies.

---

## 🏗️ Project Structure

behavault/
├── backend/ # FastAPI backend + ML model + Streamlit dashboard
│ ├── main.py # FastAPI app with /predict endpoint
│ ├── model.pkl # Trained Isolation Forest model
│ ├── logger.py # Logs incoming predictions to CSV
│ ├── dashboard.py # Streamlit dashboard to monitor anomalies
│ └── data/session_logs.csv
├── frontend/ # Flutter SDK for capturing user behavior
│ ├── lib/
│ ├── pubspec.yaml
│ └── ...
└── README.md


---

## 🚀 Features

### ✅ Flutter Frontend (SDK)
- Captures:
  - Keystroke timing
  - Touch events (down/up)
  - Device motion
  - Navigation routes
  - Geolocation
- Sends behavioral data to backend for prediction
- Shows in-app alerts based on severity

### ⚙️ FastAPI Backend
- Receives `features = [keystroke_count, motion_count, touch_count, location_flag, navigation_count]`
- Returns:
  ```json
  {
    "anomalous": true,
    "score": -0.65,
    "severity": "medium"
  }
📊 Streamlit Admin Dashboard
Session Logs Table – Timestamp, anomaly score, severity

Bar Charts & Heatmaps – Visualize behavior features

Flagged Sessions – Medium & high severity

Behavioral Drift – Time series of anomaly scores

Model Explainability – View score distribution and thresholds

🧪 How it Works
Flutter app collects real-time user behavior.

Sends data to /predict endpoint.

Backend evaluates the behavior using Isolation Forest.

Response severity guides app actions (lock out, warn, restrict).

Session logs are saved and visualized in a dashboard.

🔧 Backend Setup
bash
Copy
Edit
cd backend/
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
Visit: http://localhost:8000/docs for Swagger UI

Optional: To launch dashboard

streamlit run dashboard.py
💖 Flutter Frontend Setup

cd example/
flutter clean
flutter pub get
flutter run

ML Model Training (Optional)
You can retrain the Isolation Forest using your own dataset.

Save as model.pkl in the backend folder.

📦 Requirements
Backend
fastapi

uvicorn

scikit-learn

pandas

streamlit

plotly, matplotlib, seaborn

Install with:
pip install fastapi uvicorn scikit-learn pandas streamlit plotly matplotlib seaborn
Frontend
Flutter 3.0+

http, geolocator, sensors_plus, flutter_hooks etc.

🌟 Future Scope
SHAP-based model explainability

Session replay visualization

Role-based access control for admin panel

