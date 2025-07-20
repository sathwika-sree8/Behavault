import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import json
import os

BEHAVIOR_DATA_FILE = '../behavior_data.json'
SESSION_LOG_FILE = '../behavault_backend/session_logs.csv'

st.title("Behavioral Analytics Dashboard")

@st.cache_data
def load_behavior_data():
    if os.path.exists(BEHAVIOR_DATA_FILE):
        with open(BEHAVIOR_DATA_FILE, 'r') as f:
            data = json.load(f)
        return data
    else:
        return []

@st.cache_data
def load_session_logs():
    if os.path.exists(SESSION_LOG_FILE):
        df = pd.read_csv(SESSION_LOG_FILE)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        return df
    else:
        return pd.DataFrame()

behavior_data = load_behavior_data()
session_logs = load_session_logs()

if behavior_data:
    st.subheader("Raw Behavior Data")
    st.json(behavior_data)

    # Convert list of event dicts to DataFrame
    df_behavior = pd.DataFrame(behavior_data)

    st.subheader("Event Type Distribution")
    event_counts = df_behavior['type'].value_counts()
    st.bar_chart(event_counts)

    st.subheader("Timestamp Range")
    if 'timestamp' in df_behavior.columns:
        df_behavior['timestamp'] = pd.to_datetime(df_behavior['timestamp'])
        st.write(f"From {df_behavior['timestamp'].min()} to {df_behavior['timestamp'].max()}")

    # Summary statistics for numeric columns
    numeric_cols = df_behavior.select_dtypes(include=[np.number]).columns.tolist()
    if numeric_cols:
        st.subheader("Summary Statistics for Numeric Data")
        st.dataframe(df_behavior[numeric_cols].describe())

    # Correlation heatmap
    if len(numeric_cols) > 1:
        st.subheader("Correlation Heatmap of Behavior Metrics")
        corr = df_behavior[numeric_cols].corr()
        sns.heatmap(corr, annot=True, cmap='coolwarm')
        st.pyplot(plt.gcf())
        plt.clf()
else:
    st.warning("No behavior data found in behavior_data.json.")

if not session_logs.empty:
    st.subheader("Flagged Session History")
    st.dataframe(session_logs)

    st.subheader("Anomaly Score Distribution")
    # Assuming 'features' column is string representation of list, convert to list of floats
    features_expanded = session_logs['features'].apply(lambda x: np.fromstring(x.strip('[]'), sep=',') if pd.notnull(x) else np.array([]))
    # Calculate anomaly scores as sum of features
    anomaly_scores = features_expanded.apply(np.sum)
    st.bar_chart(anomaly_scores.value_counts().sort_index())

    st.subheader("Behavioral Drift Over Time")
    drift_data = session_logs.groupby([session_logs['timestamp'].dt.date]).apply(lambda x: x['features'].apply(lambda f: np.sum(np.fromstring(f.strip('[]'), sep=','))).mean())
    drift_data.index = pd.to_datetime(drift_data.index)
    drift_data.plot(kind='line', marker='o')
    plt.xlabel('Date')
    plt.ylabel('Average Anomaly Score')
    plt.title('Behavioral Drift Over Time')
    st.pyplot(plt.gcf())
    plt.clf()

    st.subheader("Severity Count")
    sns.countplot(x='severity', data=session_logs)
    st.pyplot(plt.gcf())
    plt.clf()
else:
    st.warning("No session log data found.")

# Future features placeholders
st.markdown("### Coming Up Next in Streamlit (to be added):")
st.markdown("""
- Session Logs Table with timestamp, IP (if present), anomaly_score, severity, and is_anomalous.
- Flagged Sessions: Filtered view showing only medium and high severity logs.
- Model Explainability: Plot anomaly score thresholds and feature contributions.
- Data Logging: Ensure backend /predict endpoint appends data to session_logs.csv.
""")
