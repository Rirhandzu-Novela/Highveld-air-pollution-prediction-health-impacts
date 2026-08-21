import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import matplotlib.pyplot as plt
from scipy.stats import norm

# 1️⃣ Load the dataset
file_path = "GertPollCardMort.csv"  # Update path if needed
data = pd.read_csv(file_path, sep=";", parse_dates=["date"], dayfirst=True)

# 2️⃣ Handle missing values
data["death_count"].fillna(data["death_count"].median(), inplace=True)

# 3️⃣ Define features and target variable
features = ["pm2.5", "pm10", "so2", "no2", "temp", "relHum"]
target = "death_count"

# 4️⃣ Normalize features
# Capture PM2.5 range before scaling to convert 10 µg/m³ into scaled units
pm25_range = data["pm2.5"].max() - data["pm2.5"].min()
delta_scaled = 10 / pm25_range  # equivalent to 10 µg/m³ in scaled units

scaler = MinMaxScaler()
data[features] = scaler.fit_transform(data[features])

# 5️⃣ Create lagged features (0 to 14 days)
for lag in range(0, 15):  # Lag 0 is the current day
    for feature in features:
        data[f"{feature}_lag{lag}"] = data[feature].shift(lag)

# 6️⃣ Drop NaN values caused by lagging
data.dropna(inplace=True)

# 7️⃣ Split into train and test sets (80% train, 20% test)
train_data, test_data = train_test_split(data, test_size=0.2, shuffle=False)

# 8️⃣ Separate features (X) and target variable (y)
X_train, y_train = train_data.drop(columns=["date", "death_count"]), train_data["death_count"]
X_test, y_test = test_data.drop(columns=["date", "death_count"]), test_data["death_count"]

# 9️⃣ Reshape for LSTM input (samples, time steps, features)
X_train_lstm = np.reshape(X_train.values, (X_train.shape[0], 1, X_train.shape[1]))
X_test_lstm = np.reshape(X_test.values, (X_test.shape[0], 1, X_test.shape[1]))

# 🔟 Build the LSTM model
lstm_model = Sequential([
    LSTM(64, return_sequences=True, input_shape=(1, X_train.shape[1])),
    Dropout(0.2),
    LSTM(32, return_sequences=False),
    Dropout(0.2),
    Dense(16, activation='relu'),
    Dense(1)  # Output layer for regression
])

# 1️⃣1️⃣ Compile model
lstm_model.compile(optimizer=Adam(learning_rate=0.001), loss='mean_squared_error')

# 1️⃣2️⃣ Train the model
history = lstm_model.fit(X_train_lstm, y_train, epochs=20, batch_size=32, validation_data=(X_test_lstm, y_test), verbose=1)

# 1️⃣3️⃣ Predict mortality
y_pred_lstm = lstm_model.predict(X_test_lstm).flatten()

# 1️⃣4️⃣ Compute evaluation metrics
mae = mean_absolute_error(y_test, y_pred_lstm)
rmse = np.sqrt(mean_squared_error(y_test, y_pred_lstm))
r2 = r2_score(y_test, y_pred_lstm)

print(f"LSTM Model Performance:")
print(f"MAE: {mae:.2f}, RMSE: {rmse:.2f}, R² Score: {r2:.2f}")

# 1️⃣5️⃣ Estimate RR (Risk Ratio) with Bootstrapped CI
n_bootstrap = 1000  # Number of bootstrap samples
lstm_results = {}

for lag in range(0, 15):  # Lag0 to Lag14
    X_base = X_test.copy()
    X_increased = X_test.copy()
    
    # Add 10 µg/m³ in scaled units to PM2.5 at this lag (clipped to valid [0,1] range)
    X_increased[f"pm2.5_lag{lag}"] = (
        X_base[f"pm2.5_lag{lag}"] + delta_scaled
    ).clip(0, 1)
    
    # Reshape for LSTM input
    X_base_lstm = np.reshape(X_base.values, (X_base.shape[0], 1, X_base.shape[1]))
    X_increased_lstm = np.reshape(X_increased.values, (X_increased.shape[0], 1, X_increased.shape[1]))

    # Predict mortality under baseline & increased pollution
    y_pred_base = lstm_model.predict(X_base_lstm).flatten()
    y_pred_increased = lstm_model.predict(X_increased_lstm).flatten()
    
    # Compute bootstrapped RR estimates
    rr_bootstrap = []
    for _ in range(n_bootstrap):
        sample_idx = np.random.choice(len(y_pred_base), size=len(y_pred_base), replace=True)
        rr_sample = np.mean(y_pred_increased[sample_idx]) / np.mean(y_pred_base[sample_idx])
        rr_bootstrap.append(rr_sample)

    # Compute mean RR and 95% CI
    rr_lstm = np.mean(rr_bootstrap)
    ci_lower, ci_upper = np.percentile(rr_bootstrap, [2.5, 97.5])
    
    # Store results
    lstm_results[lag] = [rr_lstm, ci_lower, ci_upper]

# Convert results to DataFrame
lstm_rr_ci_df = pd.DataFrame.from_dict(lstm_results, orient="index", columns=["PM₂.₅ PMR (LSTM)", "CI Lower (LSTM)", "CI Upper (LSTM)"])
lstm_rr_ci_df.reset_index(inplace=True)
lstm_rr_ci_df.rename(columns={"index": "Lag (Days)"}, inplace=True)

# 1️⃣6️⃣ Display final RR & CI results
print(lstm_rr_ci_df.to_string(index=False))
lstm_rr_ci_df.to_csv("lstm_rr_ci_results.csv", index=False)

# 1️⃣7️⃣ Plot Actual vs Predicted Deaths
plt.figure(figsize=(12, 6))
plt.plot(y_test.values, label="Actual Deaths", color='blue')
plt.plot(y_pred_lstm, label="Predicted Deaths (LSTM)", color='red', linestyle='dashed')
plt.legend()
plt.xlabel("Time")
plt.ylabel("Mortality Count")
plt.title("LSTM Predicted vs Actual Mortality")
plt.show()