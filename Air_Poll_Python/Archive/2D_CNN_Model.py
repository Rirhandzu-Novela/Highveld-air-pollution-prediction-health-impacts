"""
2D CNN Production Model - Training and Evaluation
Uses best hyperparameters from grid search
Includes: Predictions, Metrics, Visualizations, SHAP Analysis
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import json
import warnings
warnings.filterwarnings('ignore')

# Set random seeds
np.random.seed(42)
tf.random.set_seed(42)

print("="*80)
print("2D CNN MODEL - TRAINING WITH OPTIMAL PARAMETERS")
print("="*80)

# ============================================================================
# 1. LOAD BEST PARAMETERS
# ============================================================================
print("\n[1/7] Loading best parameters from grid search...")

try:
    with open('2d_cnn_best_params.json', 'r') as f:
        best_params = json.load(f)
    print("✓ Best parameters loaded")
except FileNotFoundError:
    print("⚠ No best_params.json found, using defaults")
    best_params = {
        'filters': 64,
        'kernel_size': 3,
        'dropout': 0.3,
        'dense_units': 128,
        'learning_rate': 0.001,
        'batch_size': 32,
        'n_in': 1
    }

print("\nBest Parameters:")
for param, value in best_params.items():
    print(f"  {param}: {value}")

# ============================================================================
# 2. LOAD AND PREPARE DATA
# ============================================================================
print("\n[2/7] Loading data...")

em = pd.read_csv('eMalahleniIM.csv', sep=';', header=0, index_col=0)
mb = pd.read_csv('MiddelburgIM.csv', sep=';', header=0, index_col=0)

min_len = min(len(em), len(mb))
em = em[:min_len]
mb = mb[:min_len]

target = em['pm2.5'].values.reshape(-1, 1)
em_features = em.drop(['pm2.5'], axis=1).values
mb_features = mb.drop(['pm2.5'], axis=1).values

scaler_em = MinMaxScaler()
scaler_mb = MinMaxScaler()
scaler_target = MinMaxScaler()

em_norm = scaler_em.fit_transform(em_features)
mb_norm = scaler_mb.fit_transform(mb_features)
target_norm = scaler_target.fit_transform(target)

print(f"Data loaded: eMalahleni {em.shape}, Middelburg {mb.shape}")

# ============================================================================
# 3. CREATE 2D SEQUENCES
# ============================================================================
print("\n[3/7] Creating 2D sequences...")

def create_2d_sequences(em_data, mb_data, target_data, n_in=1):
    X, y = [], []
    
    for i in range(len(em_data) - n_in):
        em_window = em_data[i:i+n_in]
        mb_window = mb_data[i:i+n_in]
        combined = np.vstack([em_window, mb_window])
        combined_2d = combined.reshape(2, 12, 1)
        
        target_window = target_data[i+n_in]
        
        X.append(combined_2d)
        y.append(target_window)
    
    return np.array(X), np.array(y)

X, y = create_2d_sequences(em_norm, mb_norm, target_norm, 
                           n_in=best_params['n_in'])

print(f"Sequences created: X {X.shape}, y {y.shape}")

# ============================================================================
# 4. SPLIT DATA
# ============================================================================
print("\n[4/7] Splitting data...")

try:
    with open('lstm_train_val_test_indices.json', 'r') as f:
        indices = json.load(f)
    print("Using standardized indices")
    train_idx = indices['train_indices']
    val_idx = indices['val_indices']
    test_idx = indices['test_indices']
except FileNotFoundError:
    print("Creating new indices")
    n_samples = len(X)
    train_size = int(0.6 * n_samples)
    val_size = int(0.2 * n_samples)
    indices = np.random.permutation(n_samples)
    train_idx = indices[:train_size].tolist()
    val_idx = indices[train_size:train_size+val_size].tolist()
    test_idx = indices[train_size+val_size:].tolist()

max_valid_idx = len(X)
train_idx = [i for i in train_idx if i < max_valid_idx]
val_idx = [i for i in val_idx if i < max_valid_idx]
test_idx = [i for i in test_idx if i < max_valid_idx]

X_train, y_train = X[train_idx], y[train_idx]
X_val, y_val = X[val_idx], y[val_idx]
X_test, y_test = X[test_idx], y[test_idx]

print(f"Train: {X_train.shape}, Val: {X_val.shape}, Test: {X_test.shape}")

# ============================================================================
# 5. BUILD AND TRAIN MODEL
# ============================================================================
print("\n[5/7] Building and training model...")

keras.backend.clear_session()

model = keras.Sequential([
    layers.Input(shape=(2, 12, 1)),
    
    layers.Conv2D(best_params['filters'], best_params['kernel_size'], 
                 padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(best_params['dropout']),
    
    layers.Conv2D(best_params['filters'], best_params['kernel_size'], 
                 padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(best_params['dropout']),
    
    layers.Flatten(),
    layers.Dense(best_params['dense_units'], activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(best_params['dropout']),
    
    layers.Dense(32, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(1)
])

optimizer = keras.optimizers.Adam(
    learning_rate=best_params['learning_rate']
)
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
        verbose=1
    )
]

print(f"\nTraining with {len(X_train)} samples...")
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=60,
    batch_size=best_params['batch_size'],
    callbacks=callbacks,
    verbose=1
)

print(f"\nTraining completed in {len(history.history['loss'])} epochs")

# ============================================================================
# 6. EVALUATE MODEL
# ============================================================================
print("\n[6/7] Evaluating model...")

# Predictions
y_train_pred = model.predict(X_train, verbose=0).flatten()
y_val_pred = model.predict(X_val, verbose=0).flatten()
y_test_pred = model.predict(X_test, verbose=0).flatten()

# Metrics function
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
test_metrics = calc_metrics(y_test, y_test_pred, "Test")

metrics_df = pd.DataFrame([train_metrics, val_metrics, test_metrics])

print("\n" + "="*80)
print("PERFORMANCE METRICS")
print("="*80)
print(metrics_df.to_string(index=False))

# Save metrics
metrics_df.to_csv('Results/eMa2DCNN_metrics_PM2.csv', index=False)
print("\nMetrics saved to: Results/eMa2DCNN_metrics_PM2.csv")

# ============================================================================
# 7. VISUALIZATIONS
# ============================================================================
print("\n[7/7] Creating visualizations...")

fig = plt.figure(figsize=(16, 12))

# Training history
ax1 = plt.subplot(2, 3, 1)
ax1.plot(history.history['loss'], label='Train Loss', linewidth=2)
ax1.plot(history.history['val_loss'], label='Val Loss', linewidth=2)
ax1.set_title('Model Loss', fontsize=12, fontweight='bold')
ax1.set_xlabel('Epoch')
ax1.set_ylabel('Loss (MSE)')
ax1.legend()
ax1.grid(alpha=0.3)

ax2 = plt.subplot(2, 3, 2)
ax2.plot(history.history['mae'], label='Train MAE', linewidth=2)
ax2.plot(history.history['val_mae'], label='Val MAE', linewidth=2)
ax2.set_title('Model MAE', fontsize=12, fontweight='bold')
ax2.set_xlabel('Epoch')
ax2.set_ylabel('MAE')
ax2.legend()
ax2.grid(alpha=0.3)

# Predictions vs Actual
ax3 = plt.subplot(2, 3, 3)
ax3.scatter(y_test, y_test_pred, alpha=0.6, s=20)
ax3.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 
         'r--', lw=2, label='Perfect Prediction')
ax3.set_title(f'Test Set Predictions (R²={test_metrics["R²"]:.4f})', 
              fontsize=12, fontweight='bold')
ax3.set_xlabel('Actual (normalized)')
ax3.set_ylabel('Predicted (normalized)')
ax3.legend()
ax3.grid(alpha=0.3)

# Residuals
ax4 = plt.subplot(2, 3, 4)
residuals = y_test - y_test_pred
ax4.scatter(y_test_pred, residuals, alpha=0.6, s=20)
ax4.axhline(y=0, color='r', linestyle='--', lw=2)
ax4.set_title('Residual Plot', fontsize=12, fontweight='bold')
ax4.set_xlabel('Predicted (normalized)')
ax4.set_ylabel('Residuals')
ax4.grid(alpha=0.3)

# Distribution of residuals
ax5 = plt.subplot(2, 3, 5)
ax5.hist(residuals, bins=50, edgecolor='black', alpha=0.7)
ax5.set_title('Residual Distribution', fontsize=12, fontweight='bold')
ax5.set_xlabel('Residuals')
ax5.set_ylabel('Frequency')
ax5.grid(alpha=0.3)

# Error metrics comparison
ax6 = plt.subplot(2, 3, 6)
metrics_names = ['MAE', 'RMSE', 'MAPE']
train_vals = [train_metrics['MAE'], train_metrics['RMSE'], train_metrics['MAPE']]
val_vals = [val_metrics['MAE'], val_metrics['RMSE'], val_metrics['MAPE']]
test_vals = [test_metrics['MAE'], test_metrics['RMSE'], test_metrics['MAPE']]

x = np.arange(len(metrics_names))
width = 0.25

ax6.bar(x - width, train_vals, width, label='Train', alpha=0.8)
ax6.bar(x, val_vals, width, label='Val', alpha=0.8)
ax6.bar(x + width, test_vals, width, label='Test', alpha=0.8)

ax6.set_ylabel('Error')
ax6.set_title('Error Metrics Comparison', fontsize=12, fontweight='bold')
ax6.set_xticks(x)
ax6.set_xticklabels(metrics_names)
ax6.legend()
ax6.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('Results/2D_CNN_Training_Analysis.png', dpi=300, bbox_inches='tight')
print("Training analysis saved to: Results/2D_CNN_Training_Analysis.png")

# Save predictions
predictions_df = pd.DataFrame({
    'Actual': y_test,
    'Predicted': y_test_pred,
    'Residual': residuals,
    'Abs_Error': np.abs(residuals)
})
predictions_df.to_csv('Results/2D_CNN_Predictions.csv', index=False)
print("Predictions saved to: Results/2D_CNN_Predictions.csv")

# Save model
model.save('2d_cnn_best_model.h5')
print("Model saved to: 2d_cnn_best_model.h5")

print("\n" + "="*80)
print("2D CNN TRAINING COMPLETE")
print("="*80)
print(f"\nFinal Test R² Score: {test_metrics['R²']:.4f}")
print(f"Final Test MAE: {test_metrics['MAE']:.4f}")
print(f"Final Test RMSE: {test_metrics['RMSE']:.4f}")
