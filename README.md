# Behavior Tracker SDK 

This project demonstrates the usage of the Behavior Tracker SDK in a Flutter application, along with a backend service and an admin dashboard for behavioral analytics and anomaly detection.

## Project Directory Structure

```
behavior_tracker_sdk/
├── app/
│   └── model/
│       ├── train_model.py          # Script to train Isolation Forest model
│       └── predict.py              # Script to predict anomaly using trained model
├── behavault_backend/
│   ├── app.py                     # Flask backend API server
│   └── session_logs.csv           # CSV log of session data
├── behavault_dashboard/
│   └── app.py                     # Streamlit dashboard for visualization
├── example/
│   ├── lib/
│   │   └── main.dart              # Flutter example app main code
│   ├── pubspec.yaml               # Flutter dependencies
│   └── README.md                  # This README file
├── lib/
│   └── behavior_tracker_sdk.dart  # SDK main entry point
│   └── src/                      # SDK source code files
└── pubspec.yaml                  # Root Flutter project dependencies
```

## System Architecture Overview

```
+-------------------+       +-------------------+       +-----------------------+
|                   |       |                   |       |                       |
|  Flutter Example   | ----> |  Backend API      | ----> |  Anomaly Detection    |
|  App (SDK)         |       |  (Flask Server)   |       |  Model (Isolation     |
|                   |       |                   |       |  Forest)              |
+-------------------+       +-------------------+       +-----------------------+
         |                          |                             |
         |                          |                             |
         v                          v                             v
+-------------------+       +-------------------+       +-----------------------+
|                   |       |                   |       |                       |
| Behavioral Data    |       | Session Logs CSV  |       | Prediction Script     |
| Collection &       |       | & JSON Storage    |       |                       |
| Export             |       |                   |       |                       |
+-------------------+       +-------------------+       +-----------------------+
                                                         |
                                                         v
                                              +-----------------------+
                                              |                       |
                                              | Admin Dashboard       |
                                              | (Streamlit Visualizer)|
                                              |                       |
                                              +-----------------------+
```

- The Flutter app collects behavioral data using the SDK and sends it to the backend API.
- The backend stores raw data and session logs, and uses the trained Isolation Forest model to detect anomalies.
- The prediction script loads the model and classifies new data.
- The admin dashboard visualizes session logs, anomaly scores, and feature contributions.

## Technologies Used

- **Flutter**: Mobile and web app development framework.
- **Dart**: Programming language for Flutter.
- **Flask**: Python web framework for backend API.
- **Python**: Backend logic, model training, and prediction.
- **Scikit-learn**: Machine learning library for Isolation Forest model.
- **Joblib**: Model serialization.
- **Streamlit**: Dashboard and data visualization.
- **Plotly & Matplotlib**: Visualization libraries.
- **Pandas**: Data manipulation and analysis.
- **HTTP**: Communication between Flutter app and backend API.

## Features

- **Flutter Example App**
  - Collects behavioral data such as keystrokes, touch events, geolocation, navigation events.
  - Requests user consent before data collection.
  - Exports collected data as JSON and saves locally.
  - Sends behavioral data to backend API for analysis.
  - Reacts to anomaly detection results by restricting access or requiring re-authentication.

- **Backend API (Flask)**
  - Receives behavioral data JSON via `/predict` POST endpoint.
  - Logs session data to CSV and appends raw data to JSON file.
  - Analyzes features to detect anomaly severity (low, medium, high).
  - Notifies admin on medium or high severity anomalies.

- **Anomaly Detection Model**
  - Isolation Forest model trained on session logs.
  - Model and scaler saved for prediction.
  - Prediction script to classify new behavioral data as anomaly or normal.

- **Admin Dashboard (Streamlit)**
  - Visualizes session logs with timestamps, severity, and anomaly flags.
  - Displays flagged sessions with medium and high severity.
  - Shows anomaly score distributions and behavioral drift over time.
  - Visualizes feature contributions to anomalies.

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.x
- Required Python packages: Flask, Flask-CORS, pandas, scikit-learn, joblib, streamlit, plotly, matplotlib

### Running the Flutter Example App

1. Navigate to the `example` directory.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run -d chrome` to launch the app in Chrome.
4. Use the app to collect behavioral data and send it to the backend.

### Running the Backend API

1. Navigate to the `behavault_backend` directory.
2. Install Python dependencies: `pip install -r requirements.txt` (create this file if needed).
3. Run the backend server: `python app.py`.
4. The backend listens on port 8000 and exposes the `/predict` endpoint.

### Training the Anomaly Detection Model

1. Navigate to the `app/model` directory.
2. Run `python train_model.py` to train and save the Isolation Forest model.

### Using the Prediction Script

1. Use `predict.py` to load the saved model and scaler.
2. Call `predict_anomaly(features)` with a feature vector to get anomaly prediction.

### Running the Admin Dashboard

1. Navigate to the `behavault_dashboard` directory.
2. Run `streamlit run app.py` to launch the dashboard.
3. Visualize behavioral analytics and anomaly detection results.

## Notes

- Ensure `behavior_data.json` and `session_logs.csv` are properly populated by the backend for accurate dashboard visualization.
- Customize the SDK and backend as needed for your application requirements.
- The project is designed to respect user privacy by collecting behavioral data only after consent.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Scikit-learn Isolation Forest](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html)
