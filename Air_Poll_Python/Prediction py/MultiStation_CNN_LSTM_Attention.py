"""
Multi-Station CNN-LSTM with Station Attention Mechanism
========================================================
Demonstrates how attention weights can learn which station matters more for prediction.

Key Features:
- Multi-head attention over stations (Station A vs Station B)
- Attention weights visualization (shows importance of each station)
- Same data split as other models for fair comparison
- Early stopping and adaptive learning rate
- 26 features = 13 per station (including PM2.5(t-1), matching LSTM approach)

Architecture:
  Input (26 features = 13 per station)
    ↓
  CNN (1D convolution)
    ↓
  LSTM (temporal processing)
    ↓
  Station Attention (learn which station to focus on)
    ↓
  Dense layers
    ↓
  Output (PM2.5 prediction)
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Model
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from datetime import datetime

try:
    import shap
    SHAP_AVAILABLE = True
except ImportError:
    SHAP_AVAILABLE = False

print(f"TensorFlow version: {tf.__version__}")
print(f"Script started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

# =============================================================================
# 1. LOAD DATA
# =============================================================================
print("[1/7] Loading data...")

# Load both stations
em = pd.read_csv('eMalahleniIM.csv', sep=';', header=0, index_col=0)
mb = pd.read_csv('MiddelburgIM.csv', sep=';', header=0, index_col=0)

# Extract PM2.5 target
target_em = em['pm2.5'].values
target_mb = mb['pm2.5'].values

# We'll predict eMalahleni PM2.5 (you can change to mb if desired)
target = target_em

# Get ALL features INCLUDING PM2.5 (matches LSTM approach)
# This way we have PM2.5(t-1) as a feature, predicting PM2.5(t)
em_all = em.values  # All 13 features including PM2.5
mb_all = mb.values  # All 13 features including PM2.5

# Normalize all features from both stations separately
scaler_em = MinMaxScaler()
scaler_mb = MinMaxScaler()
scaler_target = MinMaxScaler()

em_norm = scaler_em.fit_transform(em_all)
mb_norm = scaler_mb.fit_transform(mb_all)
target_norm = scaler_target.fit_transform(target.reshape(-1, 1)).flatten()

print(f"eMalahleni: {em.shape}, Middelburg: {mb.shape}")
print(f"Target shape: {target.shape}")

# =============================================================================
# 2. CREATE SEQUENCES
# =============================================================================
print("\n[2/7] Creating sequences...")

def create_sequences(em_data, mb_data, target_data, n_in=1):
    """Create sequences with concatenated station features"""
    X, y = [], []
    
    for i in range(len(em_data) - n_in):
        # Concatenate features from both stations: [EM_12 + MB_12]
        x_seq = np.concatenate([em_data[i:i+n_in].flatten(), 
                                mb_data[i:i+n_in].flatten()])
        X.append(x_seq)
        y.append(target_data[i+n_in])
    
    return np.array(X), np.array(y)

X, y = create_sequences(em_norm, mb_norm, target_norm, n_in=1)
print(f"Sequences created: X {X.shape}, y {y.shape}")
print(f"  Features: {X.shape[1]} ({X.shape[1]//2} per station × 2)")

# =============================================================================
# 3. SPLIT DATA (SAME AS NOTEBOOKS)
# =============================================================================
print("\n[3/7] Splitting data...")

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42
)
X_train, X_val, y_train, y_val = train_test_split(
    X_train, y_train, test_size=0.20, random_state=42
)

print(f"Train: {X_train.shape}, Val: {X_val.shape}, Test: {X_test.shape}")

# Reshape for CNN-LSTM: (samples, timesteps, features)
# We have 26 features in 1 timestep, reshape to (samples, 1, 26)
X_train = X_train.reshape(X_train.shape[0], 1, X_train.shape[1])
X_val = X_val.reshape(X_val.shape[0], 1, X_val.shape[1])
X_test = X_test.reshape(X_test.shape[0], 1, X_test.shape[1])

print(f"Reshaped: Train {X_train.shape}, Val {X_val.shape}, Test {X_test.shape}")

# =============================================================================
# 4. ATTENTION LAYER FOR STATIONS
# =============================================================================
print("\n[4/7] Building attention mechanism...")

class StationAttention(layers.Layer):
    """
    Simple attention mechanism over two stations.
    
    Learned weights combine contributions from two stations.
    """
    def __init__(self, **kwargs):
        super(StationAttention, self).__init__(**kwargs)
        
    def build(self, input_shape):
        self.attention_weights = self.add_weight(
            name='attention_station',
            shape=(2,),  # Two stations
            initializer='ones',
            trainable=True
        )
        super(StationAttention, self).build(input_shape)
    
    def call(self, inputs_list):
        """inputs_list: [x, lstm_out]"""
        x, lstm_out = inputs_list
        x_flat = tf.reshape(x, (tf.shape(x)[0], -1))
        attn_weights = tf.nn.softmax(self.attention_weights)
        station_a = x_flat[..., :13] * attn_weights[0]
        station_b = x_flat[..., 13:] * attn_weights[1]
        attention_out = tf.concat([station_a, station_b], axis=-1)
        combined = tf.concat([lstm_out, attention_out], axis=-1)
        return combined

# =============================================================================
# 5. BUILD MODEL WITH ATTENTION
# =============================================================================
print("\n[5/7] Building CNN-LSTM model with station attention...")

def build_model_with_attention():
    """
    CNN-LSTM model with learning-based station attention mechanism.
    """
    inputs = keras.Input(shape=(X_train.shape[1], X_train.shape[2]), name='cnn_lstm_input')
    
    # Conv1D + LSTM
    x = layers.Conv1D(filters=64, kernel_size=3, activation='relu', padding='same')(inputs)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.3)(x)
    
    lstm1 = layers.LSTM(56, activation='relu', return_sequences=True)(x)
    lstm_out = layers.LSTM(56, activation='relu', return_sequences=False)(lstm1)
    lstm_out = layers.Dropout(0.3)(lstm_out)
    
    # Attention layer
    attention_layer = StationAttention()
    combined = layers.Lambda(lambda tensors: attention_layer(tensors), 
                            output_shape=(82,))([inputs, lstm_out])
    
    # Dense layers
    x = layers.Dense(128, activation='relu')(combined)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.3)(x)
    
    x = layers.Dense(64, activation='relu')(x)
    x = layers.Dropout(0.2)(x)
    
    outputs = layers.Dense(1)(x)
    
    model = Model(inputs, outputs)
    return model, attention_layer

model, attention_layer = build_model_with_attention()
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss='mse',
    metrics=['mae']
)

print(f"Model parameters: {model.count_params():,}")
model.summary()

# =============================================================================
# 6. TRAIN MODEL
# =============================================================================
print("\n[6/7] Training model...")

callbacks = [
    EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True),
    ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-6)
]

history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=100,
    batch_size=32,
    callbacks=callbacks,
    verbose=1
)

print("Training complete!")

# =============================================================================
# 7. EVALUATE & VISUALIZE
# =============================================================================
print("\n[7/7] Evaluating model...")

def evaluate_model(model, X, y, set_name):
    """Evaluate and print metrics"""
    y_pred = model.predict(X, verbose=0)
    
    # Denormalize predictions
    y_pred_denorm = scaler_target.inverse_transform(y_pred)
    y_denorm = scaler_target.inverse_transform(y.reshape(-1, 1))
    
    r2 = r2_score(y_denorm, y_pred_denorm)
    mae = mean_absolute_error(y_denorm, y_pred_denorm)
    rmse = np.sqrt(mean_squared_error(y_denorm, y_pred_denorm))
    
    print(f"\n{set_name} Metrics:")
    print(f"  R² Score: {r2:.4f}")
    print(f"  MAE:      {mae:.3f} µg/m³")
    print(f"  RMSE:     {rmse:.3f} µg/m³")
    
    return y_pred_denorm, y_denorm, r2, mae, rmse

# Evaluate on all sets
train_pred, train_true, train_r2, train_mae, train_rmse = evaluate_model(model, X_train, y_train, "TRAIN")
val_pred, val_true, val_r2, val_mae, val_rmse = evaluate_model(model, X_val, y_val, "VALIDATION")
test_pred, test_true, test_r2, test_mae, test_rmse = evaluate_model(model, X_test, y_test, "TEST")

# =============================================================================
# VISUALIZATIONS
# =============================================================================
print("\nGenerating visualizations...")

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Multi-Station CNN-LSTM with Attention - Performance', fontsize=14, fontweight='bold')

# 1. Training history
ax = axes[0, 0]
ax.plot(history.history['loss'], label='Train Loss', linewidth=2)
ax.plot(history.history['val_loss'], label='Val Loss', linewidth=2)
ax.set_xlabel('Epoch')
ax.set_ylabel('Loss (MSE)')
ax.set_title('Training History')
ax.legend()
ax.grid(True, alpha=0.3)

# 2. Actual vs Predicted (Test)
ax = axes[0, 1]
ax.scatter(test_true, test_pred, alpha=0.5, s=20)
ax.plot([test_true.min(), test_true.max()], [test_true.min(), test_true.max()], 'r--', lw=2)
ax.set_xlabel('Actual PM2.5 (µg/m³)')
ax.set_ylabel('Predicted PM2.5 (µg/m³)')
ax.set_title(f'Test: R²={test_r2:.4f}, MAE={test_mae:.2f}')
ax.grid(True, alpha=0.3)

# 3. Error distribution
ax = axes[1, 0]
residuals = test_true.flatten() - test_pred.flatten()
ax.hist(residuals, bins=50, edgecolor='black', alpha=0.7)
ax.axvline(0, color='r', linestyle='--', linewidth=2)
ax.set_xlabel('Residual (µg/m³)')
ax.set_ylabel('Frequency')
ax.set_title(f'Error Distribution (Mean={residuals.mean():.2f})')
ax.grid(True, alpha=0.3, axis='y')

# 4. Time series comparison (first 500 samples)
ax = axes[1, 1]
time_window = 500
ax.plot(test_true[:time_window], label='Actual', linewidth=2, alpha=0.8)
ax.plot(test_pred[:time_window], label='Predicted', linewidth=2, alpha=0.8)
ax.fill_between(range(time_window), test_true[:time_window].flatten(), 
                 test_pred[:time_window].flatten(), alpha=0.2)
ax.set_xlabel('Time Sample')
ax.set_ylabel('PM2.5 (µg/m³)')
ax.set_title('Time Series Comparison (First 500 Test Samples)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('Results/multistation_cnnlstm_attention_performance.png', dpi=150, bbox_inches='tight')
print("✓ Saved: multistation_cnnlstm_attention_performance.png")
plt.show()

# =============================================================================
# ATTENTION WEIGHTS ANALYSIS
# =============================================================================
print("\n" + "="*70)
print("ATTENTION MECHANISM ANALYSIS")
print("="*70)

# Extract attention weights from the attention layer
attn_weights_learned = tf.nn.softmax(attention_layer.attention_weights).numpy()

print("\nStation Attention Mechanism:")
print(f"  This represents how much each station influenced the prediction")

# Station importance percentages
station_a_pct = attn_weights_learned[0] * 100
station_b_pct = attn_weights_learned[1] * 100

print(f"\nLearned Station Importance:")
print(f"  eMalahleni (Station A): {station_a_pct:.1f}%")
print(f"  Middelburg  (Station B): {station_b_pct:.1f}%")

# Visualize
fig, ax = plt.subplots(figsize=(8, 6))
stations = ['eMalahleni\n(Station A)', 'Middelburg\n(Station B)']
importance = [station_a_pct, station_b_pct]
colors = ['#1f77b4', '#ff7f0e']

bars = ax.bar(stations, importance, color=colors, alpha=0.7, edgecolor='black', linewidth=2)
ax.set_ylabel('Relative Importance (%)', fontsize=12)
ax.set_title('Station Importance Learned by Attention Mechanism', fontsize=13, fontweight='bold')
ax.set_ylim([0, 100])

# Add percentage labels on bars
for bar, val in zip(bars, importance):
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2., height,
            f'{val:.1f}%', ha='center', va='bottom', fontsize=12, fontweight='bold')

ax.grid(True, alpha=0.3, axis='y')
plt.tight_layout()
plt.savefig('Results/station_attention_weights.png', dpi=150, bbox_inches='tight')
print("\n✓ Saved: station_attention_weights.png")
plt.show()

# =============================================================================
# COMPARISON WITH BASELINES
# =============================================================================
print("\n" + "="*70)
print("COMPARISON WITH BASELINE MODELS")
print("="*70)

comparison = {
    'Model': [
        'LSTM '
        '(baseline)',
        'CNN-LSTM (baseline)',
        'CNN-LSTM + Attention (this)'
    ],
    'R² Score': [0.7255, 0.7065, test_r2],
    'MAE (µg/m³)': [7.356, 8.669, test_mae],
    'RMSE (µg/m³)': [15.958, 16.502, test_rmse]
}

comparison_df = pd.DataFrame(comparison)
print("\n", comparison_df.to_string(index=False))

improvement_r2 = ((test_r2 - 0.7065) / 0.7065) * 100
improvement_mae = ((8.669 - test_mae) / 8.669) * 100

print(f"\nImprovement vs CNN-LSTM baseline:")
print(f"  R² Change: {improvement_r2:+.2f}%")
print(f"  MAE Change: {improvement_mae:+.2f}%")

if test_r2 > 0.7255:
    print(f"\n✅ BEATS LSTM BASELINE! (R²={test_r2:.4f} vs 0.7255)")
else:
    print(f"\n📊 Close to LSTM baseline (R²={test_r2:.4f} vs 0.7255)")
    print(f"   Attention adds interpretability even if performance is similar")

# =============================================================================
# SAVE RESULTS
# =============================================================================
print("\n" + "="*70)
print("SAVING RESULTS")
print("="*70)

# Create Results directory if it doesn't exist
import os
os.makedirs('Results', exist_ok=True)

# Save predictions CSV
test_true_flat = test_true.flatten()
test_pred_flat = test_pred.flatten()
predictions_df = pd.DataFrame({
    'Actual': test_true_flat,
    'Predicted': test_pred_flat,
    'Error': np.abs(test_true_flat - test_pred_flat),
    'Error_Percent': (np.abs(test_true_flat - test_pred_flat) / (np.abs(test_true_flat) + 1e-8)) * 100
})
predictions_df.to_csv('Results/multistation_cnnlstm_attention_predictions.csv', index=False)
print("✓ Saved: Results/multistation_cnnlstm_attention_predictions.csv")

# Save metrics CSV
metrics_df = pd.DataFrame({
    'Set': ['Train', 'Validation', 'Test'],
    'R2': [train_r2, val_r2, test_r2],
    'MAE': [train_mae, val_mae, test_mae],
    'RMSE': [train_rmse, val_rmse, test_rmse]
})
metrics_df.to_csv('Results/multistation_cnnlstm_attention_metrics.csv', index=False)
print("✓ Saved: Results/multistation_cnnlstm_attention_metrics.csv")

# Save comparison CSV
comparison_df.to_csv('Results/multistation_cnnlstm_attention_comparison.csv', index=False)
print("✓ Saved: Results/multistation_cnnlstm_attention_comparison.csv")

# ============================================================================
# SHAP ANALYSIS FOR INTERPRETABILITY
# ============================================================================

if SHAP_AVAILABLE:
    print("\n" + "="*70)
    print("SHAP FEATURE IMPORTANCE ANALYSIS")
    print("="*70)
    
    try:
        # Create a wrapper function for SHAP that reshapes input
        def attention_predict_wrapper(X_flat):
            """Convert flattened input back to 3D for model prediction."""
            if X_flat.ndim == 1:
                X_flat = X_flat.reshape(1, -1)
            
            # Reshape from (batch, flat) to (batch, timesteps, features)
            # X_train.shape[1]=24 (timesteps), X_train.shape[2]=26 (features)
            n_samples = X_flat.shape[0]
            X_3d = X_flat.reshape(n_samples, X_train.shape[1], X_train.shape[2])
            
            # Return predictions
            return model.predict(X_3d, verbose=0).flatten()
        
        # Prepare sample data for SHAP (use first 50 test samples)
        n_shap_samples = min(50, len(X_test))
        X_shap_samples = X_test[:n_shap_samples].reshape(n_shap_samples, -1)  # Flatten to 2D
        X_background = X_shap_samples[:10]  # Use 10 background samples
        
        print("Initializing SHAP KernelExplainer (model-agnostic)...")
        explainer = shap.KernelExplainer(attention_predict_wrapper, X_background)
        
        print("Computing SHAP values for test samples...")
        # Use first 20 test samples for explanation
        shap_values = explainer.shap_values(X_shap_samples[:20], nsamples=100)
        shap_values = np.array(shap_values).squeeze()  # Handle output shape
        
        # Create feature names for ALL 26 features across 24 timesteps
        # 26 features = 13 (eMalahleni) + 13 (Middelburg)
        stations_list = ['eMalahleni', 'Middelburg']
        em_features = list(pd.read_csv('eMalahleniIM.csv', sep=';', nrows=1, index_col=0).columns)
        feature_names = []
        for t in range(X_train.shape[1]):
            for station in stations_list:
                for feat in em_features:
                    feature_names.append(f"{station}_{feat}(t-{X_train.shape[1]-t})")
        
        # Ensure feature names match X_shap_samples shape
        if len(feature_names) != X_shap_samples.shape[1]:
            print(f"Warning: feature_names length {len(feature_names)} != X_shap_samples width {X_shap_samples.shape[1]}")
            # Fallback: create generic feature names
            feature_names = [f"f{i}" for i in range(X_shap_samples.shape[1])]
        
        # SHAP summary plot
        plt.figure(figsize=(12, 8))
        shap.summary_plot(shap_values, X_shap_samples[:20], 
                         feature_names=feature_names, show=False, max_display=20)
        plt.title('CNN-LSTM Attention Model SHAP Feature Importance (Top 20)', fontweight='bold', size=14)
        plt.tight_layout()
        plt.savefig('Results/multistation_cnnlstm_attention_shap_summary.png', dpi=300, bbox_inches='tight')
        print("SHAP summary plot saved to: Results/multistation_cnnlstm_attention_shap_summary.png")
        plt.close()
        
        # SHAP bar plot
        plt.figure(figsize=(10, 6))
        shap.summary_plot(shap_values, X_shap_samples[:20], 
                         feature_names=feature_names, plot_type="bar", show=False, max_display=15)
        plt.title('CNN-LSTM Attention Model SHAP Feature Importance (Mean)', fontweight='bold', size=14)
        plt.tight_layout()
        plt.savefig('Results/multistation_cnnlstm_attention_shap_bar.png', dpi=300, bbox_inches='tight')
        print("SHAP bar plot saved to: Results/multistation_cnnlstm_attention_shap_bar.png")
        plt.close()
        
        print("✅ SHAP analysis completed successfully!")
        
    except Exception as e:
        print(f"⚠️ SHAP analysis failed: {e}")
        print("Continuing without SHAP analysis...")
else:
    print("\n⚠️ SHAP not available. Install with: pip install shap")


print("\n" + "="*70)
print("SCRIPT COMPLETE")
print("="*70)
print(f"Finished at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
