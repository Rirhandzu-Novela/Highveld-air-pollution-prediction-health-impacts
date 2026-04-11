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
from torch_geometric.nn import TransformerConv, global_mean_pool, BatchNorm
from torch_geometric.data import Data, DataLoader
from torch_geometric.utils import dense_to_sparse

# Sklearn
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# JSON and utilities
import json

# SHAP for interpretability
import shap

# Suppress warnings
import warnings
warnings.filterwarnings('ignore')

print(f"PyTorch version: {torch.__version__}")
print(f"2D Graph Transformer FIXED started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# =============================================================================
# FIXED HELPER FUNCTIONS
# =============================================================================

def create_deterministic_spatial_graph(n_stations=2, n_features=13, feature_correlations=None,
                                     inter_station_weight=0.8, cross_mult=0.5):
    """Create DETERMINISTIC 2D spatial graph from data correlations."""
    total_nodes = n_stations * n_features
    adj_matrix = np.zeros((total_nodes, total_nodes))
    
    # 1. Intra-station connections (use provided correlations)
    for station in range(n_stations):
        start_idx = station * n_features
        for i in range(n_features):
            for j in range(n_features):
                if i != j:
                    weight = 0.3  # Default weak connection
                    if feature_correlations is not None:
                        weight = abs(feature_correlations[i, j])
                    adj_matrix[start_idx + i, start_idx + j] = weight
    
    # 2. Inter-station connections (same features across stations) - Use data-driven weight
    for feature in range(n_features):
        for station1 in range(n_stations):
            for station2 in range(station1 + 1, n_stations):
                idx1 = station1 * n_features + feature
                idx2 = station2 * n_features + feature
                weight = inter_station_weight  # Data-driven weight
                adj_matrix[idx1, idx2] = weight
                adj_matrix[idx2, idx1] = weight
    
    # 3. Cross-feature inter-station connections (weaker but deterministic)
    for station1 in range(n_stations):
        for station2 in range(station1 + 1, n_stations):
            start1, end1 = station1 * n_features, (station1 + 1) * n_features
            start2, end2 = station2 * n_features, (station2 + 1) * n_features
            
            for i in range(start1, end1):
                for j in range(start2, end2):
                    if feature_correlations is not None:
                        # Use data-driven weights for cross-feature connections
                        weight = abs(feature_correlations[i % n_features, j % n_features]) * cross_mult
                    else:
                        weight = 0.25  # Fallback default
                    adj_matrix[i, j] = weight
                    adj_matrix[j, i] = weight
    
    # Add self-connections
    np.fill_diagonal(adj_matrix, 1.0)
    
    # Convert to edge list
    edge_index, edge_weights = dense_to_sparse(torch.tensor(adj_matrix, dtype=torch.float))
    
    return edge_index, edge_weights

def create_temporal_positional_encoding(seq_length, d_model):
    """Create temporal positional encoding for sequence data."""
    pe = torch.zeros(seq_length, d_model)
    position = torch.arange(0, seq_length, dtype=torch.float).unsqueeze(1)
    
    div_term = torch.exp(torch.arange(0, d_model, 2).float() * 
                        -(np.log(10000.0) / d_model))
    
    pe[:, 0::2] = torch.sin(position * div_term)
    if d_model % 2 == 1:
        pe[:, 1::2] = torch.cos(position * div_term[:-1])
    else:
        pe[:, 1::2] = torch.cos(position * div_term)
    
    return pe

def create_spatial_positional_encoding(n_stations, n_features, d_model):
    """Create spatial positional encoding for multi-station data."""
    total_nodes = n_stations * n_features
    pe = torch.zeros(total_nodes, d_model)
    
    for station in range(n_stations):
        for feature in range(n_features):
            node_id = station * n_features + feature
            position = node_id
            
            div_term = torch.exp(torch.arange(0, d_model, 2).float() * 
                               -(np.log(10000.0) / d_model))
            
            pe[node_id, 0::2] = torch.sin(position * div_term)
            if d_model % 2 == 1:
                pe[node_id, 1::2] = torch.cos(position * div_term[:-1])
            else:
                pe[node_id, 1::2] = torch.cos(position * div_term)
    
    return pe

def create_graph_sequence_data_fixed(X, Y, n_stations=2, n_features=13, seq_length=24, 
                                   feature_correlations=None, inter_station_weight=0.8, cross_mult=0.5):
    """Convert sequence data to graph format with proper temporal handling."""
    graph_data_list = []
    
    # Create deterministic graph structure with data-driven correlations
    edge_index, edge_attr = create_deterministic_spatial_graph(n_stations, n_features, 
                                                               feature_correlations=feature_correlations,
                                                               inter_station_weight=inter_station_weight,
                                                               cross_mult=cross_mult)
    total_nodes = n_stations * n_features
    
    for i in range(len(X)):
        # X[i] shape: [stations * features * seq_length] flattened
        # Reshape to: [stations, features, seq_length]
        x_3d = X[i].reshape(n_stations, n_features, seq_length)
        
        # Transpose to [seq_length, stations, features] for proper temporal processing
        x_temporal = x_3d.transpose(2, 0, 1)  # [24, 2, 13]
        
        # Reshape to [seq_length, total_nodes] for graph processing
        node_features = torch.tensor(x_temporal.reshape(seq_length, -1), dtype=torch.float32)
        
        # Create graph data object
        data = Data(
            x=node_features.T,  # [total_nodes, seq_length] - nodes as rows, time as columns
            edge_index=edge_index.long(),
            edge_attr=edge_attr.float(),
            y=torch.tensor([Y[i]], dtype=torch.float32),
            n_stations=torch.tensor([n_stations], dtype=torch.long),
            n_features=torch.tensor([n_features], dtype=torch.long),
            seq_length=torch.tensor([seq_length], dtype=torch.long)
        )
        graph_data_list.append(data)
    
    return graph_data_list

# =============================================================================
# FIXED MODEL COMPONENTS
# =============================================================================

class FixedMultiHeadGraphAttention(nn.Module):
    """FIXED Multi-head graph attention with proper edge attribute handling."""
    
    def __init__(self, in_dim, out_dim, num_heads=8, dropout=0.1):
        super(FixedMultiHeadGraphAttention, self).__init__()
        self.num_heads = num_heads
        self.out_dim = out_dim
        self.head_dim = out_dim // num_heads
        
        assert self.head_dim * num_heads == out_dim
        
        # Use TransformerConv with edge_dim parameter for edge attributes
        self.transformers = nn.ModuleList([
            TransformerConv(in_dim, self.head_dim, heads=1, dropout=dropout, edge_dim=1)
            for _ in range(num_heads)
        ])
        
        self.output_projection = nn.Linear(out_dim, out_dim)
        self.layer_norm = nn.LayerNorm(out_dim)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x, edge_index, edge_attr=None):
        head_outputs = []
        
        for transformer in self.transformers:
            if edge_attr is not None:
                head_out = transformer(x, edge_index, edge_attr.unsqueeze(-1))  # Include edge attributes
            else:
                head_out = transformer(x, edge_index)
            head_outputs.append(head_out)
        
        # Concatenate heads
        multi_head_out = torch.cat(head_outputs, dim=-1)
        
        # Output projection and residual connection
        out = self.output_projection(multi_head_out)
        if x.size(-1) == self.out_dim:
            out = self.layer_norm(out + x)  # Residual connection only if dimensions match
        else:
            out = self.layer_norm(out)
        out = self.dropout(out)
        
        return out

class TemporalTransformerLayer(nn.Module):
    """Temporal transformer layer for sequence modeling."""
    
    def __init__(self, d_model, num_heads=8, d_ff=256, dropout=0.1, seq_length=24):
        super(TemporalTransformerLayer, self).__init__()
        
        self.seq_length = seq_length
        self.d_model = d_model
        
        self.temporal_attention = nn.MultiheadAttention(
            d_model, num_heads, dropout=dropout, batch_first=True
        )
        
        self.feed_forward = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_ff, d_model)
        )
        
        self.layer_norm1 = nn.LayerNorm(d_model)
        self.layer_norm2 = nn.LayerNorm(d_model)
        self.dropout = nn.Dropout(dropout)
        
        # Register temporal positional encoding
        self.register_buffer('temporal_pos_enc', 
                           create_temporal_positional_encoding(seq_length, d_model))
    
    def forward(self, x):
        # x shape: [batch_size, total_nodes, seq_length, d_model]
        batch_size, total_nodes, seq_len, d_model = x.size()
        
        # Process each node's temporal sequence
        temporal_outputs = []
        for node in range(total_nodes):
            node_seq = x[:, node, :, :]  # [batch_size, seq_length, d_model]
            
            # Add temporal positional encoding
            node_seq = node_seq + self.temporal_pos_enc[:seq_len, :].unsqueeze(0)
            
            # Self-attention over time dimension
            attn_out, _ = self.temporal_attention(node_seq, node_seq, node_seq)
            node_seq = self.layer_norm1(node_seq + self.dropout(attn_out))
            
            # Feed-forward
            ff_out = self.feed_forward(node_seq)
            node_seq = self.layer_norm2(node_seq + self.dropout(ff_out))
            
            temporal_outputs.append(node_seq)
        
        # Stack back: [batch_size, total_nodes, seq_length, d_model]
        out = torch.stack(temporal_outputs, dim=1)
        
        return out

class FixedGraphTransformer2DModel(nn.Module):
    """FIXED 2D Graph Transformer with proper temporal and spatial modeling."""
    
    def __init__(self, input_dim=24, d_model=128, num_graph_layers=2, 
                 num_temporal_layers=2, num_heads=8, dropout=0.1,
                 n_stations=2, n_features=13, seq_length=24):
        super(FixedGraphTransformer2DModel, self).__init__()
        
        self.n_stations = n_stations
        self.n_features = n_features
        self.d_model = d_model
        self.seq_length = seq_length
        self.total_nodes = n_stations * n_features
        
        # Input projection: project temporal features to d_model
        self.input_projection = nn.Linear(input_dim, d_model)
        
        # Spatial positional encoding
        self.register_buffer('spatial_pos_encoding', 
                           create_spatial_positional_encoding(n_stations, n_features, d_model))
        
        # Spatial graph attention layers
        self.graph_layers = nn.ModuleList([
            FixedMultiHeadGraphAttention(d_model, d_model, num_heads, dropout)
            for _ in range(num_graph_layers)
        ])
        
        # Temporal transformer layers
        self.temporal_layers = nn.ModuleList([
            TemporalTransformerLayer(d_model, num_heads, d_model*2, dropout, seq_length)
            for _ in range(num_temporal_layers)
        ])
        
        # Global pooling and prediction head
        self.global_pool = global_mean_pool
        
        self.prediction_head = nn.Sequential(
            nn.Linear(d_model, d_model // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 2, d_model // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 4, 1)  # REMOVED SIGMOID - proper regression output
        )
    
    def forward(self, data):
        x, edge_index, edge_attr, batch = data.x, data.edge_index, data.edge_attr, data.batch
        
        # x shape: [total_nodes_in_batch, seq_length]
        batch_size = batch.max().item() + 1
        nodes_per_graph = self.total_nodes
        
        # Reshape to proper batch format
        x = x.view(batch_size, nodes_per_graph, self.seq_length)
        
        # Input projection: [batch_size, total_nodes, seq_length] -> [batch_size, total_nodes, d_model]
        x_proj = self.input_projection(x)
        
        # Add spatial positional encoding
        x_proj = x_proj + self.spatial_pos_encoding.unsqueeze(0)
        
        # Flatten for graph processing: [batch_size * total_nodes, d_model]
        x_flat = x_proj.view(-1, self.d_model)
        
        # Spatial modeling with graph attention
        for graph_layer in self.graph_layers:
            x_flat = graph_layer(x_flat, edge_index, edge_attr)
        
        # Reshape back: [batch_size, total_nodes, d_model]
        x_spatial = x_flat.view(batch_size, nodes_per_graph, self.d_model)
        
        # Expand for temporal processing: [batch_size, total_nodes, seq_length, d_model]
        x_temporal = x_spatial.unsqueeze(2).repeat(1, 1, self.seq_length, 1)
        
        # Temporal modeling
        for temporal_layer in self.temporal_layers:
            x_temporal = temporal_layer(x_temporal)
        
        # Global temporal pooling: average over time dimension
        x_pooled = x_temporal.mean(dim=2)  # [batch_size, total_nodes, d_model]
        
        # Global spatial pooling: average over nodes
        x_final = x_pooled.mean(dim=1)  # [batch_size, d_model]
        
        # Final prediction
        out = self.prediction_head(x_final)
        
        return out.squeeze()

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
    
    # Store feature names for later use
    unique_feature_names = [col.replace(f'{stations[0]}_', '') for col in data.columns if col.startswith(stations[0])]
    
    # Find PM2.5 column index for correct unscaling
    pm25_column_name = f'{stations[0]}_PM2.5'
    if pm25_column_name in data.columns:
        pm25_index = data.columns.get_loc(pm25_column_name)
        print(f"PM2.5 target column: {pm25_column_name} at index {pm25_index}")
    else:
        pm25_columns = [col for col in data.columns if 'PM2.5' in col]
        if pm25_columns:
            pm25_column_name = pm25_columns[0]
            pm25_index = data.columns.get_loc(pm25_column_name)
            print(f"Using PM2.5 target column: {pm25_column_name} at index {pm25_index}")
        else:
            pm25_index = 0
            print(f"Warning: No PM2.5 column found, using index 0")
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
# DATA PREPROCESSING (CONSISTENT WITH OTHER MODELS)
# =============================================================================

print("Preprocessing data...")

# Ensure all data is float
values = values.astype('float32')

# Normalize features
scaler = MinMaxScaler(feature_range=(0, 1))
scaled = scaler.fit_transform(values)

# Create overlapping sequences for temporal modeling
seq_length = 24
X_sequences = []
Y_sequences = []

for i in range(len(scaled) - seq_length):
    X_sequences.append(scaled[i:i+seq_length])
    Y_sequences.append(scaled[i+seq_length, pm25_index])

X = np.array(X_sequences)  # [samples, seq_length, features]  
Y = np.array(Y_sequences)  # [samples]

# Reshape X for graph processing: [samples, features*seq_length]
X = X.reshape(X.shape[0], -1)

print(f"Sequence X shape: {X.shape}, Y shape: {Y.shape}")

# =============================================================================
# COMPUTE DATA-DRIVEN CORRELATIONS
# =============================================================================

print("\nComputing feature correlations from data...")
# Compute correlation matrix from normalized feature data
feature_correlations = np.corrcoef(scaled.T)  # Correlation matrix (n_features, n_features)
print(f"Feature correlation matrix shape: {feature_correlations.shape}")

# Compute inter-station weight from cross-station correlations
# Average correlation between corresponding features across stations
station_wise_corrs = []
for feat_idx in range(n_feats):
    idx1 = feat_idx  # eMalahleni
    idx2 = n_feats + feat_idx  # Middelburg
    if idx1 < feature_correlations.shape[0] and idx2 < feature_correlations.shape[1]:
        corr = abs(feature_correlations[idx1, idx2])
        station_wise_corrs.append(corr)

inter_station_weight = np.mean(station_wise_corrs) if station_wise_corrs else 0.8
cross_feature_mult = 0.5 * inter_station_weight  # Scale cross-feature weights

print(f"Data-driven inter-station weight: {inter_station_weight:.4f}")
print(f"Cross-feature multiplier: {cross_feature_mult:.4f}")

# =============================================================================
# DATA SPLITTING (CONSISTENT WITH OTHER MODELS)
# =============================================================================

print("\nSplitting data (consistent with other models)...")

# Convert to graph sequence format first
print("Converting to FIXED graph data format...")
graph_data = create_graph_sequence_data_fixed(X, Y, n_stations, n_feats, 24,
                                            feature_correlations=feature_correlations,
                                            inter_station_weight=inter_station_weight,
                                            cross_mult=cross_feature_mult)
print(f"Created {len(graph_data)} graph sequence samples")

# Split indices
n_samples = len(graph_data)
indices = list(range(n_samples))

# Same splitting as other models
train_val_idx, test_idx = train_test_split(indices, test_size=0.2, random_state=42)
train_idx, val_idx = train_test_split(train_val_idx, test_size=0.2, random_state=42)

train_data = [graph_data[i] for i in train_idx]
val_data = [graph_data[i] for i in val_idx] 
test_data = [graph_data[i] for i in test_idx]

print(f"Train: {len(train_data)} graphs, Val: {len(val_data)} graphs, Test: {len(test_data)} graphs")

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

# Initialize FIXED model
model = FixedGraphTransformer2DModel(
    input_dim=24,
    d_model=128,
    num_graph_layers=2,
    num_temporal_layers=2,
    num_heads=8,
    dropout=0.1,
    n_stations=n_stations,
    n_features=n_feats,
    seq_length=24
).to(device)

# Count parameters
total_params = sum(p.numel() for p in model.parameters())
print(f"FIXED Model parameters: {total_params:,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.AdamW(model.parameters(), lr=0.0005, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=50)

# =============================================================================
# TRAINING AND EVALUATION FUNCTIONS
# =============================================================================

def train_model(model, train_loader, criterion, optimizer, device):
    model.train()
    total_loss = 0.0
    num_batches = 0
    
    for batch in train_loader:
        batch = batch.to(device)
        optimizer.zero_grad()
        
        predictions = model(batch)
        loss = criterion(predictions, batch.y)
        
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()
        
        total_loss += loss.item()
        num_batches += 1
    
    return total_loss / num_batches

def evaluate_model(model, loader, criterion, device):
    model.eval()
    total_loss = 0.0
    predictions = []
    targets = []
    
    with torch.no_grad():
        for batch in loader:
            batch = batch.to(device)
            pred = model(batch)
            loss = criterion(pred, batch.y)
            
            total_loss += loss.item()
            predictions.extend(pred.cpu().numpy())
            targets.extend(batch.y.cpu().numpy())
    
    return total_loss / len(loader), np.array(predictions), np.array(targets)

# =============================================================================
# MODEL TRAINING
# =============================================================================

print("Training FIXED 2D Graph Transformer model...")

best_val_loss = float('inf')
patience = 15
patience_counter = 0
epochs = 100

training_start = time.time()

for epoch in range(epochs):
    # Training
    train_loss = train_model(model, train_loader, criterion, optimizer, device)
    
    # Validation
    val_loss, val_pred, val_target = evaluate_model(model, val_loader, criterion, device)
    
    # Learning rate scheduling
    scheduler.step()
    
    # Early stopping
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        torch.save(model.state_dict(), 'fixed_2d_graph_transformer_best_model.pth')
    else:
        patience_counter += 1
    
    if epoch % 10 == 0:
        print(f"Epoch {epoch:3d}: Train Loss: {train_loss:.6f}, Val Loss: {val_loss:.6f}, Best Val: {best_val_loss:.6f}")
    
    if patience_counter >= patience:
        print(f"Early stopping at epoch {epoch}")
        break

training_time = time.time() - training_start
print(f"\nTraining completed in {training_time:.2f} seconds")

# Load best model for evaluation
model.load_state_dict(torch.load('fixed_2d_graph_transformer_best_model.pth'))

# =============================================================================
# MODEL EVALUATION
# =============================================================================

print("Evaluating FIXED 2D Graph Transformer model...")

# Test evaluation
test_loss, test_predictions, test_targets = evaluate_model(model, test_loader, criterion, device)

# Unscale predictions for evaluation
def unscale(scaled_value):
    """Unscale normalized values back to original scale using PM2.5 scaling parameters."""
    return scaled_value * (scaler.data_max_[pm25_index] - scaler.data_min_[pm25_index]) + scaler.data_min_[pm25_index]

predictions_unscaled = unscale(test_predictions)
targets_unscaled = unscale(test_targets)

# Calculate metrics
mse = mean_squared_error(targets_unscaled, predictions_unscaled)
rmse = sqrt(mse)
mae = mean_absolute_error(targets_unscaled, predictions_unscaled)
r2 = r2_score(targets_unscaled, predictions_unscaled)

print(f"\nFIXED 2D Graph Transformer Model Performance:")
print(f"Test MSE: {mse:.6f}")
print(f"Test RMSE: {rmse:.6f}")
print(f"Test MAE: {mae:.6f}")
print(f"Test R²: {r2:.6f}")

# =============================================================================
# SAVE RESULTS
# =============================================================================

print("Saving FIXED model results...")

# Save predictions
results_df = pd.DataFrame({
    'Actual': targets_unscaled,
    'Predicted': predictions_unscaled,
    'Error': np.abs(predictions_unscaled - targets_unscaled)
})
results_df.to_csv('fixed_2d_graph_transformer_predictions.csv', index=False)

# Save model metrics
metrics_df = pd.DataFrame({
    'Model': ['FIXED 2D Graph Transformer'],
    'MSE': [mse],
    'RMSE': [rmse],
    'MAE': [mae],
    'R2': [r2],
    'Training_Time': [training_time],
    'Parameters': [total_params],
    'Stations': [n_stations],
    'Features_per_Station': [n_feats],
    'Fixes_Applied': ['Deterministic graph, Edge attributes, No sigmoid, Temporal encoding']
})
metrics_df.to_csv('fixed_2d_graph_transformer_metrics.csv', index=False)

# =============================================================================
# VISUALIZATIONS
# =============================================================================

print("Creating visualizations...")

# 1. TIME SERIES PLOT (Actual vs Predicted)
fig, ax = plt.subplots(figsize=(14, 5))
time_range = np.arange(len(targets_unscaled))
ax.plot(time_range, targets_unscaled, 'o-', label='Actual', alpha=0.7, linewidth=2, markersize=4)
ax.plot(time_range, predictions_unscaled, 's-', label='Predicted', alpha=0.7, linewidth=2, markersize=4)
ax.set_xlabel('Time Step')
ax.set_ylabel('PM2.5 (μg/m³)')
ax.set_title('FIXED 2D Graph Transformer: Time Series - Actual vs Predicted PM2.5')
ax.legend(loc='best')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_2d_graph_transformer_timeseries.png', dpi=300, bbox_inches='tight')
plt.close()

# 2. QUANTILE ANALYSIS (Error distribution across value ranges)
errors = np.abs(predictions_unscaled - targets_unscaled)
bins = pd.qcut(targets_unscaled, q=5, retbins=True)[1]

quantile_errors = []
for i in range(len(bins) - 1):
    group_indices = np.where((targets_unscaled >= bins[i]) & (targets_unscaled < bins[i+1]))[0]
    if len(group_indices) > 0:
        quantile_errors.append(errors[group_indices].mean())
    else:
        quantile_errors.append(0)

rounded_bins = np.round(bins, decimals=2)

fig, ax = plt.subplots(figsize=(10, 5))
ax.plot(range(1, len(quantile_errors) + 1), quantile_errors, marker='o', linewidth=2, markersize=8, color='steelblue')
ax.set_xlabel('Quantile', fontweight='bold')
ax.set_ylabel('Average Absolute Error (μg/m³)', fontweight='bold')
ax.set_title('FIXED 2D Graph Transformer: Quantile Analysis - Error by PM2.5 Level')
ax.set_xticks(range(1, len(quantile_errors) + 1))
ax.set_xticklabels([f'{rounded_bins[i]:.1f}-{rounded_bins[i+1]:.1f}' for i in range(len(rounded_bins) - 1)], rotation=45)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_2d_graph_transformer_quantile_analysis.png', dpi=300, bbox_inches='tight')
plt.close()

# =============================================================================
# SHAP ANALYSIS FOR 2D MODEL INTERPRETABILITY
# =============================================================================

print("Performing SHAP analysis for 2D Graph Transformer interpretability...")

def graph_transformer_predict_wrapper(X_flat):
    """Wrapper for 2D Graph Transformer prediction compatible with SHAP."""
    predictions = []

    # Use first test sample as template for edge information
    template_graph = test_data[0]
    total_nodes = n_stations * n_feats

    model.eval()
    with torch.no_grad():
        for i in range(X_flat.shape[0]):
            # Reshape back to [total_nodes, seq_length]
            node_features = X_flat[i].reshape(total_nodes, seq_length)

            data_obj = Data(
                x=torch.tensor(node_features, dtype=torch.float32),
                edge_index=template_graph.edge_index,
                edge_attr=template_graph.edge_attr,
                batch=torch.zeros(total_nodes, dtype=torch.long)
            ).to(device)

            pred = model(data_obj)
            predictions.append(pred.cpu().numpy())

    return np.array(predictions).flatten()

# Prepare SHAP sample data
n_shap_samples = min(80, len(test_data))
X_shap = np.array([test_data[i].x.cpu().numpy().flatten() for i in range(n_shap_samples)])
X_background = X_shap[:30]

try:
    print("Initializing SHAP KernelExplainer for 2D Graph Transformer...")
    explainer = shap.KernelExplainer(graph_transformer_predict_wrapper, X_background)

    print("Computing SHAP values...")
    shap_values = explainer.shap_values(X_shap[:15], nsamples=80)

    # Feature names: [station_feature_t0, station_feature_t1, ...]
    feature_names = []
    for station_idx, station in enumerate(stations):
        for feat_name in unique_feature_names:
            for t in range(seq_length):
                feature_names.append(f't{t}_{station}_{feat_name}')

    # SHAP summary plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:15], feature_names=feature_names[:X_shap.shape[1]], show=False)
    plt.title('2D Graph Transformer SHAP Feature Importance Summary', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('fixed_2d_graph_transformer_shap_summary.png', dpi=300, bbox_inches='tight')
    plt.close()

    # SHAP bar plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:15], feature_names=feature_names[:X_shap.shape[1]], plot_type="bar", show=False)
    plt.title('2D Graph Transformer SHAP Feature Importance (Mean)', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('fixed_2d_graph_transformer_shap_bar.png', dpi=300, bbox_inches='tight')
    plt.close()

    print("[SUCCESS] SHAP analysis completed successfully!")

except ImportError:
    print("SHAP not available. Install with: pip install shap")
except Exception as e:
    print(f"SHAP analysis encountered an error: {e}")
    print("Continuing without SHAP analysis...")

print("\nFIXED 2D Graph Transformer complete!")

