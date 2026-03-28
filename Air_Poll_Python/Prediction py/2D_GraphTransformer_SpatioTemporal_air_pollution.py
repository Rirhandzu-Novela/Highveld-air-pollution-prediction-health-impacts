"""
2D Spatiotemporal Graph Transformer Air Pollution Prediction
============================================================== 
Graph Transformer Network for multi-station air pollution prediction using 2D spatial + temporal data
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
print(f"2D Spatiotemporal Graph Transformer started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

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

def create_2d_spatial_graph(n_stations=2, n_features=13, k_neighbors=5):
    """Create advanced 2D spatial graph for multi-station modeling."""
    total_nodes = n_stations * n_features
    
    # Initialize adjacency matrix
    adj_matrix = np.zeros((total_nodes, total_nodes))
    
    # 1. Intra-station connections: Connect features within same station
    for station in range(n_stations):
        start_idx = station * n_features
        end_idx = (station + 1) * n_features
        
        # Create fully connected subgraph for each station
        for i in range(start_idx, end_idx):
            for j in range(start_idx, end_idx):
                if i != j:
                    # Weight connections based on typical air quality correlations
                    weight = np.random.uniform(0.5, 1.0)  # Strong intra-station connections
                    adj_matrix[i, j] = weight
    
    # 2. Inter-station connections: Connect same features across stations
    for feature in range(n_features):
        for station1 in range(n_stations):
            for station2 in range(station1 + 1, n_stations):
                idx1 = station1 * n_features + feature
                idx2 = station2 * n_features + feature
                # Same feature across stations should have strong connection
                weight = np.random.uniform(0.7, 1.0)  # Strong inter-station connections
                adj_matrix[idx1, idx2] = weight
                adj_matrix[idx2, idx1] = weight
    
    # 3. Cross-feature inter-station connections (weaker)
    for station1 in range(n_stations):
        for station2 in range(station1 + 1, n_stations):
            start1, end1 = station1 * n_features, (station1 + 1) * n_features
            start2, end2 = station2 * n_features, (station2 + 1) * n_features
            
            # Add some cross-feature connections between stations
            for i in range(start1, end1):
                for j in range(start2, end2):
                    if np.random.random() < 0.3:  # 30% chance of connection
                        weight = np.random.uniform(0.2, 0.5)  # Weaker connections
                        adj_matrix[i, j] = weight
                        adj_matrix[j, i] = weight
    
    # Add self-connections
    np.fill_diagonal(adj_matrix, 1.0)
    
    # Convert to edge list
    edge_index, edge_weights = dense_to_sparse(torch.tensor(adj_matrix, dtype=torch.float))
    
    return edge_index, edge_weights

def create_positional_encoding_2d_temporal(n_stations, n_features, seq_length, d_model):
    """Create 2D + temporal positional encoding for multi-station spatiotemporal data."""
    total_nodes = n_stations * n_features
    
    # Spatial positional encoding
    pe_spatial = torch.zeros(total_nodes, d_model // 2)
    
    for station in range(n_stations):
        for feature in range(n_features):
            node_id = station * n_features + feature
            position = node_id
            
            div_term = torch.exp(torch.arange(0, d_model // 2, 2).float() * 
                               -(np.log(10000.0) / (d_model // 2)))
            
            pe_spatial[node_id, 0::2] = torch.sin(position * div_term)
            if (d_model // 2) % 2 == 1:
                pe_spatial[node_id, 1::2] = torch.cos(position * div_term[:-1])
            else:
                pe_spatial[node_id, 1::2] = torch.cos(position * div_term)
    
    # Temporal positional encoding
    pe_temporal = torch.zeros(seq_length, d_model // 2)
    
    for t in range(seq_length):
        position = t
        
        div_term = torch.exp(torch.arange(0, d_model // 2, 2).float() * 
                           -(np.log(10000.0) / (d_model // 2)))
        
        pe_temporal[t, 0::2] = torch.sin(position * div_term)
        if (d_model // 2) % 2 == 1:
            pe_temporal[t, 1::2] = torch.cos(position * div_term[:-1])
        else:
            pe_temporal[t, 1::2] = torch.cos(position * div_term)
    
    return pe_spatial, pe_temporal

def create_2d_spatiotemporal_graph_sequence_data(X, Y, seq_length, n_stations=2, n_features=13):
    """Convert 2D multi-station spatiotemporal sequence data to graph format."""
    graph_data_list = []
    
    # Create base graph structure for 2D spatial connections
    edge_index, edge_attr = create_2d_spatial_graph(n_stations, n_features)
    total_nodes = n_stations * n_features
    expected_size = seq_length * n_stations * n_features
    
    # Verify that X has the expected dimensions
    if X.shape[1] != expected_size:
        print(f"Warning: X has {X.shape[1]} columns but expected {expected_size}")
        print(f"Adjusting seq_length or dimensions...")
        # Try to infer the actual seq_length from data
        actual_seq_length = X.shape[1] // (n_stations * n_features)
        seq_length = actual_seq_length
        print(f"Using seq_length = {seq_length}")
    
    for i in range(len(X)):
        # Reshape X from flat to [timesteps, stations, features]
        x_temporal = X[i].reshape(seq_length, n_stations, n_features)
        
        # Create node features with temporal dimension: [total_nodes, seq_length]
        node_features = torch.tensor(x_temporal.transpose(1, 2, 0).reshape(total_nodes, seq_length), dtype=torch.float32)
        
        # Create graph data object with temporal dimension
        data = Data(
            x=node_features,  # [total_nodes, seq_length]
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
    
    # Store feature names for later use (extract only unique features, not per-station duplicates)
    unique_feature_names = [col.replace(f'{stations[0]}_', '') for col in data.columns if col.startswith(stations[0])]
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

# Frame as supervised learning with TEMPORAL WINDOW
seq_length = 24  # Use 24 timesteps (same as 1D GraphTransformer)
reframed = series_to_supervised(scaled, n_in=seq_length, n_out=1)

# Keep only the input columns (past seq_length timesteps) and the first target (PM2.5 at current time)
# Input columns: seq_length * n_vars
# Target column: first var at time t (PM2.5)
n_input_cols = seq_length * n_vars
input_cols = list(range(n_input_cols))
# Add the target: PM2.5 at time t (which should be at column n_input_cols)
target_col = n_input_cols

# Select only these columns
if target_col < len(reframed.columns):
    reframed = reframed.iloc[:, input_cols + [target_col]]
else:
    # If target column doesn't exist, use the last column
    reframed = reframed.iloc[:, input_cols + [len(reframed.columns) - 1]]

values = reframed.values

print(f"Supervised data shape: {values.shape}")

# Split into input and output
X = values[:, :-1]  # All columns except last
Y = values[:, -1]   # Last column (PM2.5 prediction target)

print(f"X shape: {X.shape}")
print(f"Y shape: {Y.shape}")

# =============================================================================
# DATA SPLITTING (SAME AS NOTEBOOKS FOR CONSISTENCY)
# =============================================================================

print("Splitting data (same as LSTM/CNN notebooks)...")

# Split X, Y DIRECTLY with same random_state as notebooks (guaranteed consistency)
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.20, random_state=42)
X_train, X_val, Y_train, Y_val = train_test_split(X_train, Y_train, test_size=0.20, random_state=42)

print(f"Train: {X_train.shape[0]}, Val: {X_val.shape[0]}, Test: {X_test.shape[0]}")

# Convert split data to spatiotemporal graph format
print("Converting to spatiotemporal graph data format...")
train_data = create_2d_spatiotemporal_graph_sequence_data(X_train, Y_train, seq_length, n_stations, n_feats)
val_data = create_2d_spatiotemporal_graph_sequence_data(X_val, Y_val, seq_length, n_stations, n_feats)
test_data = create_2d_spatiotemporal_graph_sequence_data(X_test, Y_test, seq_length, n_stations, n_feats)

print(f"[OK] Train graphs: {len(train_data)} samples")
print(f"[OK] Val graphs: {len(val_data)} samples")
print(f"[OK] Test graphs: {len(test_data)} samples")

# =============================================================================
# 2D SPATIOTEMPORAL GRAPH TRANSFORMER MODEL COMPONENTS
# =============================================================================

class MultiHeadGraphAttention2D(nn.Module):
    """2D Multi-head graph attention for multi-station spatial modeling."""
    
    def __init__(self, in_dim, out_dim, num_heads=8, dropout=0.1):
        super(MultiHeadGraphAttention2D, self).__init__()
        self.num_heads = num_heads
        self.out_dim = out_dim
        self.head_dim = out_dim // num_heads
        
        assert self.head_dim * num_heads == out_dim
        
        self.transformers = nn.ModuleList([
            TransformerConv(in_dim, self.head_dim, heads=1, dropout=dropout)
            for _ in range(num_heads)
        ])
        
        self.output_projection = nn.Linear(out_dim, out_dim)
        self.layer_norm = nn.LayerNorm(out_dim)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x, edge_index, edge_attr=None):
        # Multi-head attention
        head_outputs = []
        for transformer in self.transformers:
            head_out = transformer(x, edge_index)
            head_outputs.append(head_out)
        
        # Concatenate heads
        multi_head_out = torch.cat(head_outputs, dim=-1)
        
        # Output projection and residual connection
        out = self.output_projection(multi_head_out)
        out = self.layer_norm(out + x if x.size(-1) == self.out_dim else out)
        out = self.dropout(out)
        
        return out

class TemporalTransformerLayer(nn.Module):
    """Temporal transformer layer for temporal attention."""
    
    def __init__(self, d_model, num_heads=8, d_ff=256, dropout=0.1):
        super(TemporalTransformerLayer, self).__init__()
        
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
    
    def forward(self, x):
        # x shape: [batch_size, total_nodes, seq_length, d_model] or reshaped for temporal attention
        # Apply temporal attention: [batch_size*total_nodes, seq_length, d_model]
        batch_size, total_nodes, seq_length, d_model = x.shape
        x_temporal = x.view(batch_size * total_nodes, seq_length, d_model)
        
        # Temporal self-attention
        attn_out, _ = self.temporal_attention(x_temporal, x_temporal, x_temporal)
        x_temporal = x_temporal + self.dropout(attn_out)
        x_temporal = self.layer_norm1(x_temporal)
        
        # Feed-forward
        ff_out = self.feed_forward(x_temporal)
        x_temporal = x_temporal + self.dropout(ff_out)
        x_temporal = self.layer_norm2(x_temporal)
        
        # Reshape back
        x = x_temporal.view(batch_size, total_nodes, seq_length, d_model)
        
        return x

class SpatialTemporalLayer(nn.Module):
    """Spatial modeling layer for 2D data (station-wise and feature-wise attention)."""
    
    def __init__(self, d_model, num_heads=8, d_ff=256, dropout=0.1, n_stations=2, n_features=13):
        super(SpatialTemporalLayer, self).__init__()
        
        self.n_stations = n_stations
        self.n_features = n_features
        self.d_model = d_model
        
        # Station-wise attention
        self.station_attention = nn.MultiheadAttention(
            d_model, num_heads, dropout=dropout, batch_first=True
        )
        
        # Feature-wise attention
        self.feature_attention = nn.MultiheadAttention(
            d_model, num_heads, dropout=dropout, batch_first=True
        )
        
        # Feed-forward networks
        self.feed_forward = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_ff, d_model)
        )
        
        self.layer_norm1 = nn.LayerNorm(d_model)
        self.layer_norm2 = nn.LayerNorm(d_model)
        self.layer_norm3 = nn.LayerNorm(d_model)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x):
        batch_size = x.size(0)
        total_nodes = x.size(1)
        seq_length = x.size(2)
        d_model = x.size(3)
        
        # Reshape to separate stations and features: [batch, stations, features, seq_length, d_model]
        x_reshaped = x.view(batch_size, self.n_stations, self.n_features, seq_length, d_model)
        
        # Station-wise attention (avg across stations for each feature at each timestep)
        for t in range(seq_length):
            for feature in range(self.n_features):
                feat_data = x_reshaped[:, :, feature, t, :]  # [batch, stations, d_model]
                attn_out, _ = self.station_attention(feat_data, feat_data, feat_data)
                x_reshaped[:, :, feature, t, :] = x_reshaped[:, :, feature, t, :] + self.dropout(attn_out)
        
        x = x_reshaped.view(batch_size, total_nodes, seq_length, d_model)
        x = self.layer_norm1(x)
        
        # Feature-wise attention (avg across features for each station at each timestep)
        x_reshaped = x.view(batch_size, self.n_stations, self.n_features, seq_length, d_model)
        for t in range(seq_length):
            for station in range(self.n_stations):
                stat_data = x_reshaped[:, station, :, t, :]  # [batch, features, d_model]
                attn_out, _ = self.feature_attention(stat_data, stat_data, stat_data)
                x_reshaped[:, station, :, t, :] = x_reshaped[:, station, :, t, :] + self.dropout(attn_out)
        
        x = x_reshaped.view(batch_size, total_nodes, seq_length, d_model)
        x = self.layer_norm2(x)
        
        # Feed-forward (process each position independently)
        x_flat = x.view(batch_size * total_nodes * seq_length, d_model)
        ff_out = self.feed_forward(x_flat)
        x = x + self.dropout(ff_out.view(batch_size, total_nodes, seq_length, d_model))
        x = self.layer_norm3(x)
        
        return x

class GraphTransformer2DSpatioTemporalModel(nn.Module):
    """2D Spatiotemporal Graph Transformer for multi-station air pollution prediction."""
    
    def __init__(self, input_dim=1, d_model=128, num_graph_layers=2, 
                 num_spatial_layers=2, num_temporal_layers=2, num_heads=8, 
                 dropout=0.1, n_stations=2, n_features=13, seq_length=24):
        super(GraphTransformer2DSpatioTemporalModel, self).__init__()
        
        self.n_stations = n_stations
        self.n_features = n_features
        self.d_model = d_model
        self.seq_length = seq_length
        self.total_nodes = n_stations * n_features
        
        # Input projection
        self.input_projection = nn.Linear(input_dim, d_model)
        
        # 2D + Temporal Positional encoding
        pe_spatial, pe_temporal = create_positional_encoding_2d_temporal(n_stations, n_features, seq_length, d_model)
        self.register_buffer('pe_spatial', pe_spatial)
        self.register_buffer('pe_temporal', pe_temporal)
        
        # Spatial graph attention layers
        self.graph_layers = nn.ModuleList([
            MultiHeadGraphAttention2D(d_model, d_model, num_heads, dropout)
            for _ in range(num_graph_layers)
        ])
        
        # Spatial layers for 2D modeling
        self.spatial_layers = nn.ModuleList([
            SpatialTemporalLayer(d_model, num_heads, d_model*2, dropout, n_stations, n_features)
            for _ in range(num_spatial_layers)
        ])
        
        # Temporal layers for temporal attention
        self.temporal_layers = nn.ModuleList([
            TemporalTransformerLayer(d_model, num_heads, d_model*2, dropout)
            for _ in range(num_temporal_layers)
        ])
        
        # Multi-station aggregation
        self.station_aggregation = nn.Sequential(
            nn.Linear(d_model * self.total_nodes * seq_length, d_model * 16),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model * 16, d_model * 8),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model * 8, d_model * 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model * 4, d_model),
            nn.ReLU(),
            nn.Dropout(dropout)
        )
        
        # Final prediction head
        self.prediction_head = nn.Sequential(
            nn.Linear(d_model, d_model // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 2, d_model // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 4, 1),
            nn.Sigmoid()
        )
    
    def forward(self, data):
        x, edge_index, edge_attr, batch = data.x, data.edge_index, data.edge_attr, data.batch
        
        # x shape: [total_nodes_in_all_graphs, seq_length] from PyTorch Geometric batching
        # batch: tensor indicating which sample each node belongs to
        batch_size = batch.max().item() + 1
        nodes_per_graph = self.total_nodes
        
        # Get positional encoding (reuse same spatial encoding for all samples)
        pe_spatial = self.pe_spatial  # [nodes_per_graph, d_model // 2]
        
        # Expand input for each timestep: process each timestep separately
        x_expanded = []
        for t in range(self.seq_length):
            x_t = x[:, t].unsqueeze(1)  # [total_nodes_in_all_graphs, 1]
            x_t = self.input_projection(x_t)  # [total_nodes_in_all_graphs, d_model]
            
            # Add spatial and temporal positional encodings
            node_id_in_sample = torch.arange(x.size(0), device=x.device) % nodes_per_graph
            pe_spatial_expanded = pe_spatial[node_id_in_sample]  # [total_nodes_in_all_graphs, d_model // 2]
            pe_temporal_expanded = self.pe_temporal[t].unsqueeze(0).expand(x.size(0), -1)  # [total_nodes_in_all_graphs, d_model // 2]
            
            # Concatenate spatial and temporal encodings to get full d_model
            pos_enc = torch.cat([pe_spatial_expanded, pe_temporal_expanded], dim=1)  # [total_nodes_in_all_graphs, d_model]
            x_t = x_t + pos_enc
            
            x_expanded.append(x_t)
        
        x_temporal = torch.stack(x_expanded, dim=1)  # [total_nodes_in_all_graphs, seq_length, d_model]
        
        # Spatial modeling with graph attention (per timestep)
        x_seq = []
        for t in range(self.seq_length):
            x_t = x_temporal[:, t, :]  # [total_nodes_in_all_graphs, d_model]
            
            for graph_layer in self.graph_layers:
                x_t = graph_layer(x_t, edge_index, edge_attr)
            
            x_seq.append(x_t)
        
        x_temporal = torch.stack(x_seq, dim=1)  # [total_nodes_in_all_graphs, seq_length, d_model]
        
        # Reshape for batch processing: [batch_size, nodes_per_graph, seq_length, d_model]
        x_batch = x_temporal.view(batch_size, nodes_per_graph, self.seq_length, self.d_model)
        
        # Spatial-temporal modeling for 2D structure
        for spatial_layer in self.spatial_layers:
            x_batch = spatial_layer(x_batch)
        
        # Temporal modeling
        for temporal_layer in self.temporal_layers:
            x_batch = temporal_layer(x_batch)
        
        # Multi-station aggregation: flatten and aggregate all node features and timesteps
        x_flat = x_batch.view(batch_size, -1)
        x_aggregated = self.station_aggregation(x_flat)
        
        # Final prediction
        out = self.prediction_head(x_aggregated)
        
        return out.squeeze()

# =============================================================================
# MODEL TRAINING SETUP
# =============================================================================

# Device configuration
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Create data loaders
batch_size = 8  # Smaller batch size due to larger model
train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

# Initialize model
model = GraphTransformer2DSpatioTemporalModel(
    input_dim=1,
    d_model=128,
    num_graph_layers=2,
    num_spatial_layers=2,
    num_temporal_layers=2,
    num_heads=8,
    dropout=0.1,
    n_stations=n_stations,
    n_features=n_feats,
    seq_length=seq_length
).to(device)

# Count parameters
total_params = sum(p.numel() for p in model.parameters())
print(f"Model parameters: {total_params:,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.AdamW(model.parameters(), lr=0.0005, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=50)

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
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
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

print("Starting 2D Spatiotemporal Graph Transformer training...")

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
        torch.save(model.state_dict(), '2d_graph_transformer_spatiotemporal_best_model.pth')
    else:
        patience_counter += 1
    
    if patience_counter >= patience:
        print(f'Early stopping at epoch {epoch+1}')
        break

training_time = time.time() - start_time
print(f"Training completed in {training_time:.2f} seconds")

# Load best model for evaluation
model.load_state_dict(torch.load('2d_graph_transformer_spatiotemporal_best_model.pth'))

# =============================================================================
# MODEL EVALUATION
# =============================================================================

print("Evaluating 2D Spatiotemporal Graph Transformer model...")

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

print(f"\n2D Spatiotemporal Graph Transformer Model Performance:")
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
plt.title('2D Spatiotemporal Graph Transformer Training History', fontweight='bold')
plt.legend()
plt.grid(True, alpha=0.3)

# 2. Predictions vs Actual
plt.subplot(1, 3, 2)
plt.scatter(targets_unscaled, predictions_unscaled, alpha=0.5, s=20)
plt.plot([targets_unscaled.min(), targets_unscaled.max()], 
         [targets_unscaled.min(), targets_unscaled.max()], 'r--', linewidth=2)
plt.xlabel('Actual PM2.5', fontweight='bold')
plt.ylabel('Predicted PM2.5', fontweight='bold')
plt.title(f'2D Spatiotemporal (R² = {r2:.3f})', fontweight='bold')
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
plt.savefig('2d_graph_transformer_spatiotemporal_results.png', dpi=300, bbox_inches='tight')
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
plt.title('2D Spatiotemporal Graph Transformer Quantile Analysis', fontweight='bold', size=14)
plt.xticks(range(1, len(quantiles.categories) + 1), 
          [f'{rounded_bins[i]:.2f}-{rounded_bins[i+1]:.2f}' for i in range(len(rounded_bins) - 1)], 
          rotation=45)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('2d_graph_transformer_spatiotemporal_quantile_analysis.png', dpi=300, bbox_inches='tight')
plt.show()

# =============================================================================
# SHAP ANALYSIS FOR 2D SPATIOTEMPORAL MODEL INTERPRETABILITY
# =============================================================================

print("Performing SHAP analysis for 2D Spatiotemporal Graph Transformer interpretability...")

# Create a wrapper function for SHAP analysis
def graph_transformer_predict_wrapper(X_flat):
    """Wrapper function for Spatiotemporal Graph Transformer prediction compatible with SHAP."""
    predictions = []
    
    model.eval()
    with torch.no_grad():
        for x_sample in X_flat:
            # Convert to graph data format
            graph_sample = create_2d_spatiotemporal_graph_sequence_data([x_sample], [0], seq_length, n_stations, n_feats)[0]
            graph_sample = graph_sample.to(device)
            
            # Create a mini-batch
            loader = DataLoader([graph_sample], batch_size=1, shuffle=False)
            
            for batch in loader:
                pred = model(batch).cpu()
                # Handle scalar predictions properly
                if pred.dim() == 0:
                    # Scalar tensor: use .item()
                    predictions.append(pred.item())
                else:
                    # Array tensor: use first element
                    predictions.append(pred.numpy()[0])
    
    return np.array(predictions)

# Prepare sample data for SHAP
n_shap_samples = min(80, len(test_data))
X_shap = np.array([test_data[i].x.cpu().numpy().flatten() for i in range(n_shap_samples)])
X_background = X_shap[:30]  # Use first 30 samples as background

try:
    print("Initializing SHAP KernelExplainer for 2D Spatiotemporal Graph Transformer...")
    explainer = shap.KernelExplainer(graph_transformer_predict_wrapper, X_background)
    
    print("Computing SHAP values...")
    shap_values = explainer.shap_values(X_shap[:15], nsamples=80)
    
    # Create feature names for 2D spatiotemporal model using actual column names WITH temporal indicators
    feature_names = []
    for station_idx, station in enumerate(stations):
        for feat_name in unique_feature_names:
            for t in range(seq_length):
                feature_names.append(f't{t}_{station}_{feat_name}')
    
    # SHAP summary plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:15], feature_names=feature_names[:X_shap.shape[1]], show=False)
    plt.title('2D Spatiotemporal Graph Transformer SHAP Feature Importance Summary', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('2d_graph_transformer_spatiotemporal_shap_summary.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # SHAP bar plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:15], feature_names=feature_names[:X_shap.shape[1]], plot_type="bar", show=False)
    plt.title('2D Spatiotemporal Graph Transformer SHAP Feature Importance (Mean)', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('2d_graph_transformer_spatiotemporal_shap_bar.png', dpi=300, bbox_inches='tight')
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
results_df.to_csv('2d_graph_transformer_spatiotemporal_predictions.csv', index=False)

# Save model metrics
metrics_df = pd.DataFrame({
    'Model': ['2D Spatiotemporal Graph Transformer'],
    'MSE': [mse],
    'RMSE': [rmse],
    'MAE': [mae],
    'R2': [r2],
    'Training_Time': [training_time],
    'Parameters': [total_params],
    'Stations': [n_stations],
    'Features_per_Station': [n_feats],
    'Seq_Length': [seq_length]
})
metrics_df.to_csv('2d_graph_transformer_spatiotemporal_metrics.csv', index=False)

print(f"✅ 2D Spatiotemporal Graph Transformer completed successfully!")
print(f"📁 Results saved:")
print(f"  📊 Predictions: '2d_graph_transformer_spatiotemporal_predictions.csv'")
print(f"  📈 Metrics: '2d_graph_transformer_spatiotemporal_metrics.csv'")  
print(f"  🎯 Best model: '2d_graph_transformer_spatiotemporal_best_model.pth'")
print(f"  📋 Visualizations: '2d_graph_transformer_spatiotemporal_results.png', '2d_graph_transformer_spatiotemporal_quantile_analysis.png'")
if 'shap_values' in locals():
    print(f"  🔍 SHAP analysis: '2d_graph_transformer_spatiotemporal_shap_summary.png', '2d_graph_transformer_spatiotemporal_shap_bar.png'")
print(f"  ⏱️ Total time: {time.time() - start_time:.2f} seconds")
