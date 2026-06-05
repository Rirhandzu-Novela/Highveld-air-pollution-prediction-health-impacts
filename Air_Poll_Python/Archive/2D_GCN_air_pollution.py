"""
2D GCN Air Pollution Prediction
===============================
Graph Convolutional Network for multi-station air pollution prediction using 2D spatial-temporal data
"""

# Import Libraries
import numpy as np
import pandas as pd
from math import sqrt
import matplotlib.pyplot as plt
from matplotlib import rcParams
import time
from datetime import datetime

# PyTorch and PyTorch Geometric
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GCNConv, global_mean_pool, BatchNorm
from torch_geometric.data import Data, DataLoader
from torch_geometric.utils import dense_to_sparse

# Sklearn
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# SHAP for interpretability
import shap

# Suppress warnings
import warnings
warnings.filterwarnings('ignore')

print(f"PyTorch version: {torch.__version__}")
print(f"2D GCN started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def series_to_supervised(data, n_in=1, n_out=1, dropnan=True):
    """Convert time series data to supervised learning format."""
    n_vars = 1 if type(data) is list else data.shape[1]
    df = pd.DataFrame(data)
    cols, names = list(), list()
    
    # Input sequence (t-n, ... t-1)
    for i in range(n_in, 0, -1):
        cols.append(df.shift(i))
        names += [('var%d(t-%d)' % (j+1, i)) for j in range(n_vars)]
    
    # Forecast sequence (t, t+1, ... t+n)
    for i in range(0, n_out):
        cols.append(df.shift(-i))
        if i == 0:
            names += [('var%d(t)' % (j+1)) for j in range(n_vars)]
        else:
            names += [('var%d(t+%d)' % (j+1, i)) for j in range(n_vars)]
    
    agg = pd.concat(cols, axis=1)
    agg.columns = names
    
    if dropnan:
        agg.dropna(inplace=True)
    return agg

def create_2d_spatial_graph(n_stations=2, n_features=13, correlation_threshold=0.3):
    """Create 2D spatial graph connecting stations and features."""
    total_nodes = n_stations * n_features
    
    # Create spatial adjacency matrix
    adj_matrix = np.zeros((total_nodes, total_nodes))
    
    # Connect features within same station (intra-station connections)
    for station in range(n_stations):
        start_idx = station * n_features
        end_idx = (station + 1) * n_features
        
        # Full connections within station
        for i in range(start_idx, end_idx):
            for j in range(start_idx, end_idx):
                if i != j:
                    adj_matrix[i, j] = 1.0
    
    # Connect same features across stations (inter-station connections)
    for feature in range(n_features):
        for station1 in range(n_stations):
            for station2 in range(station1 + 1, n_stations):
                idx1 = station1 * n_features + feature
                idx2 = station2 * n_features + feature
                adj_matrix[idx1, idx2] = 1.0
                adj_matrix[idx2, idx1] = 1.0
    
    # Add self-connections
    np.fill_diagonal(adj_matrix, 1.0)
    
    # Convert to edge list
    edge_index, edge_weights = dense_to_sparse(torch.tensor(adj_matrix, dtype=torch.float))
    
    return edge_index, edge_weights

def create_2d_graph_data_list(X, Y, n_stations=2, n_features=13):
    """Convert 2D multi-station data to graph format."""
    graph_data_list = []
    
    # Create base graph structure for 2D spatial connections
    edge_index, edge_weights = create_2d_spatial_graph(n_stations, n_features)
    total_nodes = n_stations * n_features
    
    for i in range(len(X)):
        # Reshape X from flat to 2D: [stations, features]
        x_2d = X[i].reshape(n_stations, n_features)
        
        # Flatten to create node features: [total_nodes, 1] 
        node_features = torch.tensor(x_2d.flatten().reshape(-1, 1), dtype=torch.float32)
        
        # Create graph data object
        data = Data(
            x=node_features,
            edge_index=edge_index.long(),
            edge_attr=edge_weights.unsqueeze(-1),
            y=torch.tensor([Y[i]], dtype=torch.float32),
            n_stations=torch.tensor([n_stations], dtype=torch.long),
            n_features=torch.tensor([n_features], dtype=torch.long)
        )
        graph_data_list.append(data)
    
    return graph_data_list

# =============================================================================
# LOAD MULTI-STATION DATASET
# =============================================================================

print("Loading multi-station dataset...")

# Load and merge two stations 
stations = ['eMalahleni', 'Middelburg']
dfs = []

for st in stations:
    try:
        df = pd.read_csv(f'{st}IM.csv', sep=';', header=0, index_col=0)
        # Rename columns to keep track of station
        df.columns = [f'{st}_{c}' for c in df.columns]
        dfs.append(df)
        print(f"Loaded {st} station: {df.shape}")
    except FileNotFoundError:
        print(f"Warning: Could not load {st}IM.csv - file not found")

if len(dfs) == 2:
    # Merge datasets
    data = pd.concat(dfs, axis=1).dropna()
    values = data.values
    print(f"Merged dataset shape: {data.shape}")
    print(f"Columns: {list(data.columns)}")
else:
    print("Error: Could not load both station files")
    exit(1)

n_stations = len(stations)
n_vars = values.shape[1]
n_feats = int(n_vars / n_stations)

print(f"Number of stations: {n_stations}")
print(f"Features per station: {n_feats}")
print(f"Total variables: {n_vars}")

# =============================================================================
# DATA PREPROCESSING
# =============================================================================

print("Preprocessing data...")

# Ensure all data is float
values = values.astype('float32')

# Normalize features
scaler = MinMaxScaler(feature_range=(0, 1))
scaled = scaler.fit_transform(values)

# Frame as supervised learning
reframed = series_to_supervised(scaled, 1, 1)

# Drop columns we don't want to predict (keep only first station's PM2.5)
drop = list(range(n_vars+1, 2*n_vars))
reframed.drop(reframed.columns[drop], axis=1, inplace=True)
values = reframed.values

print(f"Supervised data shape: {values.shape}")

# Split into input and output
X = values[:,:-1]  # All columns except last
Y = values[:,-1]   # Last column (PM2.5 prediction target)

print(f"X shape: {X.shape}")
print(f"Y shape: {Y.shape}")

# Convert to graph data format
graph_data = create_2d_graph_data_list(X, Y, n_stations, n_feats)
print(f"Created {len(graph_data)} 2D graph samples")

# =============================================================================
# DATA SPLITTING
# =============================================================================

print("Splitting data...")

# Split data: 60% train, 20% validation, 20% test
n_samples = len(graph_data)
indices = list(range(n_samples))

train_val_idx, test_idx = train_test_split(indices, test_size=0.2, random_state=42)
train_idx, val_idx = train_test_split(train_val_idx, test_size=0.25, random_state=42)

train_data = [graph_data[i] for i in train_idx]
val_data = [graph_data[i] for i in val_idx]
test_data = [graph_data[i] for i in test_idx]

print(f"Train: {len(train_data)} samples")
print(f"Val: {len(val_data)} samples")
print(f"Test: {len(test_data)} samples")

# =============================================================================
# 2D GCN MODEL DEFINITION
# =============================================================================

class GCN2DModel(nn.Module):
    """2D Graph Convolutional Network for multi-station air pollution prediction."""
    
    def __init__(self, input_dim=1, hidden_dim=64, n_layers=3, dropout=0.2, 
                 n_stations=2, n_features=13):
        super(GCN2DModel, self).__init__()
        
        self.n_layers = n_layers
        self.n_stations = n_stations
        self.n_features = n_features
        self.dropout = dropout
        
        # GCN layers for spatial modeling
        self.convs = nn.ModuleList()
        self.batch_norms = nn.ModuleList()
        
        # Input layer
        self.convs.append(GCNConv(input_dim, hidden_dim))
        self.batch_norms.append(BatchNorm(hidden_dim))
        
        # Hidden layers with residual connections
        for _ in range(n_layers - 2):
            self.convs.append(GCNConv(hidden_dim, hidden_dim))
            self.batch_norms.append(BatchNorm(hidden_dim))
        
        # Output layer
        self.convs.append(GCNConv(hidden_dim, hidden_dim))
        self.batch_norms.append(BatchNorm(hidden_dim))
        
        # 2D spatial aggregation for multi-station modeling
        self.spatial_aggregation = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim * 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim * 2, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout)
        )
        
        # Final prediction head
        self.predictor = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim // 2, hidden_dim // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim // 4, 1),
            nn.Sigmoid()
        )
    
    def forward(self, data):
        x, edge_index, batch = data.x, data.edge_index, data.batch
        
        # GCN layers with residual connections
        for i, (conv, bn) in enumerate(zip(self.convs, self.batch_norms)):
            x_residual = x if i > 0 and x.size(-1) == conv.out_channels else None
            
            x = conv(x, edge_index)
            x = bn(x)
            x = F.relu(x)
            x = F.dropout(x, p=self.dropout, training=self.training)
            
            # Residual connection
            if x_residual is not None:
                x = x + x_residual
        
        # Global pooling to get graph-level representation
        x_pooled = global_mean_pool(x, batch)
        
        # 2D spatial aggregation
        x_spatial = self.spatial_aggregation(x_pooled)
        
        # Final prediction
        out = self.predictor(x_spatial)
        
        return out.squeeze()

# =============================================================================
# MODEL TRAINING SETUP
# =============================================================================

# Device configuration
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Create data loaders
batch_size = 32
train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

# Initialize model
model = GCN2DModel(
    input_dim=1,
    hidden_dim=64,
    n_layers=3,
    dropout=0.2,
    n_stations=n_stations,
    n_features=n_feats
).to(device)

# Count parameters
total_params = sum(p.numel() for p in model.parameters())
print(f"Model parameters: {total_params:,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001, weight_decay=1e-5)
scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=10, gamma=0.7)

# =============================================================================
# TRAINING FUNCTIONS
# =============================================================================

def train_epoch(model, train_loader, optimizer, criterion, device):
    """Train for one epoch."""
    model.train()
    total_loss = 0
    
    for batch in train_loader:
        batch = batch.to(device)
        optimizer.zero_grad()
        
        out = model(batch)
        loss = criterion(out, batch.y)
        
        loss.backward()
        optimizer.step()
        
        total_loss += loss.item()
    
    return total_loss / len(train_loader)

def evaluate_model(model, data_loader, criterion, device):
    """Evaluate the model."""
    model.eval()
    total_loss = 0
    predictions = []
    targets = []
    
    with torch.no_grad():
        for batch in data_loader:
            batch = batch.to(device)
            out = model(batch)
            loss = criterion(out, batch.y)
            
            total_loss += loss.item()
            predictions.extend(out.cpu().numpy())
            targets.extend(batch.y.cpu().numpy())
    
    return total_loss / len(data_loader), np.array(predictions), np.array(targets)

# =============================================================================
# MODEL TRAINING
# =============================================================================

print("Starting 2D GCN training...")

# Training parameters
epochs = 100
best_val_loss = float('inf')
patience = 15
patience_counter = 0

# Training history
train_losses = []
val_losses = []

start_time = time.time()

for epoch in range(epochs):
    # Train
    train_loss = train_epoch(model, train_loader, optimizer, criterion, device)
    train_losses.append(train_loss)
    
    # Validate
    val_loss, _, _ = evaluate_model(model, val_loader, criterion, device)
    val_losses.append(val_loss)
    
    # Learning rate scheduling
    scheduler.step()
    
    # Print progress
    if (epoch + 1) % 10 == 0:
        print(f'Epoch [{epoch+1}/{epochs}] - Train Loss: {train_loss:.6f}, Val Loss: {val_loss:.6f}')
    
    # Early stopping
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        # Save best model
        torch.save(model.state_dict(), '2d_gcn_best_model.pth')
    else:
        patience_counter += 1
    
    if patience_counter >= patience:
        print(f'Early stopping at epoch {epoch+1}')
        break

training_time = time.time() - start_time
print(f"Training completed in {training_time:.2f} seconds")

# Load best model for evaluation
model.load_state_dict(torch.load('2d_gcn_best_model.pth'))

# =============================================================================
# MODEL EVALUATION
# =============================================================================

print("Evaluating 2D GCN model...")

# Test evaluation
test_loss, test_predictions, test_targets = evaluate_model(model, test_loader, criterion, device)

# Unscale predictions for evaluation
def unscale(scaled_value):
    """Unscale normalized values back to original scale."""
    return scaled_value * (scaler.data_max_[0] - scaler.data_min_[0]) + scaler.data_min_[0]

predictions_unscaled = unscale(test_predictions)
targets_unscaled = unscale(test_targets)

# Calculate metrics
mse = mean_squared_error(targets_unscaled, predictions_unscaled)
rmse = sqrt(mse)
mae = mean_absolute_error(targets_unscaled, predictions_unscaled)
r2 = r2_score(targets_unscaled, predictions_unscaled)

print(f"\n2D GCN Model Performance:")
print(f"Test MSE: {mse:.6f}")
print(f"Test RMSE: {rmse:.6f}")
print(f"Test MAE: {mae:.6f}")
print(f"Test R²: {r2:.6f}")

# =============================================================================
# VISUALIZATIONS
# =============================================================================

print("Creating visualizations...")

# Set up plotting parameters
rcParams['font.weight'] = 'bold'
plt.style.use('default')

# 1. Training History
plt.figure(figsize=(15, 5))

# Training loss
plt.subplot(1, 3, 1)
plt.plot(train_losses, label='Training Loss', linewidth=2)
plt.plot(val_losses, label='Validation Loss', linewidth=2)
plt.xlabel('Epoch', fontweight='bold')
plt.ylabel('Loss', fontweight='bold')
plt.title('2D GCN Training History', fontweight='bold')
plt.legend()
plt.grid(True, alpha=0.3)

# 2. Predictions vs Actual
plt.subplot(1, 3, 2)
plt.scatter(targets_unscaled, predictions_unscaled, alpha=0.5, s=20)
plt.plot([targets_unscaled.min(), targets_unscaled.max()], 
         [targets_unscaled.min(), targets_unscaled.max()], 'r--', linewidth=2)
plt.xlabel('Actual PM2.5', fontweight='bold')
plt.ylabel('Predicted PM2.5', fontweight='bold')
plt.title(f'2D GCN Predictions (R² = {r2:.3f})', fontweight='bold')
plt.grid(True, alpha=0.3)

# 3. Residuals
plt.subplot(1, 3, 3)
residuals = predictions_unscaled - targets_unscaled
plt.scatter(targets_unscaled, residuals, alpha=0.5, s=20)
plt.axhline(y=0, color='r', linestyle='--', linewidth=2)
plt.xlabel('Actual PM2.5', fontweight='bold')
plt.ylabel('Residuals', fontweight='bold')
plt.title('Residual Analysis', fontweight='bold')
plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('2d_gcn_results.png', dpi=300, bbox_inches='tight')
plt.show()

# 4. Quantile Analysis
print("Performing quantile analysis...")

errors = np.abs(predictions_unscaled - targets_unscaled)
quantiles = pd.qcut(targets_unscaled, q=5, labels=['Very Low', 'Low', 'Medium', 'High', 'Very High'])
bins = pd.qcut(targets_unscaled, q=5, retbins=True)[1]

quantile_errors = []
for i in range(len(bins) - 1):
    group_indices = np.where((targets_unscaled >= bins[i]) & (targets_unscaled < bins[i+1]))[0]
    quantile_errors.append(errors[group_indices].mean())

rounded_bins = np.round(bins, decimals=3)

plt.figure(figsize=(10, 6))
plt.plot(range(1, len(quantiles.categories) + 1), quantile_errors, marker='o', linewidth=2, markersize=8)
plt.xlabel('Quantile', fontweight='bold', size=12)
plt.ylabel('Average Error', fontweight='bold', size=12)
plt.title('2D GCN Quantile Analysis', fontweight='bold', size=14)
plt.xticks(range(1, len(quantiles.categories) + 1), 
          [f'{rounded_bins[i]:.2f}-{rounded_bins[i+1]:.2f}' for i in range(len(rounded_bins) - 1)], 
          rotation=45)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('2d_gcn_quantile_analysis.png', dpi=300, bbox_inches='tight')
plt.show()

# =============================================================================
# SHAP ANALYSIS FOR 2D MODEL INTERPRETABILITY
# =============================================================================

print("Performing SHAP analysis for 2D GCN model interpretability...")

# Create a wrapper function for SHAP analysis
def gcn_predict_wrapper(X_flat):
    """Wrapper function for GCN prediction compatible with SHAP."""
    predictions = []
    
    model.eval()
    with torch.no_grad():
        for x_sample in X_flat:
            # Convert to graph data format
            graph_sample = create_2d_graph_data_list([x_sample], [0], n_stations, n_feats)[0]
            graph_sample = graph_sample.to(device)
            
            # Create a mini-batch
            loader = DataLoader([graph_sample], batch_size=1, shuffle=False)
            
            for batch in loader:
                pred = model(batch).cpu().numpy()
                predictions.append(pred[0] if isinstance(pred, np.ndarray) else pred)
    
    return np.array(predictions)

# Prepare sample data for SHAP
n_shap_samples = min(100, len(test_data))
X_shap = np.array([test_data[i].x.cpu().numpy().flatten() for i in range(n_shap_samples)])
X_background = X_shap[:50]  # Use first 50 samples as background

try:
    print("Initializing SHAP KernelExplainer...")
    explainer = shap.KernelExplainer(gcn_predict_wrapper, X_background)
    
    print("Computing SHAP values...")
    shap_values = explainer.shap_values(X_shap[:20], nsamples=100)
    
    # Create feature names for 2D model
    feature_names = []
    for station_idx, station in enumerate(stations):
        for feat_idx in range(n_feats):
            feature_names.append(f'{station}_feat_{feat_idx}')
    
    # SHAP summary plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:20], feature_names=feature_names, show=False)
    plt.title('2D GCN SHAP Feature Importance Summary', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('2d_gcn_shap_summary.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # SHAP bar plot
    plt.figure(figsize=(10, 6))
    shap.summary_plot(shap_values, X_shap[:20], feature_names=feature_names, plot_type="bar", show=False)
    plt.title('2D GCN SHAP Feature Importance (Mean)', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('2d_gcn_shap_bar.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("✅ SHAP analysis completed successfully!")
    
except Exception as e:
    print(f"⚠️ SHAP analysis encountered an error: {e}")
    print("Continuing without SHAP analysis...")

# =============================================================================
# SAVE RESULTS
# =============================================================================

print("Saving results...")

# Save predictions
results_df = pd.DataFrame({
    'Actual': targets_unscaled,
    'Predicted': predictions_unscaled,
    'Error': errors
})
results_df.to_csv('2d_gcn_predictions.csv', index=False)

# Save model metrics
metrics_df = pd.DataFrame({
    'Model': ['2D GCN'],
    'MSE': [mse],
    'RMSE': [rmse],
    'MAE': [mae],
    'R2': [r2],
    'Training_Time': [training_time],
    'Parameters': [total_params],
    'Stations': [n_stations],
    'Features_per_Station': [n_feats]
})
metrics_df.to_csv('2d_gcn_metrics.csv', index=False)

print(f"✅ 2D GCN completed successfully!")
print(f"📁 Results saved:")
print(f"  📊 Predictions: '2d_gcn_predictions.csv'")
print(f"  📈 Metrics: '2d_gcn_metrics.csv'")
print(f"  🎯 Best model: '2d_gcn_best_model.pth'")
print(f"  📋 Visualizations: '2d_gcn_results.png', '2d_gcn_quantile_analysis.png'")
if 'shap_values' in locals():
    print(f"  🔍 SHAP analysis: '2d_gcn_shap_summary.png', '2d_gcn_shap_bar.png'")
print(f"  ⏱️ Total time: {time.time() - start_time:.2f} seconds")