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
print(f"FIXED 2D Spatiotemporal Graph Transformer started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# =============================================================================
# FIXED HELPER FUNCTIONS
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

def create_deterministic_2d_spatial_graph(n_stations=2, n_features=13, feature_correlations=None,
                                         inter_station_weight=0.8, cross_mult=0.5):
    """FIXED: Create deterministic 2D spatial graph from data correlations."""
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
    
    # 3. Cross-feature inter-station connections (deterministic, not random)
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

def create_enhanced_positional_encoding_2d_temporal(n_stations, n_features, seq_length, d_model):
    """FIXED: Enhanced 2D + temporal positional encoding for multi-station spatiotemporal data."""
    total_nodes = n_stations * n_features
    
    # Spatial positional encoding (half of d_model dimensions)
    pe_spatial = torch.zeros(total_nodes, d_model // 2)
    
    for station in range(n_stations):
        for feature in range(n_features):
            node_id = station * n_features + feature
            # Use both station and feature information in positioning
            position = station * 1000 + feature  # Encode both station and feature
            
            div_term = torch.exp(torch.arange(0, d_model // 2, 2).float() * 
                               -(np.log(10000.0) / (d_model // 2)))
            
            pe_spatial[node_id, 0::2] = torch.sin(position * div_term)
            if (d_model // 2) % 2 == 1:
                pe_spatial[node_id, 1::2] = torch.cos(position * div_term[:-1])
            else:
                pe_spatial[node_id, 1::2] = torch.cos(position * div_term)
    
    # Temporal positional encoding (other half of d_model dimensions)
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

def create_fixed_2d_spatiotemporal_graph_sequence_data(X, Y, seq_length, n_stations=2, n_features=13,
                                                    feature_correlations=None, inter_station_weight=0.8, cross_mult=0.5):
    """FIXED: Convert 2D multi-station spatiotemporal sequence data to graph format."""
    graph_data_list = []
    
    # Create deterministic graph structure for 2D spatial connections with data-driven correlations
    edge_index, edge_attr = create_deterministic_2d_spatial_graph(n_stations, n_features,
                                                                 feature_correlations=feature_correlations,
                                                                 inter_station_weight=inter_station_weight,
                                                                 cross_mult=cross_mult)
    total_nodes = n_stations * n_features
    expected_size = seq_length * n_stations * n_features
    
    # Verify that X has the expected dimensions
    if X.shape[1] != expected_size:
        print(f"Warning: X has {X.shape[1]} columns but expected {expected_size}")
        print(f"Adjusting seq_length or dimensions...")
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
    
    # Store feature names for later use
    unique_feature_names = [col.replace(f'{stations[0]}_', '') for col in data.columns if col.startswith(stations[0])]
    
    # FIXED: Find PM2.5 column index for correct unscaling
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
# DATA PREPROCESSING
# =============================================================================

print("Preprocessing data...")

# Ensure all data is float
values = values.astype('float32')

# Normalize features
scaler = MinMaxScaler(feature_range=(0, 1))
scaled = scaler.fit_transform(values)

# Set sequence length
seq_length = 24
print(f"Using sequence length: {seq_length}")

# Frame as supervised learning
reframed = series_to_supervised(scaled, n_in=seq_length, n_out=1)

# Drop columns we don't want to predict (keep only first station's PM2.5)
# The target is in the last n_vars columns, we want only the PM2.5 from first station
drop_start = n_vars * seq_length + 1  # Start after the target column
drop_end = n_vars * seq_length + n_vars  # End at all target columns
drop = list(range(drop_start, drop_end))
# Remove the PM2.5 column from the drop list (keep it as target)
target_col_in_drop = drop_start + pm25_index - n_vars * seq_length - 1
if target_col_in_drop in drop:
    drop.remove(target_col_in_drop)

reframed.drop(reframed.columns[drop], axis=1, inplace=True)
values = reframed.values

print(f"Supervised data shape: {values.shape}")

# Split into input and output
X = values[:,:-1]  # All columns except last
Y = values[:,-1]   # Last column (PM2.5 prediction target)

print(f"X shape: {X.shape}")
print(f"Y shape: {Y.shape}")

# =============================================================================
# DATA SPLITTING (CONSISTENT WITH OTHER MODELS)
# =============================================================================

print("Splitting data (consistent with other models)...")

# Compute data-driven correlations from normalized features
print("\nComputing feature correlations from data...")
# Compute correlation matrix from ORIGINAL scaled data (before supervised transformation)
feature_correlations = np.corrcoef(scaled.T)
# Extract the feature correlation submatrix (first n_feats x n_feats)
feature_corr_subset = feature_correlations[:n_feats, :n_feats]

# Compute inter-station weight from cross-station correlations
station_wise_corrs = []
for feat_idx in range(n_feats):
    idx1 = feat_idx  # Station 1
    idx2 = n_feats + feat_idx  # Station 2
    if idx1 < feature_correlations.shape[0] and idx2 < feature_correlations.shape[1]:
        corr = abs(feature_correlations[idx1, idx2])
        station_wise_corrs.append(corr)

inter_station_weight = np.mean(station_wise_corrs) if station_wise_corrs else 0.8
cross_feature_mult = 0.5 * inter_station_weight

print(f"Data-driven inter-station weight: {inter_station_weight:.4f}")
print(f"Cross-feature multiplier: {cross_feature_mult:.4f}")

# Convert to graph sequence format first
print("Converting to FIXED graph data format...")
graph_data = create_fixed_2d_spatiotemporal_graph_sequence_data(X, Y, seq_length, n_stations, n_feats,
                                                               feature_correlations=feature_corr_subset,
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
# FIXED MODEL COMPONENTS
# =============================================================================

class FixedMultiHeadGraphAttention2D(nn.Module):
    """FIXED: 2D Multi-head graph attention for multi-station spatial modeling with edge attributes."""
    
    def __init__(self, in_dim, out_dim, num_heads=8, dropout=0.1):
        super(FixedMultiHeadGraphAttention2D, self).__init__()
        self.num_heads = num_heads
        self.out_dim = out_dim
        self.head_dim = out_dim // num_heads
        
        assert self.head_dim * num_heads == out_dim
        
        # FIXED: Use TransformerConv with edge_dim to properly handle edge attributes
        self.transformers = nn.ModuleList([
            TransformerConv(in_dim, self.head_dim, heads=1, dropout=dropout, edge_dim=1)
            for _ in range(num_heads)
        ])
        
        self.output_projection = nn.Linear(out_dim, out_dim)
        self.layer_norm = nn.LayerNorm(out_dim)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x, edge_index, edge_attr=None):
        # FIXED: Properly use edge attributes in attention computation
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
            out = self.layer_norm(out + x)  # Residual only if dimensions match
        else:
            out = self.layer_norm(out)
        out = self.dropout(out)
        
        return out

class FixedTemporalTransformerLayer(nn.Module):
    """FIXED: Temporal transformer layer for temporal attention."""
    
    def __init__(self, d_model, num_heads=8, d_ff=256, dropout=0.1):
        super(FixedTemporalTransformerLayer, self).__init__()
        
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
        # x shape: [batch_size, total_nodes, seq_length, d_model]
        batch_size, total_nodes, seq_length, d_model = x.shape
        
        # FIXED: Efficient batch processing instead of nested loops
        # Reshape for batch temporal attention: [batch_size*total_nodes, seq_length, d_model]
        x_temporal = x.reshape(batch_size * total_nodes, seq_length, d_model)
        
        # Temporal self-attention
        attn_out, _ = self.temporal_attention(x_temporal, x_temporal, x_temporal)
        x_temporal = x_temporal + self.dropout(attn_out)
        x_temporal = self.layer_norm1(x_temporal)
        
        # Feed-forward
        ff_out = self.feed_forward(x_temporal)
        x_temporal = x_temporal + self.dropout(ff_out)
        x_temporal = self.layer_norm2(x_temporal)
        
        # Reshape back: [batch_size, total_nodes, seq_length, d_model]
        x = x_temporal.reshape(batch_size, total_nodes, seq_length, d_model)
        
        return x

class FixedSpatialTemporalLayer(nn.Module):
    """FIXED: Optimized spatial modeling layer for 2D data without nested loops."""
    
    def __init__(self, d_model, num_heads=8, d_ff=256, dropout=0.1, n_stations=2, n_features=13):
        super(FixedSpatialTemporalLayer, self).__init__()
        
        self.n_stations = n_stations
        self.n_features = n_features
        self.d_model = d_model
        
        # Station-wise attention (efficient batch processing)
        self.station_attention = nn.MultiheadAttention(
            d_model, num_heads, dropout=dropout, batch_first=True
        )
        
        # Feature-wise attention (efficient batch processing)
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
        # x shape: [batch_size, total_nodes, seq_length, d_model]
        batch_size, total_nodes, seq_length, d_model = x.shape
        
        # FIXED: Efficient batch processing instead of nested loops
        # Reshape to [batch_size, seq_length, stations, features, d_model]
        x_reshaped = x.reshape(batch_size, self.n_stations, self.n_features, seq_length, d_model)
        x_reshaped = x_reshaped.permute(0, 3, 1, 2, 4)  # [batch, seq, stations, features, d_model]
        
        # Station-wise attention: process all timesteps and features together
        # Reshape to [batch*seq*features, stations, d_model]
        station_input = x_reshaped.reshape(batch_size * seq_length * self.n_features, self.n_stations, d_model)
        station_attn, _ = self.station_attention(station_input, station_input, station_input)
        station_output = station_input + self.dropout(station_attn)
        
        # Reshape back and apply layer norm
        x_station = station_output.reshape(batch_size, seq_length, self.n_features, self.n_stations, d_model)
        x_station = x_station.permute(0, 3, 2, 1, 4).contiguous()  # [batch, stations, features, seq, d_model]
        x_station = x_station.reshape(batch_size, total_nodes, seq_length, d_model)
        x = x + x_station  # Residual connection
        x = self.layer_norm1(x)
        
        # Feature-wise attention: process all timesteps and stations together
        x_reshaped = x.reshape(batch_size, self.n_stations, self.n_features, seq_length, d_model)
        x_reshaped = x_reshaped.permute(0, 3, 2, 1, 4)  # [batch, seq, features, stations, d_model]
        
        # Reshape to [batch*seq*stations, features, d_model]
        feature_input = x_reshaped.reshape(batch_size * seq_length * self.n_stations, self.n_features, d_model)
        feature_attn, _ = self.feature_attention(feature_input, feature_input, feature_input)
        feature_output = feature_input + self.dropout(feature_attn)
        
        # Reshape back and apply layer norm
        x_feature = feature_output.reshape(batch_size, seq_length, self.n_stations, self.n_features, d_model)
        x_feature = x_feature.permute(0, 2, 3, 1, 4).contiguous()  # [batch, stations, features, seq, d_model]
        x_feature = x_feature.reshape(batch_size, total_nodes, seq_length, d_model)
        x = x + x_feature  # Residual connection
        x = self.layer_norm2(x)
        
        # Feed-forward (process all positions efficiently)
        x_flat = x.reshape(batch_size * total_nodes * seq_length, d_model)
        ff_out = self.feed_forward(x_flat)
        x = x + self.dropout(ff_out.reshape(batch_size, total_nodes, seq_length, d_model))
        x = self.layer_norm3(x)
        
        return x

class FixedGraphTransformer2DSpatioTemporalModel(nn.Module):
    """FIXED: 2D Spatiotemporal Graph Transformer for multi-station air pollution prediction."""
    
    def __init__(self, input_dim=1, d_model=128, num_graph_layers=2, 
                 num_spatial_layers=2, num_temporal_layers=2, num_heads=8, 
                 dropout=0.1, n_stations=2, n_features=13, seq_length=24):
        super(FixedGraphTransformer2DSpatioTemporalModel, self).__init__()
        
        self.n_stations = n_stations
        self.n_features = n_features
        self.d_model = d_model
        self.seq_length = seq_length
        self.total_nodes = n_stations * n_features
        
        # Input projection
        self.input_projection = nn.Linear(input_dim, d_model)
        
        # FIXED: Enhanced 2D + Temporal Positional encoding
        pe_spatial, pe_temporal = create_enhanced_positional_encoding_2d_temporal(n_stations, n_features, seq_length, d_model)
        self.register_buffer('pe_spatial', pe_spatial)
        self.register_buffer('pe_temporal', pe_temporal)
        
        # Spatial graph attention layers - FIXED to use edge attributes
        self.graph_layers = nn.ModuleList([
            FixedMultiHeadGraphAttention2D(d_model, d_model, num_heads, dropout)
            for _ in range(num_graph_layers)
        ])
        
        # FIXED: Optimized spatial layers for 2D modeling
        self.spatial_layers = nn.ModuleList([
            FixedSpatialTemporalLayer(d_model, num_heads, d_model*2, dropout, n_stations, n_features)
            for _ in range(num_spatial_layers)
        ])
        
        # FIXED: Optimized temporal layers for temporal attention
        self.temporal_layers = nn.ModuleList([
            FixedTemporalTransformerLayer(d_model, num_heads, d_model*2, dropout)
            for _ in range(num_temporal_layers)
        ])
        
        # FIXED: More efficient aggregation
        self.station_aggregation = nn.Sequential(
            nn.Linear(d_model * self.total_nodes, d_model * 8),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model * 8, d_model * 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model * 4, d_model),
            nn.ReLU(),
            nn.Dropout(dropout)
        )
        
        # FIXED: Final prediction head without sigmoid for proper regression
        self.prediction_head = nn.Sequential(
            nn.Linear(d_model, d_model // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 2, d_model // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 4, 1)
            # REMOVED: nn.Sigmoid() - not appropriate for regression
        )
    
    def forward(self, data):
        x, edge_index, edge_attr, batch = data.x, data.edge_index, data.edge_attr, data.batch
        
        # x shape: [total_nodes_in_all_graphs, seq_length] from PyTorch Geometric batching
        batch_size = batch.max().item() + 1
        nodes_per_graph = self.total_nodes
        
        # FIXED: More efficient positional encoding application
        pe_spatial = self.pe_spatial  # [nodes_per_graph, d_model // 2]
        pe_temporal = self.pe_temporal  # [seq_length, d_model // 2]
        
        # Process each timestep efficiently
        x_expanded = []
        for t in range(self.seq_length):
            x_t = x[:, t].unsqueeze(1)  # [total_nodes_in_all_graphs, 1]
            x_t = self.input_projection(x_t)  # [total_nodes_in_all_graphs, d_model]
            
            # Add positional encodings efficiently
            node_id_in_sample = torch.arange(x.size(0), device=x.device) % nodes_per_graph
            pe_spatial_expanded = pe_spatial[node_id_in_sample]  # [total_nodes, d_model//2]
            pe_temporal_expanded = pe_temporal[t].unsqueeze(0).expand(x.size(0), -1)  # [total_nodes, d_model//2]
            
            # Combine spatial and temporal encodings
            pos_enc = torch.cat([pe_spatial_expanded, pe_temporal_expanded], dim=1)
            x_t = x_t + pos_enc
            x_expanded.append(x_t)
        
        x_temporal = torch.stack(x_expanded, dim=1)  # [total_nodes, seq_length, d_model]
        
        # FIXED: Efficient spatial modeling with graph attention
        x_seq = []
        for t in range(self.seq_length):
            x_t = x_temporal[:, t, :]  # [total_nodes, d_model]
            
            # Apply graph layers with edge attributes
            for graph_layer in self.graph_layers:
                x_t = graph_layer(x_t, edge_index, edge_attr)
            
            x_seq.append(x_t)
        
        x_temporal = torch.stack(x_seq, dim=1)  # [total_nodes, seq_length, d_model]
        
        # Reshape for batch processing: [batch_size, nodes_per_graph, seq_length, d_model]
        x_batch = x_temporal.reshape(batch_size, nodes_per_graph, self.seq_length, self.d_model)
        
        # FIXED: Optimized spatial-temporal modeling
        for spatial_layer in self.spatial_layers:
            x_batch = spatial_layer(x_batch)
        
        # FIXED: Optimized temporal modeling
        for temporal_layer in self.temporal_layers:
            x_batch = temporal_layer(x_batch)
        
        # FIXED: More efficient aggregation - average over time, then aggregate nodes
        x_temporal_avg = x_batch.mean(dim=2)  # Average over time: [batch_size, nodes_per_graph, d_model]
        x_flat = x_temporal_avg.reshape(batch_size, -1)  # Flatten nodes
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
batch_size = 32  # Reasonable batch size for complex model
train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

# Initialize FIXED model
model = FixedGraphTransformer2DSpatioTemporalModel(
    input_dim=1,
    d_model=128,
    num_graph_layers=2,
    num_spatial_layers=1,  # Reduced for efficiency
    num_temporal_layers=1,  # Reduced for efficiency 
    num_heads=8,
    dropout=0.1,
    n_stations=n_stations,
    n_features=n_feats,
    seq_length=seq_length
).to(device)

# Count parameters
total_params = sum(p.numel() for p in model.parameters())
print(f"FIXED Model parameters: {total_params:,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.AdamW(model.parameters(), lr=0.0005, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', patience=10)

# =============================================================================
# TRAINING FUNCTIONS
# =============================================================================

def train_epoch(model, train_loader, criterion, optimizer, device):
    model.train()
    total_loss = 0.0
    num_batches = 0
    
    for batch in train_loader:
        batch = batch.to(device)
        optimizer.zero_grad()
        
        predictions = model(batch)
        loss = criterion(predictions, batch.y)
        
        loss.backward()
        # Add gradient clipping for stability
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
# TRAINING LOOP
# =============================================================================

print("Training FIXED 2D Spatiotemporal Graph Transformer model...")

best_val_loss = float('inf')
patience = 20
patience_counter = 0
epochs = 100

training_start_time = time.time()

for epoch in range(epochs):
    # Training
    train_loss = train_epoch(model, train_loader, criterion, optimizer, device)
    
    # Validation
    val_loss, val_pred, val_target = evaluate_model(model, val_loader, criterion, device)
    
    # Learning rate scheduling
    scheduler.step(val_loss)
    
    # Early stopping
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        torch.save(model.state_dict(), 'fixed_2d_spatiotemporal_graph_transformer_best_model.pth')
    else:
        patience_counter += 1
    
    if epoch % 15 == 0:
        print(f"Epoch {epoch:3d}/{epochs}: Train Loss: {train_loss:.6f}, Val Loss: {val_loss:.6f}, Best: {best_val_loss:.6f}")
    
    if patience_counter >= patience:
        print(f"Early stopping at epoch {epoch}")
        break

training_time = time.time() - training_start_time
print(f"\nTraining completed in {training_time:.2f} seconds")

# Load best model for evaluation
model.load_state_dict(torch.load('fixed_2d_spatiotemporal_graph_transformer_best_model.pth'))

# =============================================================================
# MODEL EVALUATION
# =============================================================================

print("Evaluating FIXED 2D Spatiotemporal Graph Transformer model...")

# Test evaluation
test_loss, test_predictions, test_targets = evaluate_model(model, test_loader, criterion, device)

# FIXED: Unscale predictions for evaluation using correct PM2.5 column
def unscale_fixed(scaled_value):
    """FIXED unscaling function using correct PM2.5 column."""
    return scaled_value * (scaler.data_max_[pm25_index] - scaler.data_min_[pm25_index]) + scaler.data_min_[pm25_index]

predictions_unscaled = unscale_fixed(test_predictions)
targets_unscaled = unscale_fixed(test_targets)

# Calculate metrics
mse = mean_squared_error(targets_unscaled, predictions_unscaled)
rmse = sqrt(mse)
mae = mean_absolute_error(targets_unscaled, predictions_unscaled)
r2 = r2_score(targets_unscaled, predictions_unscaled)

print(f"\nFIXED 2D Spatiotemporal Graph Transformer Model Performance:")
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
results_df.to_csv('fixed_2d_spatiotemporal_graph_transformer_predictions.csv', index=False)

# Save model metrics
metrics_df = pd.DataFrame({
    'Model': ['FIXED 2D Spatiotemporal Graph Transformer'],
    'MSE': [mse],
    'RMSE': [rmse],
    'MAE': [mae],
    'R2': [r2],
    'Training_Time': [training_time],
    'Parameters': [total_params],
    'Stations': [n_stations],
    'Features_per_Station': [n_feats],
    'Fixes_Applied': ['Deterministic graph, Edge attributes, No sigmoid, Correct PM2.5 unscaling, Optimized processing']
})
metrics_df.to_csv('fixed_2d_spatiotemporal_graph_transformer_metrics.csv', index=False)

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
ax.set_title('FIXED 2D Spatiotemporal Graph Transformer: Time Series - Actual vs Predicted PM2.5')
ax.legend(loc='best')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_2d_spatiotemporal_graph_transformer_timeseries.png', dpi=300, bbox_inches='tight')
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
ax.set_title('FIXED 2D Spatiotemporal Graph Transformer: Quantile Analysis - Error by PM2.5 Level')
ax.set_xticks(range(1, len(quantile_errors) + 1))
ax.set_xticklabels([f'{rounded_bins[i]:.1f}-{rounded_bins[i+1]:.1f}' for i in range(len(rounded_bins) - 1)], rotation=45)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_2d_spatiotemporal_graph_transformer_quantile_analysis.png', dpi=300, bbox_inches='tight')
plt.close()

# =============================================================================
# SHAP ANALYSIS FOR 2D SPATIOTEMPORAL MODEL INTERPRETABILITY
# =============================================================================

print("Performing SHAP analysis for 2D Spatiotemporal Graph Transformer interpretability...")

# Create a wrapper function for SHAP analysis (using template graph approach from V0)
def graph_transformer_predict_wrapper(X_flat):
    """Wrapper function for Spatiotemporal Graph Transformer prediction compatible with SHAP."""
    predictions = []
    
    # Use first test sample as template for edge information
    template_graph = test_data[0]
    total_nodes = n_stations * n_feats
    
    model.eval()
    with torch.no_grad():
        for i in range(X_flat.shape[0]):
            # Reshape back to [total_nodes, seq_length]
            node_features = X_flat[i].reshape(total_nodes, seq_length)
            
            # Create a Data object using template graph structure
            data = Data(
                x=torch.tensor(node_features, dtype=torch.float32),
                edge_index=template_graph.edge_index,
                edge_attr=template_graph.edge_attr,
                batch=torch.zeros(total_nodes, dtype=torch.long)
            ).to(device)
            
            # Get prediction
            pred = model(data)
            predictions.append(pred.cpu().numpy())
    
    return np.array(predictions).flatten()

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
    plt.savefig('fixed_2d_spatiotemporal_graph_transformer_shap_summary.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # SHAP bar plot
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, X_shap[:15], feature_names=feature_names[:X_shap.shape[1]], plot_type="bar", show=False)
    plt.title('2D Spatiotemporal Graph Transformer SHAP Feature Importance (Mean)', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('fixed_2d_spatiotemporal_graph_transformer_shap_bar.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print("[SUCCESS] SHAP analysis completed successfully!")
    
except ImportError:
    print("⚠ SHAP not available. Install with: pip install shap")
except Exception as e:
    print(f"⚠ SHAP analysis encountered an error: {e}")
    print("Continuing without SHAP analysis...")
