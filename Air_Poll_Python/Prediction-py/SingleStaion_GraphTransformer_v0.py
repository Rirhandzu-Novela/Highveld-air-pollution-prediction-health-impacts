"""
Graph Transformer for Air Pollution Prediction
===============================================
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

# JSON and utilities
import json

# Suppress warnings
import warnings
warnings.filterwarnings('ignore')

print(f"PyTorch version: {torch.__version__}")
print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

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
    """Convert supervised learning data to graph format (single timestep)."""
    graph_data_list = []
    
    # Create base graph structure from feature correlations
    # X is now [samples, features] from supervised learning
    edge_index, edge_attr, _ = create_spatial_graph(X)
    
    for i in range(len(X)):
        # For supervised learning format, X[i] is just a flat feature vector [features]
        # Convert to node features: [features, 1] for graph representation
        node_features = torch.tensor(X[i].reshape(-1, 1), dtype=torch.float32)
        
        # Create graph data object
        data = Data(
            x=node_features.float(),
            edge_index=edge_index.long(),
            edge_attr=edge_attr.float(),
            y=torch.tensor([Y[i]], dtype=torch.float32),
            seq_length=torch.tensor([1], dtype=torch.long)  # Single timestep
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

# =============================================================================
# DATA PREPROCESSING
# =============================================================================

print("Preprocessing data...")

# Ensure all data is float
values = values.astype('float32')

# Normalize features
scaler = MinMaxScaler(feature_range=(0, 1))
scaled = scaler.fit_transform(values)

# Frame as supervised learning - SAME AS LSTM/CNN NOTEBOOKS
# Using series_to_supervised to match notebooks exactly
reframed = series_to_supervised(scaled, 1, 1)

n_vars = scaled.shape[1]

# Drop columns we don't want to predict (keep only first variable PM2.5)
drop = list(range(n_vars+1, 2*n_vars))
reframed.drop(reframed.columns[drop], axis=1, inplace=True)
values = reframed.values

print(f"Supervised data shape: {values.shape}")

# Split into X (all but last column) and Y (last column - PM2.5 target)
X = values[:,:-1]  # All variables at time t-1
Y = values[:,-1]   # PM2.5 at time t (1-step-ahead prediction)

print(f"X shape: {X.shape}, Y shape: {Y.shape}")

# Convert to graph sequence data for graph transformer
print("Creating graph sequence data...")
graph_data = create_graph_sequence_data(X, Y)
print(f"Created {len(graph_data)} graph samples (1-step ahead predictions)")


# =============================================================================
# TRAIN/VALIDATION/TEST SPLIT (SAME AS LSTM/CNN NOTEBOOKS)
# =============================================================================

print("Splitting data (same as LSTM/CNN notebooks)...")

# Split X, Y directly with same random_state as notebooks
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.20, random_state=42)
X_train, X_val, Y_train, Y_val = train_test_split(X_train, Y_train, test_size=0.20, random_state=42)

print(f"Train: {X_train.shape[0]}, Val: {X_val.shape[0]}, Test: {X_test.shape[0]}")

# Convert split data to graph dataset format
print("Converting to graph data format...")
train_data = create_graph_sequence_data(X_train, Y_train)
val_data = create_graph_sequence_data(X_val, Y_val)
test_data = create_graph_sequence_data(X_test, Y_test)

print(f"[OK] Train graphs: {len(train_data)} samples")
print(f"[OK] Val graphs: {len(val_data)} samples")
print(f"[OK] Test graphs: {len(test_data)} samples")

# =============================================================================
# GRAPH TRANSFORMER MODEL COMPONENTS
# =============================================================================

class MultiHeadGraphAttention(nn.Module):
    """Multi-head graph attention layer for spatial modeling."""
    
    def __init__(self, in_dim, out_dim, num_heads=4, dropout=0.1):
        super(MultiHeadGraphAttention, self).__init__()
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
        # Multi-head attention (ignore edge_attr to avoid dimension mismatch)
        head_outputs = []
        for transformer in self.transformers:
            head_out = transformer(x, edge_index)  # Remove edge_attr parameter
            head_outputs.append(head_out)
        
        # Concatenate heads
        multi_head_out = torch.cat(head_outputs, dim=-1)
        
        # Output projection and residual connection
        out = self.output_projection(multi_head_out)
        out = self.layer_norm(out + x if x.size(-1) == self.out_dim else out)
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
# GRAPH TRANSFORMER MODEL DEFINITION
# =============================================================================

class GraphTransformerModel(nn.Module):
    """Graph Transformer Network for air pollution prediction."""
    
    def __init__(self, n_features, seq_length, d_model=64, 
                 num_graph_layers=1, num_temporal_layers=1, 
                 num_heads=4, dropout=0.1):
        super(GraphTransformerModel, self).__init__()
        
        self.n_features = n_features
        self.seq_length = seq_length
        self.d_model = d_model
        
        # Input projection
        self.input_projection = nn.Linear(seq_length, d_model)
        
        # Positional encoding
        self.register_buffer('pos_encoding', create_positional_encoding(n_features, d_model))
        
        # Spatial graph attention layers
        self.graph_layers = nn.ModuleList([
            MultiHeadGraphAttention(d_model, d_model, num_heads, dropout)
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
        
        # Final prediction head
        self.prediction_head = nn.Sequential(
            nn.Linear(d_model // 2, d_model // 4),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 4, 1),
            nn.Sigmoid()
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
        
        # Spatial modeling with graph attention
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

# Get data dimensions
n_features = X_train.shape[1]  # Number of features (13)
seq_length = 1  # Single timestep for supervised learning

print(f"[OK] Data dimensions: {n_features} features, {seq_length} timestep")

# Create data loaders
batch_size = 64  # Smaller batch size for complex model
train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

# Initialize model
model = GraphTransformerModel(
    n_features=n_features,
    seq_length=seq_length,
    d_model=64,
    num_graph_layers=1,
    num_temporal_layers=1,
    num_heads=4,
    dropout=0.1
).to(device)

print(f"Model parameters: {sum(p.numel() for p in model.parameters()):,}")

# Loss function and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.AdamW(model.parameters(), lr=0.0001, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=200)

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
# TRAINING LOOP
# =============================================================================

print("Starting Graph Transformer training...")
epochs = 100
patience = 15
best_val_loss = float('inf')
patience_counter = 0
history = {'train_loss': [], 'val_loss': []}

start_time = time.time()

for epoch in range(epochs):
    # Train
    train_loss = train_epoch(model, train_loader, optimizer, criterion, device)
    
    # Validate
    val_loss, _, _ = evaluate_model(model, val_loader, criterion, device)
    
    # Learning rate scheduling
    scheduler.step()
    
    # Store history
    history['train_loss'].append(train_loss)
    history['val_loss'].append(val_loss)
    
    # Early stopping
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        patience_counter = 0
        # Save best model
        torch.save(model.state_dict(), 'best_graph_transformer_model.pth')
    else:
        patience_counter += 1
    
    if epoch % 10 == 0:
        current_lr = scheduler.get_last_lr()[0]
        print(f'Epoch {epoch:03d}: Train Loss: {train_loss:.6f}, '
              f'Val Loss: {val_loss:.6f}, LR: {current_lr:.6f}')
    
    if patience_counter >= patience:
        print(f'Early stopping at epoch {epoch}')
        break

training_time = time.time() - start_time
print(f'Training completed in {training_time:.2f} seconds')
print(f'Best validation loss: {best_val_loss:.6f}')

# Load best model
model.load_state_dict(torch.load('best_graph_transformer_model.pth'))

# =============================================================================
# EVALUATION
# =============================================================================

print("Evaluating on test set...")
test_loss, predictions, targets = evaluate_model(model, test_loader, criterion, device)

# Unscale predictions for evaluation
def unscale(scaled_value):
    """Unscale normalized values back to original scale."""
    return scaled_value * (scaler.data_max_[0] - scaler.data_min_[0]) + scaler.data_min_[0]

predictions = unscale(predictions)
targets = unscale(targets)

# Calculate metrics
mse = mean_squared_error(targets, predictions)
mae = mean_absolute_error(targets, predictions)
rmse = sqrt(mse)
r2 = r2_score(targets, predictions)

print(f"\nGraph Transformer Test Results:")
print(f"MSE:  {mse:.6f}")
print(f"MAE:  {mae:.6f}")
print(f"RMSE: {rmse:.6f}")
print(f"R²:   {r2:.6f}")

# =============================================================================
# VISUALIZATIONS
# =============================================================================

print("Creating visualizations...")

rcParams['font.weight'] = 'bold'

# Time series plot
n_points = min(150, len(targets))
plt.plot(targets[:n_points], label='Actual', linewidth=2, alpha=0.8)
plt.plot(predictions[:n_points], label='Predicted', linewidth=1.5, alpha=0.8)
plt.xlabel('Time Steps', fontweight='bold')
plt.ylabel('Normalized PM2.5', fontweight='bold')
plt.title('Graph Transformer Time Series Prediction', fontweight='bold', size=14)
plt.legend()
plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('graph_transformer_results.png', dpi=300, bbox_inches='tight')
plt.show()

# =============================================================================
# QUANTILE ANALYSIS
# =============================================================================

print("Performing quantile analysis...")

# Calculate errors
errors = predictions.flatten() - targets



# =============================================================================
# SHAP ANALYSIS
# =============================================================================

print("Performing SHAP analysis...")

try:
    import shap
    
    # Sample a subset for SHAP analysis (computationally expensive)
    n_shap_samples = min(100, len(test_data))
    shap_indices = np.random.choice(len(test_data), n_shap_samples, replace=False)
    shap_data = [test_data[i] for i in shap_indices]
    
    # Create a wrapper function for SHAP that handles graph data
    def model_predict_wrapper(X_flat):
        """Wrapper function to convert flattened input back to graph format for SHAP."""
        predictions = []
        
        # Convert flattened features back to graph format
        for i in range(X_flat.shape[0]):
            # Reshape back to [n_features, seq_length]
            node_features = X_flat[i].reshape(n_features, seq_length)
            
            # Create a sample graph data object
            sample_graph = shap_data[0]  # Use first sample as template
            data = Data(
                x=torch.tensor(node_features, dtype=torch.float32),
                edge_index=sample_graph.edge_index,
                edge_attr=sample_graph.edge_attr,
                batch=torch.zeros(n_features, dtype=torch.long)  # Single graph
            ).to(device)
            
            # Get prediction
            model.eval()
            with torch.no_grad():
                pred = model(data)
                predictions.append(pred.cpu().numpy())
        
        return np.array(predictions)
    
    # Prepare data for SHAP
    # Flatten the graph node features for SHAP analysis
    background_data = []
    test_sample_data = []
    
    for i in range(min(50, len(train_data))):  # Background samples
        node_features = train_data[i].x.numpy()  # [n_features, seq_length]
        background_data.append(node_features.flatten())
    
    for i in range(min(20, len(shap_data))):  # Test samples for explanation
        node_features = shap_data[i].x.numpy()
        test_sample_data.append(node_features.flatten())
    
    background_data = np.array(background_data)
    test_sample_data = np.array(test_sample_data)
    
    # Create SHAP explainer
    print("Creating SHAP explainer (this may take a while)...")
    explainer = shap.KernelExplainer(model_predict_wrapper, background_data[:10])  # Use fewer background samples
    
    # Calculate SHAP values
    print("Calculating SHAP values...")
    shap_values = explainer.shap_values(test_sample_data[:5])  # Analyze fewer test samples
    
    # Create feature names for visualization with proper temporal indicators
    # Extract unique feature names from dataset columns (avoiding duplicates)
    unique_features = list(dict.fromkeys(dataset.columns))  # Remove duplicates while preserving order
    
    feature_names = []
    for feat in unique_features:
        for t in range(seq_length):
            feature_names.append(f"t{t}_{feat}")
    
    # Ensure feature names match the flattened data
    if len(feature_names) != test_sample_data.shape[1]:
        # Fallback: reconstruct based on actual dimensions
        n_features_actual = test_sample_data.shape[1] // seq_length
        feature_names = []
        for feat_idx in range(n_features_actual):
            for t in range(seq_length):
                feature_names.append(f"t{t}_feat{feat_idx}")
    
    # Plot SHAP summary
    plt.figure(figsize=(12, 8))
    shap.summary_plot(shap_values, test_sample_data[:5], 
                     feature_names=feature_names, show=False, max_display=20)
    plt.title('Graph Transformer SHAP Feature Importance', fontweight='bold', size=14)
    plt.tight_layout()
    plt.savefig('graph_transformer_shap_analysis.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("SHAP analysis completed successfully!")
    
except ImportError:
    print("SHAP not available. Install with: pip install shap")
except Exception as e:
    print(f"SHAP analysis failed: {e}")
    print("This is normal for complex graph models - SHAP analysis is optional")

# =============================================================================
# SAVE RESULTS
# =============================================================================

# Save predictions
results_df = pd.DataFrame({
    'actual': targets,
    'predicted': predictions,
    'error': errors
})
results_df.to_csv('graph_transformer_predictions.csv', index=False)



# Save metrics
metrics_dict = {
    'MSE': mse,
    'MAE': mae,
    'RMSE': rmse,
    'R2': r2,
    'Training_Time': training_time,
    'Best_Val_Loss': best_val_loss
}

metrics_df = pd.DataFrame([metrics_dict])
metrics_df.to_csv('graph_transformer_metrics.csv', index=False)

