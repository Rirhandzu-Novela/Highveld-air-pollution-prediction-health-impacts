"""
Graph Transformer for Air Pollution Prediction - FIXED VERSION
==============================================================
Fixed implementation with critical issues resolved:
1. Edge attributes properly used in attention computation
2. Removed sigmoid output for proper regression
3. Fixed unscaling to use correct PM2.5 column

Notebook-style implementation following the original structure
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
from scipy.spatial.distance import pdist, squareform

# Suppress warnings
import warnings
warnings.filterwarnings('ignore')

print(f"PyTorch version: {torch.__version__}")
print(f"FIXED GraphTransformer started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

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

def create_spatial_graph(data, k_neighbors=3, correlation_threshold=0.2):
    """Create spatial graph structure based on feature relationships."""
    # Calculate correlation matrix
    corr_matrix = np.corrcoef(data.T)
    
    # Create adjacency matrix with top-k neighbors and correlation threshold
    n_features = corr_matrix.shape[0]
    adj_matrix = np.zeros_like(corr_matrix)
    
    for i in range(n_features):
        # Get correlations for node i
        correlations = np.abs(corr_matrix[i])
        
        # Find top-k neighbors above threshold
        top_indices = np.argsort(correlations)[::-1][:k_neighbors+1]  # +1 for self
        for j in top_indices:
            if correlations[j] > correlation_threshold:
                adj_matrix[i, j] = correlations[j]
    
    # Ensure symmetry
    adj_matrix = (adj_matrix + adj_matrix.T) / 2
    np.fill_diagonal(adj_matrix, 1.0)  # Self-connections
    
    # Convert to edge list
    edge_index, edge_weights = dense_to_sparse(torch.tensor(adj_matrix, dtype=torch.float))
    
    return edge_index, edge_weights, corr_matrix

def create_positional_encoding(max_len, d_model):
    """Create positional encoding for temporal sequences."""
    pe = torch.zeros(max_len, d_model)
    position = torch.arange(0, max_len).unsqueeze(1).float()
    
    div_term = torch.exp(torch.arange(0, d_model, 2).float() * 
                       -(np.log(10000.0) / d_model))
    
    pe[:, 0::2] = torch.sin(position * div_term)
    if d_model % 2 == 1:
        pe[:, 1::2] = torch.cos(position * div_term[:-1])
    else:
        pe[:, 1::2] = torch.cos(position * div_term)
    
    return pe

def create_graph_sequence_data(X, Y, seq_length=24):
    """Convert time series data to graph sequence format."""
    graph_data_list = []
    
    # Create base graph structure from feature correlations
    sample_data = X[0]  # [timesteps, features]
    edge_index, edge_attr, _ = create_spatial_graph(sample_data)
    
    for i in range(len(X)):
        # Create sequence of temporal features
        sequence_data = []
        
        for t in range(seq_length):
            if t < X[i].shape[0]:
                # Node features at time t - convert numpy to tensor
                node_features = torch.tensor(X[i][t].reshape(-1, 1), dtype=torch.float32)  # [features, 1]
            else:
                # Padding for shorter sequences
                node_features = torch.zeros(X[i].shape[1], 1, dtype=torch.float32)
            
            sequence_data.append(node_features)
        
        # Stack temporal features: [features, seq_length]
        node_features = torch.cat(sequence_data, dim=1)
        
        # Create graph data object
        data = Data(
            x=node_features.float(),
            edge_index=edge_index.long(),
            edge_attr=edge_attr.float(),
            y=torch.tensor([Y[i]], dtype=torch.float32),
            seq_length=torch.tensor([min(seq_length, X[i].shape[0])], dtype=torch.long)
        )
        graph_data_list.append(data)
    
    return graph_data_list

# =============================================================================
# LOAD DATASET
# =============================================================================

print("Loading dataset...")
dataset = pd.read_csv("eMalahleniIM.csv", sep=';', header=0, index_col=0)
values = dataset.values
print(f"Dataset shape: {dataset.shape}")
print(f"Columns: {list(dataset.columns)}")

# Find PM2.5 column index for correct unscaling
pm25_columns = [col for col in dataset.columns if 'PM2.5' in col.upper()]
if pm25_columns:
    pm25_index = dataset.columns.get_loc(pm25_columns[0])
    print(f"PM2.5 target column: {pm25_columns[0]} at index {pm25_index}")
else:
    pm25_index = 0  # Default fallback
    print(f"Warning: No PM2.5 column found, using index 0")

# =============================================================================
# DATA PREPROCESSING
# =============================================================================

print("Preprocessing data...")

# Ensure all data is float
values = values.astype('float32')

# Normalize features
scaler = MinMaxScaler(feature_range=(0, 1))
scaled = scaler.fit_transform(values)

# Create overlapping sequences for temporal modeling
seq_length = 24  # 24-hour sequence
X_sequences = []
Y_sequences = []

for i in range(len(scaled) - seq_length):
    X_sequences.append(scaled[i:i+seq_length])
    Y_sequences.append(scaled[i+seq_length, pm25_index])  # Use correct PM2.5 index

X = np.array(X_sequences)  # [samples, seq_length, features]
Y = np.array(Y_sequences)  # [samples]
n_features = scaled.shape[1]

print(f"Sequence X shape: {X.shape}, Y shape: {Y.shape}")

# Convert to graph sequence data
print("Creating graph sequence data...")
graph_data = create_graph_sequence_data(X, Y, seq_length)
print(f"Created {len(graph_data)} graph sequence samples")


# =============================================================================
# TRAIN/VALIDATION/TEST SPLIT (SAME AS LSTM/CNN NOTEBOOKS)
# =============================================================================

print("Splitting data...")
n_samples = len(graph_data)
indices = list(range(n_samples))

# First split: separate test set
train_val_idx, test_idx = train_test_split(indices, test_size=0.2, random_state=42)

# Second split: separate validation from training
train_idx, val_idx = train_test_split(train_val_idx, test_size=0.2, random_state=42)

train_data = [graph_data[i] for i in train_idx]
val_data = [graph_data[i] for i in val_idx]
test_data = [graph_data[i] for i in test_idx]

print(f"Train: {len(train_data)} sequences")
print(f"Val: {len(val_data)} sequences")
print(f"Test: {len(test_data)} sequences")

# =============================================================================
# FIXED GRAPH TRANSFORMER MODEL COMPONENTS
# =============================================================================

class FixedMultiHeadGraphAttention(nn.Module):
    """FIXED Multi-head graph attention layer for spatial modeling with edge attributes."""
    
    def __init__(self, in_dim, out_dim, num_heads=4, dropout=0.1):
        super(FixedMultiHeadGraphAttention, self).__init__()
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
                # Include edge attributes with proper dimensionality
                head_out = transformer(x, edge_index, edge_attr.unsqueeze(-1))
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
    
class TemporalTransformerLayer(nn.Module):
    """Temporal transformer layer for time series modeling."""
    
    def __init__(self, d_model, num_heads=4, d_ff=256, dropout=0.1):
        super(TemporalTransformerLayer, self).__init__()
        
        self.self_attention = nn.MultiheadAttention(
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
    
    def forward(self, x, mask=None):
        # Self-attention
        attn_out, _ = self.self_attention(x, x, x, attn_mask=mask)
        x = self.layer_norm1(x + self.dropout(attn_out))
        
        # Feed-forward
        ff_out = self.feed_forward(x)
        x = self.layer_norm2(x + self.dropout(ff_out))
        
        return x

# =============================================================================
# FIXED GRAPH TRANSFORMER MODEL DEFINITION
# =============================================================================

class FixedGraphTransformerModel(nn.Module):
    """FIXED Graph Transformer Network for air pollution prediction."""
    
    def __init__(self, n_features, seq_length, d_model=64, 
                 num_graph_layers=1, num_temporal_layers=1, 
                 num_heads=4, dropout=0.1):
        super(FixedGraphTransformerModel, self).__init__()
        
        self.n_features = n_features
        self.seq_length = seq_length
        self.d_model = d_model
        
        # Input projection
        self.input_projection = nn.Linear(seq_length, d_model)
        
        # Positional encoding
        self.register_buffer('pos_encoding', create_positional_encoding(n_features, d_model))
        
        # Spatial graph attention layers - FIXED to use edge attributes
        self.graph_layers = nn.ModuleList([
            FixedMultiHeadGraphAttention(d_model, d_model, num_heads, dropout)
            for _ in range(num_graph_layers)
        ])
        
        # Temporal transformer layers
        self.temporal_layers = nn.ModuleList([
            TemporalTransformerLayer(d_model, num_heads, d_model*2, dropout)
            for _ in range(num_temporal_layers)
        ])
        
        # Feature aggregation
        self.feature_aggregation = nn.Sequential(
            nn.Linear(d_model * n_features, d_model),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model, d_model // 2),
            nn.ReLU(),
            nn.Dropout(dropout)
        )
        
        # FIXED: Final prediction head without sigmoid for proper regression
        self.prediction_head = nn.Sequential(
            nn.Linear(d_model // 2, d_model // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 4, 1)
            # REMOVED: nn.Sigmoid() - not appropriate for regression
        )
    
    def forward(self, data):
        x, edge_index, edge_attr, batch = data.x, data.edge_index, data.edge_attr, data.batch
        
        # Input projection: [nodes, seq_length] -> [nodes, d_model]
        x = self.input_projection(x)
        
        # Add positional encoding (cycle through positions for batch processing)
        batch_size = batch.max().item() + 1
        nodes_per_graph = x.size(0) // batch_size
        pos_enc = self.pos_encoding[:nodes_per_graph].repeat(batch_size, 1)
        x = x + pos_enc
        
        # FIXED: Spatial modeling with graph attention using edge attributes
        for graph_layer in self.graph_layers:
            x = graph_layer(x, edge_index, edge_attr)
        
        # Reshape for temporal modeling: [batch_size, num_nodes, d_model]
        batch_size = batch.max().item() + 1
        nodes_per_graph = x.size(0) // batch_size
        x_temporal = x.view(batch_size, nodes_per_graph, self.d_model)
        
        # Temporal modeling with transformer
        for temporal_layer in self.temporal_layers:
            x_temporal = temporal_layer(x_temporal)
        
        # Feature aggregation: flatten and aggregate node features
        x_flat = x_temporal.view(batch_size, -1)
        x_aggregated = self.feature_aggregation(x_flat)
        
        # Final prediction
        out = self.prediction_head(x_aggregated)
        
        return out.squeeze()

# =============================================================================
# MODEL SETUP
# =============================================================================

# Device configuration
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Create data loaders
batch_size = 64  # Smaller batch size for complex model
train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

# Initialize FIXED model
model = FixedGraphTransformerModel(
    n_features=n_features,
    seq_length=seq_length,
    d_model=64,
    num_graph_layers=1,
    num_temporal_layers=1,
    num_heads=4,
    dropout=0.1
).to(device)

print(f"FIXED Model parameters: {sum(p.numel() for p in model.parameters()):,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=1e-5)
scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', patience=10)

# =============================================================================
# TRAINING FUNCTIONS
# =============================================================================

def train_epoch(model, train_loader, criterion, optimizer, device):
    model.train()
    total_loss = 0
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
    total_loss = 0
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

print("Training FIXED Graph Transformer model...")

best_val_loss = float('inf')
patience = 20
patience_counter = 0
epochs = 150

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
        torch.save(model.state_dict(), 'fixed_graph_transformer_best_model.pth')
    else:
        patience_counter += 1
    
    if epoch % 20 == 0:
        print(f"Epoch {epoch:3d}/{epochs}: Train Loss: {train_loss:.6f}, Val Loss: {val_loss:.6f}, Best: {best_val_loss:.6f}")
    
    if patience_counter >= patience:
        print(f"Early stopping at epoch {epoch}")
        break

training_time = time.time() - training_start_time
print(f"\nTraining completed in {training_time:.2f} seconds")

# Load best model
model.load_state_dict(torch.load('fixed_graph_transformer_best_model.pth'))

# =============================================================================
# EVALUATION
# =============================================================================

print("Evaluating on test set...")
test_loss, predictions, targets = evaluate_model(model, test_loader, criterion, device)

# FIXED: Unscale using correct PM2.5 column
def unscale_fixed(scaled_value):
    """FIXED unscaling function using correct PM2.5 column."""
    unscaled_value = scaled_value * (scaler.data_max_[pm25_index] - scaler.data_min_[pm25_index]) + (scaler.data_min_[pm25_index])
    return unscaled_value

predictions = unscale_fixed(predictions)
targets = unscale_fixed(targets)

# Calculate metrics
mse = mean_squared_error(targets, predictions)
mae = mean_absolute_error(targets, predictions)
rmse = sqrt(mse)
r2 = r2_score(targets, predictions)

print(f"\nFIXED Graph Transformer Test Results:")
print(f"MAE:  {mae:.6f}")
print(f"RMSE: {rmse:.6f}")
print(f"R²:   {r2:.6f}")

# =============================================================================
# SAVE RESULTS
# =============================================================================

print("Saving FIXED model results...")

# Save predictions
results_df = pd.DataFrame({
    'Actual': targets,
    'Predicted': predictions,
    'Error': np.abs(predictions - targets)
})
results_df.to_csv('fixed_graph_transformer_predictions.csv', index=False)

# Save model metrics
metrics_df = pd.DataFrame({
    'Model': ['FIXED Graph Transformer'],
    'MSE': [mse],
    'RMSE': [rmse],
    'MAE': [mae],
    'R2': [r2],
    'Training_Time': [training_time],
    'Parameters': [sum(p.numel() for p in model.parameters())],
    'Features': [n_features],
    'Seq_Length': [seq_length],
    'Fixes_Applied': ['Edge attributes, No sigmoid, Correct PM2.5 unscaling']
})
metrics_df.to_csv('fixed_graph_transformer_metrics.csv', index=False)

# =============================================================================
# VISUALIZATIONS
# =============================================================================

print("Creating visualizations...")

# Scatter plot
plt.figure(figsize=(10, 8))
plt.scatter(targets, predictions, alpha=0.5, s=20)
plt.plot([targets.min(), targets.max()], [targets.min(), targets.max()], 'r--', lw=2)
plt.xlabel('Actual PM2.5 (μg/m³)')
plt.ylabel('Predicted PM2.5 (μg/m³)')
plt.title(f'FIXED Graph Transformer: Actual vs Predicted PM2.5\nR² = {r2:.4f}, RMSE = {rmse:.4f}')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_graph_transformer_scatter.png', dpi=300, bbox_inches='tight')
plt.show()

# Residual plot
residuals = predictions - targets
plt.figure(figsize=(10, 6))
plt.scatter(predictions, residuals, alpha=0.5, s=20)
plt.axhline(y=0, color='r', linestyle='--')
plt.xlabel('Predicted PM2.5 (μg/m³)')
plt.ylabel('Residuals (μg/m³)')
plt.title('FIXED Graph Transformer: Residual Plot')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('fixed_graph_transformer_residuals.png', dpi=300, bbox_inches='tight')
plt.show()

print("✅ FIXED Graph Transformer model training and evaluation completed!")
print("Critical fixes applied:")
print("  1. Edge attributes properly used in attention computation")
print("  2. Removed sigmoid output for proper regression")
print("  3. Fixed unscaling to use correct PM2.5 column")