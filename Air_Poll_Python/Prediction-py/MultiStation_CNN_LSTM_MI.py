"""
Multi-Station CNN-LSTM with Mutual Information (MI) Feature Selection
Selects features above a configurable MI threshold before training
Allows reusing hyperparameters across different stations and pollutants
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.feature_selection import mutual_info_regression
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

import os
import warnings
warnings.filterwarnings('ignore')

try:
    import shap
    SHAP_AVAILABLE = True
except ImportError:
    SHAP_AVAILABLE = False

# Set random seeds
np.random.seed(42)
tf.random.set_seed(42)

print("="*80)
print("MULTI-STATION CNN-LSTM WITH MI FEATURE SELECTION")
print("="*80)

# ============================================================================
# CONFIGURATION
# ============================================================================
MI_THRESHOLD = 0.01  # Only features with MI > this threshold are used
# Adjust this threshold to control feature selection
# Lower threshold = more features, Higher threshold = fewer features

# ============================================================================
# 1. LOAD AND PREPARE DATA
# ============================================================================
print("\n[1/7] Loading data...")

em = pd.read_csv('eMalahleniIM.csv', sep=';', header=0, index_col=0)
mb = pd.read_csv('MiddelburgIM.csv', sep=';', header=0, index_col=0)

min_len = min(len(em), len(mb))
em = em[:min_len]
mb = mb[:min_len]

print(f"eMalahleni shape: {em.shape}")
print(f"Middelburg shape: {mb.shape}")

# Extract target and ALL features INCLUDING PM2.5
target = em['pm2.5'].values.reshape(-1, 1)
em_all = em.values  # All 13 features including PM2.5
mb_all = mb.values  # All 13 features including PM2.5

# Get feature names
feature_names_em = em.columns.tolist()  # All 13 including PM2.5
feature_names_mb = mb.columns.tolist()  # All 13 including PM2.5

# Label features by station
feature_names = [f"EM_{name}" for name in feature_names_em] + \
                [f"MB_{name}" for name in feature_names_mb]

# Combine features: [13 + 13 = 26 features]
combined_features = np.concatenate([em_all, mb_all], axis=1)

print(f"Combined features shape: {combined_features.shape}")
print(f"Feature names: {feature_names}")

# Normalize
scaler_features = MinMaxScaler()
scaler_target = MinMaxScaler()

combined_norm = scaler_features.fit_transform(combined_features)
target_norm = scaler_target.fit_transform(target)

# ============================================================================
# 2. CALCULATE MUTUAL INFORMATION SCORES
# ============================================================================
print("\n[2/7] Calculating Mutual Information scores...")

mi_scores = mutual_info_regression(combined_norm, target_norm.flatten(),
                                    random_state=42)

mi_df = pd.DataFrame({
    'Feature': feature_names,
    'MI_Score': mi_scores
}).sort_values('MI_Score', ascending=False)

print("\nMutual Information Scores (all features):")
print(mi_df.to_string(index=False))

# ============================================================================
# 3. SELECT FEATURES ABOVE THRESHOLD
# ============================================================================
print(f"\n[3/7] Selecting features with MI > {MI_THRESHOLD}...")

selected_mask = mi_scores > MI_THRESHOLD
selected_features = combined_norm[:, selected_mask]
selected_feature_names = [name for name, mask in zip(feature_names, selected_mask) if mask]

print(f"\nSelected {len(selected_feature_names)} features:")
for name in selected_feature_names:
    idx = feature_names.index(name)
    print(f"  {name}: MI={mi_scores[idx]:.6f}")

print(f"\nRemoved {np.sum(~selected_mask)} features:")
removed_feature_names = [name for name, mask in zip(feature_names, selected_mask) if not mask]
for name in removed_feature_names:
    idx = feature_names.index(name)
    print(f"  {name}: MI={mi_scores[idx]:.6f}")

# ============================================================================
# 4. CREATE SEQUENCES
# ============================================================================
print("\n[4/7] Creating sequences with selected features...")

def create_sequences(data, target_data, n_in=1):
    X, y = [], []
    
    for i in range(len(data) - n_in):
        X.append(data[i:i+n_in])
        y.append(target_data[i+n_in])
    
    return np.array(X), np.array(y)

n_in = 24
X, y = create_sequences(selected_features, target_norm, n_in=n_in)

print(f"Sequences created: X {X.shape}, y {y.shape}")
print(f"Input features: {X.shape[2]}")

# ============================================================================
# 5. SPLIT DATA
# ============================================================================
print("\n[5/7] Splitting data...")

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42
)
X_train, X_val, y_train, y_val = train_test_split(
    X_train, y_train, test_size=0.20, random_state=42
)

print(f"Train: {X_train.shape}, Val: {X_val.shape}, Test: {X_test.shape}")

# ============================================================================
# 6. BUILD AND TRAIN MODEL
# ============================================================================
print("\n[6/7] Building and training model...")

# Using hyperparameters from grid search
best_params = {
    'filters': 128,
    'dropout': 0.3,
    'lstm_units': 64,
    'learning_rate': 0.001,
    'batch_size': 32,
    'dense_units': 128
}

keras.backend.clear_session()

model = keras.Sequential([
    layers.Input(shape=(X_train.shape[1], X_train.shape[2])),
    
    # Conv1D layers with SpatialDropout1D
    layers.Conv1D(best_params['filters'], 3, padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.SpatialDropout1D(best_params['dropout']),
    
    layers.Conv1D(best_params['filters'], 3, padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.SpatialDropout1D(best_params['dropout']),
    
    # Bidirectional LSTM layer
    layers.Bidirectional(layers.LSTM(best_params['lstm_units'], activation='relu', return_sequences=False)),
    layers.Dropout(best_params['dropout']),
    layers.BatchNormalization(),
    
    # Dense layers
    layers.Dense(best_params['dense_units'], activation='relu'),
    layers.Dropout(best_params['dropout']),
    
    layers.Dense(32, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(1)
])

optimizer = keras.optimizers.Adam(learning_rate=best_params['learning_rate'])
model.compile(optimizer=optimizer, loss='mse', metrics=['mae'])

print("\nModel Summary:")
print("-" * 80)
model.summary()

callbacks = [
    keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=15,
        restore_best_weights=True
    ),
    keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=7,
        min_lr=1e-6,
        verbose=0
    )
]

print(f"\nTraining with {len(X_train)} samples and {X_train.shape[2]} features...")
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=100,
    batch_size=best_params['batch_size'],
    callbacks=callbacks,
    verbose=1
)

print(f"Training completed in {len(history.history['loss'])} epochs")

# ============================================================================
# 7. EVALUATE MODEL
# ============================================================================
print("\n[7/7] Evaluating model...")

y_train_pred = model.predict(X_train, verbose=0).flatten()
y_val_pred = model.predict(X_val, verbose=0).flatten()
y_test_pred = model.predict(X_test, verbose=0).flatten()

def calc_metrics(y_true, y_pred, set_name=""):
    mae = mean_absolute_error(y_true, y_pred)
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    r2 = r2_score(y_true, y_pred)
    mape = np.mean(np.abs((y_true - y_pred) / (y_true + 1e-8))) * 100
    
    return {
        'Set': set_name,
        'MAE': mae,
        'RMSE': rmse,
        'R²': r2,
        'MAPE': mape
    }

train_metrics = calc_metrics(y_train, y_train_pred, "Train")
val_metrics = calc_metrics(y_val, y_val_pred, "Validation")

# Denormalize test data for metrics reporting
y_test_denorm = scaler_target.inverse_transform(y_test.reshape(-1, 1)).flatten()
y_test_pred_denorm = scaler_target.inverse_transform(y_test_pred.reshape(-1, 1)).flatten()
test_metrics = calc_metrics(y_test_denorm, y_test_pred_denorm, "Test")

metrics_df = pd.DataFrame([train_metrics, val_metrics, test_metrics])

print("\n" + "="*80)
print("PERFORMANCE METRICS (Test: denormalized, Train/Val: normalized)")
print("="*80)
print(metrics_df.to_string(index=False))

# Create Results directory if it doesn't exist
os.makedirs('Results', exist_ok=True)

# Save metrics
metrics_df.to_csv(f'Results/EmaMultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_metrics_PM2.csv', index=False)
print(f"Metrics saved to: Results/EmaMultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_metrics_PM2.csv")

# ============================================================================
# PREDICTION INTERVALS (Narrow - 25th-75th percentile)
# ============================================================================
print("\n" + "="*80)
print("PREDICTION INTERVALS (25th-75th Percentile)")
print("="*80)

# Calculate empirical percentiles from training residuals
train_residuals = y_train - y_train_pred
lower_percentile = np.percentile(train_residuals, 25)
upper_percentile = np.percentile(train_residuals, 75)

print(f"\nTraining residual 25th percentile: {lower_percentile:.6f}")
print(f"Training residual 75th percentile: {upper_percentile:.6f}")

# Apply intervals to test predictions
y_test_lower = y_test_pred + lower_percentile
y_test_upper = y_test_pred + upper_percentile

# Denormalize interval bounds
y_test_lower_denorm = scaler_target.inverse_transform(y_test_lower.reshape(-1, 1)).flatten()
y_test_upper_denorm = scaler_target.inverse_transform(y_test_upper.reshape(-1, 1)).flatten()

print(f"\nTest Predictions with IQR (25-75%):")
print(f"  Mean prediction: {np.mean(y_test_pred_denorm):.4f}")
print(f"  Mean interval: [{np.mean(y_test_lower_denorm):.4f}, {np.mean(y_test_upper_denorm):.4f}]")

# Save predictions with intervals
predictions_df = pd.DataFrame({
    'Actual': y_test_denorm,
    'Predicted': y_test_pred_denorm,
    'Lower_25Percentile': y_test_lower_denorm,
    'Upper_75Percentile': y_test_upper_denorm,
    'Residual': y_test_denorm - y_test_pred_denorm,
    'Abs_Error': np.abs(y_test_denorm - y_test_pred_denorm)
})
predictions_df.to_csv(f'Results/MultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_Predictions.csv', index=False)
print(f"Predictions saved to: Results/MultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_Predictions.csv")

# ============================================================================
# VISUALIZATIONS (Time Series, Quantile Analysis, SHAP)
# ============================================================================
print("\n[7/7] Creating visualizations...")

fig = plt.figure(figsize=(16, 10))

# 1. MI Scores
ax1 = plt.subplot(2, 2, 1)
mi_df_plot = mi_df.copy()
colors = ['green' if score > MI_THRESHOLD else 'red' for score in mi_df_plot['MI_Score']]
ax1.barh(mi_df_plot['Feature'], mi_df_plot['MI_Score'], color=colors)
ax1.axvline(x=MI_THRESHOLD, color='blue', linestyle='--', linewidth=2, label=f'Threshold={MI_THRESHOLD}')
ax1.set_xlabel('Mutual Information Score')
ax1.set_title(f'Feature Selection (MI > {MI_THRESHOLD})', fontsize=12, fontweight='bold')
ax1.legend()
ax1.grid(axis='x', alpha=0.3)

# 2. Time Series: Actual vs Predicted
ax2 = plt.subplot(2, 2, 2)
time_steps = np.arange(len(y_test_denorm))
ax2.plot(time_steps, y_test_denorm, label='Actual', linewidth=2, alpha=0.7)
ax2.plot(time_steps, y_test_pred_denorm, label='Predicted', linewidth=2, alpha=0.7)
ax2.set_title('Time Series: Actual vs Predicted (Denormalized)', fontsize=12, fontweight='bold')
ax2.set_xlabel('Time Step')
ax2.set_ylabel('PM2.5 (µg/m³)')
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)

# 3. Quantile Analysis: Average Error by Quantile
ax3 = plt.subplot(2, 2, 3)
errors = np.abs(y_test_denorm - y_test_pred_denorm)
bins = pd.qcut(y_test_denorm, q=5, retbins=True)[1]

quantile_errors = []
for i in range(len(bins) - 1):
    group_indices = np.where((y_test_denorm >= bins[i]) & (y_test_denorm < bins[i+1]))[0]
    if len(group_indices) > 0:
        quantile_errors.append(errors[group_indices].mean())
    else:
        quantile_errors.append(0)

rounded_bins = np.round(bins, decimals=2)

ax3.plot(range(1, len(quantile_errors) + 1), quantile_errors, marker='o', linewidth=2, markersize=8, color='steelblue')
ax3.set_xlabel('Quantile', fontweight='bold', size=11)
ax3.set_ylabel('Average Absolute Error (µg/m³)', fontweight='bold', size=11)
ax3.set_title('Quantile Analysis: Average Error by PM2.5 Level', fontweight='bold', size=12)
ax3.set_xticks(range(1, len(quantile_errors) + 1))
ax3.set_xticklabels([f'{rounded_bins[i]:.1f}-{rounded_bins[i+1]:.1f}' for i in range(len(rounded_bins) - 1)], rotation=45)
ax3.grid(True, alpha=0.3)

# 4. Prediction Accuracy Metrics
ax4 = plt.subplot(2, 2, 4)
metrics_names = ['MAE', 'RMSE', 'MAPE']
test_vals = [test_metrics['MAE'], test_metrics['RMSE'], test_metrics['MAPE']]
colors_metrics = ['#1f77b4', '#ff7f0e', '#2ca02c']

ax4.bar(metrics_names, test_vals, color=colors_metrics, alpha=0.7, edgecolor='black', linewidth=1.5)
ax4.set_ylabel('Error Value')
ax4.set_title(f'Test Set Performance Metrics (R²={test_metrics["R²"]:.4f})', fontsize=12, fontweight='bold')
ax4.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig(f'Results/MultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_Analysis.png', dpi=300, bbox_inches='tight')
print(f"Analysis visualization saved to: Results/MultiStation_CNN_LSTM_MI{int(MI_THRESHOLD*100)}_Analysis.png")
plt.close()

# Save feature selection info
feature_info = {
    'mi_threshold': MI_THRESHOLD,
    'total_features': len(feature_names),
    'selected_features': len(selected_feature_names),
    'selected_feature_names': selected_feature_names,
    'removed_feature_names': removed_feature_names,
    'mi_scores': {name: float(score) for name, score in zip(feature_names, mi_scores)}
}

model.save(f'multistation_cnn_lstm_mi_best_model.h5')
print(f"Model saved to: multistation_cnn_lstm_mi_best_model.h5")

# ============================================================================
# SHAP ANALYSIS FOR INTERPRETABILITY
# ============================================================================

if SHAP_AVAILABLE:
    print("\n" + "="*80)
    print("SHAP FEATURE IMPORTANCE ANALYSIS")
    print("="*80)
    
    try:
        # Store number of selected features for SHAP wrapper
        num_selected_feats = len(selected_feature_names) * 2  # Both stations
        n_in_value = best_params['n_in']
        
        # Create a wrapper function for SHAP that reshapes input
        def cnn_lstm_mi_predict_wrapper(X_flat):
            """Convert flattened input back to 3D for CNN-LSTM prediction."""
            if X_flat.ndim == 1:
                X_flat = X_flat.reshape(1, -1)
            
            # Reshape from (batch, flat) to (batch, timesteps, features)
            n_samples = X_flat.shape[0]
            X_3d = X_flat.reshape(n_samples, n_in_value, num_selected_feats)
            
            # Return predictions
            return model.predict(X_3d, verbose=0).flatten()
        
        # Prepare sample data for SHAP (use first 50 test samples)
        n_shap_samples = min(50, len(X_test))
        X_shap_samples = X_test[:n_shap_samples].reshape(n_shap_samples, -1)  # Flatten to 2D
        X_background = X_shap_samples[:10]  # Use 10 background samples
        
        print("Initializing SHAP KernelExplainer (model-agnostic)...")
        explainer = shap.KernelExplainer(cnn_lstm_mi_predict_wrapper, X_background)
        
        print("Computing SHAP values for test samples...")
        # Use first 20 test samples for explanation
        shap_values = explainer.shap_values(X_shap_samples[:20], nsamples=100)
        shap_values = np.array(shap_values).squeeze()  # Handle output shape
        
        # Create feature names using selected features from both stations
        stations_list = ['eMalahleni', 'Middelburg']
        feature_names = []
        for t in range(best_params['n_in']):
            for station in stations_list:
                for feat in selected_feature_names:
                    feature_names.append(f"{station}_{feat}(t-{best_params['n_in']-t})")
        
        # Ensure feature names match X_shap_samples shape
        if len(feature_names) != X_shap_samples.shape[1]:
            print(f"Warning: feature_names length {len(feature_names)} != X_shap_samples width {X_shap_samples.shape[1]}")
            # Fallback: create generic feature names
            feature_names = [f"f{i}" for i in range(X_shap_samples.shape[1])]
        
        # SHAP summary plot
        plt.figure(figsize=(12, 8))
        shap.summary_plot(shap_values, X_shap_samples[:20], 
                         feature_names=feature_names, show=False, max_display=20)
        plt.title(f'CNN-LSTM MI Feature Importance (Threshold={MI_THRESHOLD})', fontweight='bold', size=14)
        plt.tight_layout()
        plt.savefig(f'Results/multistation_cnn_lstm_mi_shap_summary.png', dpi=300, bbox_inches='tight')
        print("SHAP summary plot saved to: Results/multistation_cnn_lstm_mi_shap_summary.png")
        plt.close()
        
        # SHAP bar plot
        plt.figure(figsize=(10, 6))
        shap.summary_plot(shap_values, X_shap_samples[:20], 
                         feature_names=feature_names, plot_type="bar", show=False, max_display=15)
        plt.title(f'CNN-LSTM MI Feature Importance (Mean, Threshold={MI_THRESHOLD})', fontweight='bold', size=14)
        plt.tight_layout()
        plt.savefig(f'Results/multistation_cnn_lstm_mi_shap_bar.png', dpi=300, bbox_inches='tight')
        print("SHAP bar plot saved to: Results/multistation_cnn_lstm_mi_shap_bar.png")
        plt.close()
        
        print("✅ SHAP analysis completed successfully!")
        
    except Exception as e:
        print(f"⚠️ SHAP analysis failed: {e}")
        print("Continuing without SHAP analysis...")
else:
    print("\n⚠️ SHAP not available. Install with: pip install shap")


print("\n" + "="*80)
print("MULTI-STATION CNN-LSTM WITH MI FEATURE SELECTION COMPLETE")
print("="*80)
print(f"\nMI Threshold: {MI_THRESHOLD}")
print(f"Features Selected: {len(selected_feature_names)} / {len(feature_names)}")
print(f"Test R² Score: {test_metrics['R²']:.4f}")
print(f"Test MAE: {test_metrics['MAE']:.4f}")
print(f"Test RMSE: {test_metrics['RMSE']:.4f}")
