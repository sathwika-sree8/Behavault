import joblib

# Load saved model and scaler
model = joblib.load('app/model/isolation_model.pkl')
scaler = joblib.load('app/model/scaler.pkl')

def predict_anomaly(features):
    """
    Predict if the given feature vector is an anomaly or normal.

    Args:
        features (list of float): Feature vector matching the model input.

    Returns:
        str: "Anomaly" if detected as anomaly, "Normal" otherwise.
    """
    scaled = scaler.transform([features])
    prediction = model.predict(scaled)
    return "Anomaly" if prediction[0] == -1 else "Normal"

if __name__ == "__main__":
    # Example feature vector for testing
    test_input = [0, 0, 0, 0, 0]  # Replace with real feature values as needed
    result = predict_anomaly(test_input)
    print("🚨 Prediction:", result)
