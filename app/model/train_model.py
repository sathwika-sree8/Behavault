import pandas as pd
import ast
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import joblib
import os

# Path to session logs (adjust if needed)
data_path = os.path.join('behavault_backend', 'session_logs.csv')

# Load CSV without headers
df = pd.read_csv(data_path, header=None, names=['timestamp', 'severity', 'features'])

def clean_feature_string(raw):
    try:
        # Example: "{'features': [0, 1, 2, 3, 4]}"
        parsed = ast.literal_eval(raw)
        if isinstance(parsed, dict) and 'features' in parsed:
            return parsed['features']
        elif isinstance(parsed, list):
            return parsed
    except:
        pass
    return [0, 0, 0, 0, 0]  # fallback

# Apply the cleaner
df['features'] = df['features'].apply(clean_feature_string)

# Convert list of features to columns
features_df = pd.DataFrame(df['features'].tolist())

# Scale the features
scaler = StandardScaler()
X = scaler.fit_transform(features_df)

# Train Isolation Forest
model = IsolationForest(n_estimators=100, contamination=0.1, random_state=42)
model.fit(X)

# Save model and scaler
os.makedirs('app/model', exist_ok=True)
joblib.dump(model, 'app/model/isolation_model.pkl')
joblib.dump(scaler, 'app/model/scaler.pkl')

print("✅ Model and scaler saved successfully.")
