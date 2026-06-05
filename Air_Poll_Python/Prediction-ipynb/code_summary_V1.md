# Air Pollution Prediction - Code Summary

## Overview

This workspace contains **14 scripts and notebooks** implementing different neural network architectures for **air pollution prediction**, specifically focusing on PM2.5, PM10, SO2, and NO2 levels. The workspace includes traditional models (CNN, LSTM, CNN-LSTM) with grid search optimization, advanced graph-based models (GCN and Graph Transformer) for spatial-temporal prediction, and 2D multi-station versions for enhanced spatial modeling.

## Mathematical Formulation

### Problem Definition
Given a time series of air quality measurements $X = \{x_1, x_2, ..., x_t\}$ where $x_i \in \mathbb{R}^{13}$, predict the next hour's pollutant concentration $y_{t+1} \in \mathbb{R}$.

**Supervised Learning Transformation:**
$$f: \mathbb{R}^{13} \rightarrow \mathbb{R}$$
$$y_{t+1} = f(x_t) + \epsilon$$

where $\epsilon$ represents the prediction error.

### Data Preprocessing
**Min-Max Normalization:**
$$x_{norm} = \frac{x - x_{min}}{x_{max} - x_{min}}$$

**Time Series to Supervised Conversion:**
$$\text{Input: } X_t = [x_{t-n+1}, x_{t-n+2}, ..., x_t]$$
$$\text{Output: } Y_t = y_t$$

## Data and Problem Setup

All notebooks work with air quality data from:
- **Dataset**: `eMalahleniIM.csv` (air pollution and weather data)
- **Target**: Predicting air pollutant levels (mainly PM2.5) 
- **Input features**: 13 variables including weather conditions and pollution measurements
- **Time series approach**: Using previous hour's data to predict next hour's pollution level

## Core Notebooks

### 1. Vanilla LSTM.ipynb
- **Architecture**: Basic LSTM model with 5 dense layers
- **Structure**: LSTM(56) → Dense(56) × 5 → Dense(1)
- **Purpose**: Simple baseline approach
- **Training**: 30 epochs, batch size 16
- **Activation**: ReLU for hidden layers, sigmoid for output

**Mathematical Representation:**

*LSTM Cell Equations:*
$$f_t = \sigma(W_f \cdot [h_{t-1}, x_t] + b_f) \quad \text{(Forget gate)}$$
$$i_t = \sigma(W_i \cdot [h_{t-1}, x_t] + b_i) \quad \text{(Input gate)}$$
$$\tilde{C}_t = \tanh(W_C \cdot [h_{t-1}, x_t] + b_C) \quad \text{(Candidate values)}$$
$$C_t = f_t * C_{t-1} + i_t * \tilde{C}_t \quad \text{(Cell state)}$$
$$o_t = \sigma(W_o \cdot [h_{t-1}, x_t] + b_o) \quad \text{(Output gate)}$$
$$h_t = o_t * \tanh(C_t) \quad \text{(Hidden state)}$$

*Dense Layer Transformation:*
$$y = \sigma(W_5 \cdot \text{ReLU}(W_4 \cdot ... \cdot \text{ReLU}(W_1 \cdot h_t + b_1) + b_4) + b_5)$$

**Architecture Diagram:**
```
Input(13) → LSTM(56) → Dense(56) → Dense(56) → Dense(56) → Dense(56) → Dense(56) → Dense(1)
    ↓           ↓          ↓          ↓          ↓          ↓          ↓          ↓
 [1,13]    [1,56]     [1,56]     [1,56]     [1,56]     [1,56]     [1,56]     [1,1]
           Memory      ReLU       ReLU       ReLU       ReLU       ReLU     Sigmoid
           Gates
```

### 2. CNN.ipynb
- **Architecture**: Pure CNN model for time series prediction
- **Structure**: Conv1D(256) × 3 → MaxPooling → Flatten → Dense(1)
- **Purpose**: Uses 1D convolutions to extract temporal patterns
- **Training**: 50 epochs, batch size 16
- **Features**: 256 filters, kernel size 1, max pooling layers

**Mathematical Representation:**

*1D Convolution Operation:*
$$y[i] = \sum_{k=0}^{K-1} x[i+k] \cdot w[k] + b$$

where $K$ is the kernel size, $w$ is the filter weights, and $b$ is the bias.

*ReLU Activation:*
$$\text{ReLU}(x) = \max(0, x)$$

*Max Pooling:*
$$y[i] = \max_{j \in [i \cdot s, i \cdot s + p)} x[j]$$

where $s$ is the stride and $p$ is the pool size.

*Final Prediction:*
$$\hat{y} = \sigma(W \cdot \text{flatten}(\text{MaxPool}(\text{ReLU}(\text{Conv1D}^{(3)}(x)))) + b)$$

**Architecture Diagram:**
```
Input(1,13) → Conv1D(256) → MaxPool → Conv1D(256) → MaxPool → Conv1D(256) → MaxPool → Flatten → Dense(1)
     ↓            ↓           ↓           ↓           ↓           ↓           ↓         ↓         ↓
  [1,13]      [1,256]    [1,256]     [1,256]    [1,256]     [1,256]    [1,256]   [256]     [1]
              ReLU       Pool=1       ReLU       Pool=1       ReLU       Pool=1             Sigmoid
              K=1                     K=1                     K=1
```

### 3. CNN LSTM.ipynb
- **Architecture**: Hybrid model combining CNN and LSTM
- **Structure**: TimeDistributed(Conv1D + MaxPool) × 3 → LSTM(56) → Dense layers
- **Purpose**: Most sophisticated approach, leveraging both convolution and memory
- **Training**: 40 epochs, batch size 32
- **Features**: 64 filters in CNN layers, 56 LSTM units

**Mathematical Representation:**

*TimeDistributed CNN Feature Extraction:*
$$F_t = \text{MaxPool}(\text{ReLU}(\text{Conv1D}(x_t; W_{conv}, b_{conv})))$$

*Sequential Processing:*
$$F = [F_1, F_2, ..., F_T] \quad \text{where } F_t \in \mathbb{R}^{64}$$

*LSTM Processing of CNN Features:*
$$h_t = \text{LSTM}(F_t, h_{t-1}, C_{t-1}; W_{lstm}, b_{lstm})$$

*Final Dense Layers:*
$$\hat{y} = \sigma(W_4 \cdot \text{ReLU}(W_3 \cdot \text{ReLU}(W_2 \cdot \text{ReLU}(W_1 \cdot h_T))))$$

*Complete Model:*
$$\hat{y} = f_{dense}(f_{lstm}(f_{cnn}(X)))$$

**Architecture Diagram:**
```
Input(1,1,13) → TimeDistributed Block                    → LSTM(56) → Dense(56) → Dense(56) → Dense(56) → Dense(1)
     ↓              ↓                                         ↓          ↓          ↓          ↓          ↓
  [1,1,13]     ┌─────────────────┐                       [1,56]     [1,56]     [1,56]     [1,56]     [1,1]
               │ Conv1D(64,K=1)  │ ──┐                   Memory      ReLU       ReLU       ReLU     Sigmoid
               │      ↓          │   │
               │ MaxPool(P=1)    │   │ ×3 layers
               │      ↓          │   │
               │ ReLU + Flatten  │ ──┘
               └─────────────────┘
                      ↓
                 Feature Maps
                   [T,64]
```

## Grid Search Notebooks

### 4. CNN-Grid search.ipynb
- **Purpose**: Optimizes CNN hyperparameters
- **Parameters tested**:
  - Filters: 32, 64, 128, 256
  - Batch sizes: 16, 32, 64, 128, 256
  - Epochs: Various configurations
- **Method**: GridSearchCV with KerasRegressor wrapper
- **Cross-validation**: 3-fold CV

**Grid Search Mathematical Formulation:**
$$\theta^* = \arg\min_{\theta \in \Theta} \frac{1}{k} \sum_{j=1}^{k} \mathcal{L}(f(X^{(j)}_{train}; \theta), y^{(j)}_{val})$$

where $\Theta$ is the hyperparameter space, $k=3$ is the number of folds, and $\mathcal{L}$ is the loss function.

**Hyperparameter Space:**
$$\Theta = \{n_{filters}, b_{size}, n_{epochs}\}$$
$$n_{filters} \in \{32, 64, 128, 256\}$$
$$b_{size} \in \{16, 32, 64, 128, 256\}$$

### 5. LSTM-Grid search.ipynb
- **Purpose**: Optimizes LSTM parameters
- **Parameters tested**:
  - Hidden units: Multiple configurations
  - Batch sizes: Various sizes
  - Epochs: Different training lengths
- **Method**: Systematic hyperparameter tuning for LSTM architecture

### 6. CNN LSTM-Grid search.ipynb
- **Purpose**: Hyperparameter optimization for the hybrid CNN-LSTM model
- **Complexity**: Most complex optimization due to combined architecture
- **Parameters**: Both CNN and LSTM hyperparameters optimized simultaneously

## Key Technical Components

### Data Preprocessing Pipeline
```python
def series_to_supervised(data, n_in=1, n_out=1, dropnan=True)
```
- Converts time series to supervised learning format
- Creates lag features for temporal dependency
- Handles variable number of input/output timesteps

### Data Processing Steps
1. Load air quality data from CSV
2. Convert to float32 and handle missing values
3. MinMax scaling (0-1 normalization)
4. Time series to supervised conversion
5. Drop unwanted prediction columns (keep only target variable)
6. Train/validation/test split (60/20/20)

### Model Evaluation Framework

**Evaluation Metrics:**

*Mean Squared Error:*
$$\text{MSE} = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$

*Mean Absolute Error:*
$$\text{MAE} = \frac{1}{n} \sum_{i=1}^{n} |y_i - \hat{y}_i|$$

*Root Mean Squared Error:*
$$\text{RMSE} = \sqrt{\frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2}$$

*Coefficient of Determination:*
$$R^2 = 1 - \frac{\sum_{i=1}^{n} (y_i - \hat{y}_i)^2}{\sum_{i=1}^{n} (y_i - \bar{y})^2}$$

where $\bar{y} = \frac{1}{n} \sum_{i=1}^{n} y_i$ is the mean of actual values.

*Mean Absolute Percentage Error:*
$$\text{MAPE} = \frac{100\%}{n} \sum_{i=1}^{n} \left|\frac{y_i - \hat{y}_i}{y_i}\right|$$

**Visualizations**: 
- Predicted vs observed plots
- Quantile analysis (error distribution across pollution levels)
- Training history curves

**SHAP analysis**: Feature importance and explainability using KernelExplainer
$$\phi_i = \mathbb{E}[f(x)|x_i] - \mathbb{E}[f(x)]$$
where $\phi_i$ represents the contribution of feature $i$ to the prediction.

## Model Architecture Comparison

| Model | Key Features | Strengths | Parameters | Computational Complexity | Data Type |
|-------|-------------|-----------|------------|-------------------------|-----------|
| **Vanilla LSTM** | Simple sequential model | Good baseline, fast training | ~50K params | O(n) | Single Station |
| **CNN** | 1D convolutions | Captures local temporal patterns | ~200K params | O(n) | Single Station |
| **CNN-LSTM** | Hybrid approach | Best of both: feature extraction + memory | ~150K params | O(n) | Single Station |
| **2D CNN** | 2D convolutions | Spatial pattern recognition | ~250K params | O(n²) | Multi-Station |
| **2D CNN-LSTM** | 2D CNN + LSTM | Advanced spatial-temporal modeling | ~300K params | O(n²) | Multi-Station |
| **GCN** | Graph convolutions | Spatial feature relationships | ~100K params | O(n²) | Single Station |
| **Graph Transformer** | Multi-head attention + graph | State-of-the-art single-station attention | ~500K params | O(n²d) | Single Station |
| **2D GCN** | Multi-station GCN | Advanced spatial relationships | ~150K params | O(n³) | Multi-Station (spatial only) |
| **2D Graph Transformer** | Multi-station attention (2D) | Ultimate multi-station spatial attention | ~800K params | O(n³d) | Multi-Station (spatial only) |
| **2D Spatiotemporal Graph Transformer** ⭐ | Multi-station + temporal | **ULTIMATE**: Spatial + temporal with 24 timesteps | **~167M params** | **O(n³d × t)** | **Multi-Station + TEMPORAL** |

## Technical Implementation Details

### Input Data Shape
- **Original**: (samples, features) where features = 13
- **Reshaped**: (samples, timesteps=1, features=13) for LSTM/CNN
- **CNN-LSTM**: (samples, sequences=1, timesteps=1, features=13)

### Loss Function and Optimization

**Mean Squared Error Loss:**
$$\mathcal{L}(\theta) = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$

where $y_i$ is the actual value, $\hat{y}_i$ is the predicted value, and $n$ is the batch size.

**Adam Optimizer Update Rules:**
$$m_t = \beta_1 m_{t-1} + (1 - \beta_1) g_t$$
$$v_t = \beta_2 v_{t-1} + (1 - \beta_2) g_t^2$$
$$\hat{m}_t = \frac{m_t}{1 - \beta_1^t}, \quad \hat{v}_t = \frac{v_t}{1 - \beta_2^t}$$
$$\theta_{t+1} = \theta_t - \frac{\alpha}{\sqrt{\hat{v}_t} + \epsilon} \hat{m}_t$$

where $\alpha$ is the learning rate, $\beta_1 = 0.9$, $\beta_2 = 0.999$, and $\epsilon = 10^{-8}$.

**Activation Functions:**
- Hidden layers: $\text{ReLU}(x) = \max(0, x)$
- Output layer: $\sigma(x) = \frac{1}{1 + e^{-x}}$ (Sigmoid for normalized output)

### Training Configuration
- **Early stopping**: Patience of 10 epochs
- **Model checkpointing**: Save best weights based on validation loss
- **Batch sizes**: Optimized per model (16-32)
- **Epochs**: 30-50 depending on model complexity

## Research Focus

### Environmental Health Monitoring
- **Location**: eMalahleni area (South Africa)
- **Pollutants**: PM2.5, PM10, SO2, NO2
- **Prediction horizon**: Next-hour forecasting
- **Health impact**: Enables early warning systems for pollution exposure

### Model Interpretability
- **SHAP values**: Understanding feature contributions
- **Quantile analysis**: Performance across different pollution levels
- **Error distribution**: Understanding model limitations

## Output and Visualization

### Generated Plots
- Time series predictions vs actual values
- Quantile-based error analysis
- Feature importance plots (SHAP)
- Training history visualization

### Model Persistence
- Models saved as `.h5` files for different locations and pollutants
- Separate models for eMalahleni and Ermelo locations
- Different models for PM2.5, PM10, SO2, NO2 predictions

### Traditional Models
```python
# Core libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Deep learning
from keras.models import Sequential
from keras.layers import Dense, LSTM, Conv1D, MaxPooling1D, Flatten, TimeDistributed

# Machine learning
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# Model interpretation
import shap

# Hyperparameter optimization
from scikeras.wrappers import KerasRegressor
```

### Graph Neural Networks
```python
# PyTorch ecosystem
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.optim import Adam, AdamW
from torch.optim.lr_scheduler import CosineAnnealingLR

# PyTorch Geometric
from torch_geometric.nn import GCNConv, TransformerConv, global_mean_pool, BatchNorm
from torch_geometric.data import Data, DataLoader
from torch_geometric.utils import dense_to_sparse

# Advanced features
from torch.nn.utils import clip_grad_norm_
import itertools
from collections import defaultdict
# Hyperparameter optimization
from scikeras.wrappers import KerasRegressor
```

## Advanced Graph Neural Network Models

### 7. GCN_air_pollution.py
- **Architecture**: Graph Convolutional Network for spatial-temporal modeling
- **Structure**: Multi-layer GCN with batch normalization and residual connections
- **Purpose**: Leverages spatial relationships between features for better prediction
- **Training**: Dynamic early stopping, CUDA support
- **Features**: Graph construction based on feature correlations, global pooling

**Mathematical Representation:**

*Graph Convolution Operation:*
$$H^{(l+1)} = \sigma(\tilde{D}^{-\frac{1}{2}}\tilde{A}\tilde{D}^{-\frac{1}{2}}H^{(l)}W^{(l)})$$

where $\tilde{A} = A + I$ is the adjacency matrix with self-connections, $\tilde{D}$ is the degree matrix, and $W^{(l)}$ are the learnable parameters.

*Global Pooling for Graph-Level Prediction:*
$$h_{graph} = \text{READOUT}(\{h_v^{(L)} : v \in V\})$$

### 8. GraphTransformer_air_pollution.py
- **Architecture**: Advanced Graph Transformer with spatial and temporal attention (single station)
- **Model Size**: ~500K parameters with multi-head attention and graph convolutions
- **Input**: Single-station graph data with temporal sequences
- **Purpose**: State-of-the-art single-station spatial-temporal modeling with attention mechanisms
- **Data**: 
  - Single station: eMalahleniIM2.csv
  - 13 nodes (one per feature)
  - Temporal window: 24 timesteps per feature
- **Training Configuration**:
  - Batch size: 64
  - Epochs: 200 maximum
  - Early stopping patience: 15 epochs
  - Optimizer: AdamW (lr=0.0001, weight_decay=1e-4)
  - Scheduler: CosineAnnealingLR (T_max=50)
  - Gradient clipping: max_norm=1.0

**Architecture Components:**

*1. Spatial Graph Attention*
- Number of heads: 4
- Multi-head graph attention layers
- Creates feature dependency graph based on correlations
- Uses TransformerConv for attention-based aggregation

*2. Temporal Transformer Layer*
- Self-attention over temporal dimension
- Processes 24 timesteps for each feature
- Multi-head attention with learned weights
- Feed-forward network with dimension expansion (d_model × 2)

*3. Positional Encoding (1D)*
$$PE(pos, 2i) = \sin\left(\frac{pos}{10000^{2i/d_{model}}}\right)$$
$$PE(pos, 2i+1) = \cos\left(\frac{pos}{10000^{2i/d_{model}}}\right)$$

**Mathematical Representation:**

*Multi-Head Graph Attention:*
$$\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

*Multi-Head Output:*
$$\text{MultiHead}(Q, K, V) = \text{Concat}(\text{head}_1, ..., \text{head}_h)W^O$$

*Temporal Transformer Layer:*
$$\text{FFN}(x) = \max(0, xW_1 + b_1)W_2 + b_2$$
$$\text{LayerNorm}(x + \text{Sublayer}(x))$$

*Complete Forward Pass:*
$$\text{1. Spatial attention on graph:} \quad h_{spatial} = \text{MultiHeadGraphAttention}(X_{features})$$
$$\text{2. Reshape for temporal:} \quad h_{temporal} = \text{reshape}(h_{spatial}, [batch, seq\_len, d\_model])$$
$$\text{3. Add temporal positional encoding:} \quad h = h_{temporal} + PE_{temporal}$$
$$\text{4. Temporal transformer layers:} \quad h = \text{TemporalTransformer}(h)$$
$$\text{5. Global averaging:} \quad h_{global} = \text{MeanPool}(h)$$
$$\text{6. Final prediction:} \quad \hat{y} = \sigma(\text{Linear}(h_{global}))$$

### 9. 2DCNN.ipynb
- **Architecture**: 2D Convolutional Neural Network for multi-station spatial modeling
- **Input**: Multi-station grid data arranged as 2D spatial map
- **Structure**: Conv2D layers → MaxPooling2D → Flatten → Dense layers
- **Purpose**: Learns spatial patterns across multiple monitoring stations
- **Data Arrangement**: 
  - Spatial grid: 2 stations arranged in 2D space
  - Features per station: 13 (creating 2 × 13 feature channels)
  - Input shape: (batch, 2_stations, 13_features, 1)
- **Training**: 50 epochs, batch size 16, early stopping patience=10

**Architecture Components:**

*2D Convolution Operation:*
$$y[i,j] = \sum_{m=0}^{K_h-1} \sum_{n=0}^{K_w-1} x[i+m, j+n] \cdot w[m,n] + b$$

where $K_h$ and $K_w$ are the kernel height and width.

*2D Max Pooling:*
$$y[i,j] = \max_{m,n \in \text{pool}} x[i+m, j+n]$$

**Architecture Diagram:**
```
Input (batch, 2, 13, 1) 
    ↓
Conv2D(32, kernel_size=3) → MaxPool2D(2) 
    ↓ [batch, 1, 13, 32] → [batch, 1, 6, 32]
Conv2D(64, kernel_size=3) → MaxPool2D(2)
    ↓ [batch, 1, 4, 64] → [batch, 1, 2, 64]
Flatten → [batch, 128]
    ↓
Dense(64, ReLU) → Dense(32, ReLU) → Dense(1, Sigmoid)
    ↓
Output [batch, 1]
```

**Key Features:**
- Captures spatial dependencies between stations
- 2D kernels scan across station and feature dimensions
- Progressive downsampling with max pooling
- Hierarchical feature learning

### 10. 2DCNN LSTM.ipynb
- **Architecture**: Hybrid 2D CNN-LSTM for advanced multi-station spatial-temporal modeling
- **Input**: Multi-station spatial grid with temporal sequences
- **Structure**: Conv2D → LSTM → Dense layers (TimeDistributed architecture)
- **Purpose**: Combines 2D spatial pattern extraction with temporal memory
- **Data Organization**:
  - Spatial grid: 2 stations × 13 features
  - Temporal sequences: Multiple time steps
  - Input shape: (batch, time_steps, 2_stations, 13_features, 1)
- **Training**: 40 epochs, batch size 32, early stopping patience=10

**Architecture Components:**

*TimeDistributed 2D CNN*
$$F_t = \text{Conv2D}(\text{ReLU}(\text{MaxPool2D}(x_t)))$$
where $x_t$ is spatial data at time $t$.

*Sequential LSTM Processing*
$$h_t = \text{LSTM}(F_t, h_{t-1}, C_{t-1})$$

*Final Dense Layers*
$$\hat{y} = \sigma(W_{out} \cdot \text{ReLU}(W_1 \cdot h_T) + b)$$

**Architecture Diagram:**
```
Input (batch, T, 2, 13, 1)
    ↓
TimeDistributed Block (for each timestep)
  ├─ Conv2D(32) → MaxPool2D → Conv2D(64) → MaxPool2D → Flatten
  └─ Output: [batch, T, features]
    ↓ [batch, T, 256]
LSTM(64) → Dense(32) → Dense(1)
    ↓
Output [batch, 1]
```

**Key Advantages:**
- 2D CNN extracts spatial patterns for each time step
- LSTM captures temporal dependencies
- Combines strengths of spatial CNN with temporal LSTM
- More sophisticated than pure CNN or LSTM alone

## Grid Search Optimization Scripts

### 11. GCN_Grid_Search.py
- **Purpose**: Comprehensive hyperparameter optimization for GCN model
- **Parameters optimized**:
  - Window size: [12, 24, 48] timesteps
  - Hidden dimensions: [32, 64, 128]
  - Number of layers: [2, 3, 4]
  - Dropout rates: [0.1, 0.2, 0.3]
  - Learning rates: [0.001, 0.0005, 0.0001]
  - Batch sizes: [16, 32, 64]
- **Features**: K-fold cross-validation, early stopping, comprehensive visualization
- **Output**: Best parameters, performance analysis, saved models

### 12. GraphTransformer_Grid_Search.py
- **Purpose**: Comprehensive hyperparameter optimization for single-station Graph Transformer
- **Total Combinations**: 6,561 parameter combinations
- **Grid Parameters**:
  - seq_length: [6, 12, 24] (temporal window)
  - d_model: [64, 128, 256]
  - num_graph_layers: [1, 2, 3]
  - num_temporal_layers: [1, 2, 3]
  - num_heads: [4, 8, 16]
  - dropout: [0.1, 0.2, 0.3]
  - learning_rate: [0.001, 0.0005, 0.0001]
  - batch_size: [8, 16, 32]
- **Features**: Nested loops, early stopping per config, memory cleanup, CUDA support
- **Output**: All 6,561 results, top 10 configurations, best model weights, visualizations

### 13. 2D_GCN_air_pollution.py
- **Architecture**: 2D Graph Convolutional Network for multi-station spatial modeling
- **Structure**: Multi-station GCN with 2D spatial graph connections and enhanced aggregation
- **Input**: Merged multi-station data (2 stations × 13 features = 26 nodes per graph)
- **Model Size**: ~150K parameters with batch normalization and residual connections
- **Purpose**: Leverages spatial relationships between multiple monitoring stations
- **Training**: 
  - Mixed data from eMalahleni and Middelburg stations
  - AdamW optimizer with weight decay
  - CosineAnnealingLR scheduler
  - Early stopping with patience=15
  - 80 epochs maximum
- **Features**: 
  - 2D spatial graph construction (intra-station, inter-station, cross-feature)
  - Graph-level global mean pooling
  - Advanced spatial aggregation layers
  - Batch normalization for stability
  - Residual connections for gradient flow

**Dataset Integration:**
- **Station 1**: eMalahleniIM.csv (13 features)
- **Station 2**: Middelburg.csv (13 features)
- **Combined nodes**: 26 total (2 stations × 13)
- **Graph edges**: Weighted connections based on feature correlations
- **Total samples**: 87,645 after preprocessing

**Mathematical Representation:**

*2D Spatial Graph Construction:*
$$A_{2D} = A_{intra} + A_{inter} + A_{cross} + I$$

where:
- $A_{intra} \in \mathbb{R}^{26×26}$: Intra-station connections (features within same station)
- $A_{inter} \in \mathbb{R}^{26×26}$: Inter-station connections (same features across stations)
- $A_{cross} \in \mathbb{R}^{26×26}$: Cross-feature inter-station connections (weaker)
- $I$: Identity matrix for self-connections

*Edge Weight Assignment:*
$$w_{intra}(i,j) \sim \mathcal{U}(0.5, 1.0) \quad \text{(strong intra-station)}$$
$$w_{inter}(i,j) \sim \mathcal{U}(0.7, 1.0) \quad \text{(strong inter-station same feature)}$$
$$w_{cross}(i,j) \sim \mathcal{U}(0.2, 0.5) \quad \text{(weak cross-feature inter-station)}$$

*Node Feature Representation:*
$$X \in \mathbb{R}^{26×1} \quad \text{(scalar value per node)}$$

*Graph Convolution:*
$$H^{(l+1)} = \sigma(\tilde{D}^{-\frac{1}{2}}\tilde{A}\tilde{D}^{-\frac{1}{2}}H^{(l)}W^{(l)} + b^{(l)})$$

*Global Pooling for Multi-Station Aggregation:*
$$h_{global} = \text{GlobalMeanPool}(\{h_v^{(L)} : v \in V\})$$

*Spatial Aggregation Layer:*
$$h_{agg} = \text{ReLU}(W_{agg} \cdot h_{global} + b_{agg})$$

*Final Prediction:*
$$\hat{y} = \sigma(\text{Linear}(h_{agg}))$$

### 12. 2D_GraphTransformer_air_pollution.py
- **Architecture**: Advanced 2D Graph Transformer for multi-station spatial-temporal modeling
- **Model Size**: ~800K parameters with multi-head attention mechanisms
- **Input**: Multi-station graph data with 2D positional encoding
- **Purpose**: State-of-the-art multi-station spatial-temporal modeling with attention mechanisms
- **Data**: 
  - 2 stations merged: eMalahleni + Middelburg
  - 26 total nodes (2 × 13 features)
  - 87,645 samples after preprocessing
  - Train: 52,587 | Val: 17,529 | Test: 17,529
- **Training Configuration**:
  - Batch size: 16 (due to complexity)
  - Epochs: 80 maximum
  - Early stopping patience: 12 epochs
  - Optimizer: AdamW (lr=0.0005, weight_decay=1e-4)
  - Scheduler: CosineAnnealingLR (T_max=50)
  - Gradient clipping: max_norm=1.0

**Architecture Components:**

*1. MultiHeadGraphAttention2D*
- Number of heads: 8
- Output dimension per head: d_model/8
- Uses TransformerConv layers (one per head)
- Layer normalization and residual connections
- Dropout: 0.1

*2. SpatialTemporalLayer (Unique to 2D)*
- Station-wise attention: Aggregates information across 2 stations per feature
  $$\text{StationAttn}(F_i) = \text{MultiHead}(F_{i,:, \cdot}, F_{i,:, \cdot}, F_{i,:, \cdot})$$
  where $F_i$ represents feature $i$, and $:$ represents all stations
  
- Feature-wise attention: Aggregates information across 13 features per station
  $$\text{FeatureAttn}(S_j) = \text{MultiHead}(S_{j, :, \cdot}, S_{j, :, \cdot}, S_{j, :, \cdot})$$
  where $S_j$ represents station $j$, and $:$ represents all features

- Feed-forward network with dimension expansion
- Triple layer normalization (after station attention, feature attention, feed-forward)

*3. Input Projection*
- Projects scalar node features (input_dim=1) to d_model dimensions
$$h_0 = W_{in} \cdot x + b_{in}, \quad W_{in} \in \mathbb{R}^{1 × d_{model}}$$

*4. 2D Positional Encoding*
- Different from 1D: Encodes both station and feature dimensions
$$PE(s, f, 2i) = \sin\left(\frac{\text{pos}}{10000^{2i/d_{model}}}\right)$$
$$PE(s, f, 2i+1) = \cos\left(\frac{\text{pos}}{10000^{2i/d_{model}}}\right)$$
where $\text{pos} = s \times n_{features} + f$ (linearized 2D position)

*5. Station Aggregation*
- Flattens all node representations: $(batch, 26 \times d_{model})$
- Three dense layers with ReLU activation
- Dimension reduction: $(26 × d_{model}) → (4 × d_{model}) → (2 × d_{model}) → d_{model}$

*6. Prediction Head*
- Dense layers: $d_{model} → d_{model}/2 → d_{model}/4 → 1$
- Sigmoid activation for normalized output (0-1 range)
- Dropout between layers

**Multi-Station Graph Structure:**

The model processes a combined graph with:
- **26 nodes**: 2 stations × 13 features per station
- **Node indexing**: 
  - Nodes 0-12: Station 1 (eMalahleni) features
  - Nodes 13-25: Station 2 (Middelburg) features
- **Edge types**:
  1. Intra-station edges (strong): Features within same station
  2. Inter-station edges (strong): Same feature across stations
  3. Cross-feature edges (weak): Different features across stations
  4. Self-loops (default): All nodes connected to themselves

**Mathematical Representation of Complete Forward Pass:**

$$\text{Input: } \mathbf{x} \in \mathbb{R}^{26×1}$$

$$\text{1. Input Projection: } \mathbf{h}_0 = \text{Linear}_{in}(\mathbf{x})$$

$$\text{2. Add Positional Encoding: } \mathbf{h}_0^{pe} = \mathbf{h}_0 + PE(\text{pos})$$

$$\text{3. Graph Attention Layers (num\_graph\_layers times):}$$
$$\mathbf{h}_{i+1} = \text{MultiHeadGraphAttention2D}(\mathbf{h}_i, \mathcal{G}) + \mathbf{h}_i$$

$$\text{4. Reshape for Spatial-Temporal Processing:}$$
$$\mathbf{h}_{spatial} = \text{reshape}(\mathbf{h}_{graph}, [batch, 2, 13, d_{model}])$$

$$\text{5. Spatial-Temporal Layers (num\_spatial\_layers times):}$$
$$\mathbf{h}_{spatial,i+1} = \text{StationAttn}(\mathbf{h}_{spatial,i})$$
$$\mathbf{h}_{spatial,i+2} = \text{FeatureAttn}(\mathbf{h}_{spatial,i+1}) + \mathbf{h}_{spatial,i+1}$$

$$\text{6. Flatten and Aggregate:}$$
$$\mathbf{h}_{flat} = \text{flatten}(\mathbf{h}_{spatial})$$
$$\mathbf{h}_{agg} = \text{StationAggregation}(\mathbf{h}_{flat})$$

$$\text{7. Final Prediction:}$$
$$\hat{y} = \sigma(\text{PredictionHead}(\mathbf{h}_{agg}))$$

**SHAP Interpretability:**
- KernelExplainer with 80 background samples
- Analyzes contribution of each feature (26 total)
- Outputs feature importance for both stations
- Feature names: `eMalahleni_PM2.5`, `Middelburg_SO2`, etc.

### 13. 2D_GraphTransformer_SpatioTemporal_air_pollution.py
- **Architecture**: Advanced 2D Spatiotemporal Graph Transformer for multi-station spatial AND temporal modeling
- **Model Size**: ~167M parameters (largest model in suite)
- **Input**: Multi-station graph data with temporal sequences and 2D positional encoding
- **Purpose**: Ultimate state-of-the-art multi-station spatial-temporal modeling combining spatial relationships with temporal dynamics
- **Data**: 
  - 2 stations merged: eMalahleni + Middelburg
  - 26 total nodes (2 × 13 features)
  - 87,622 samples after preprocessing
  - Temporal window: 24 timesteps per feature
  - Train: 52,572 | Val: 17,525 | Test: 17,525
- **Training Configuration**:
  - Batch size: 8 (due to model size and temporal complexity)
  - Epochs: 100 maximum
  - Early stopping patience: 15 epochs
  - Optimizer: AdamW (lr=0.0005, weight_decay=1e-4)
  - Scheduler: CosineAnnealingLR (T_max=50)
  - Gradient clipping: max_norm=1.0

**Architecture Components (Unique Spatiotemporal Design):**

*1. MultiHeadGraphAttention2D (Spatial)*
- Number of heads: 8
- Applied per timestep to capture spatial feature relationships
- TransformerConv layers for graph-based attention
- Processes spatial structure at each time step independently

*2. SpatialTemporalLayer (Novel Two-Dimensional Attention)*
- **Station-wise attention**: Aggregates across 2 stations while preserving feature dimension
  $$\text{for each feature } f \text{ and timestep } t:}$$
  $$h_f^{station} = \text{MultiHeadAttention}([h_{s1,f,t}, h_{s2,f,t}], [h_{s1,f,t}, h_{s2,f,t}], [h_{s1,f,t}, h_{s2,f,t}])$$
  
- **Feature-wise attention**: Aggregates across 13 features while preserving station dimension  
  $$\text{for each station } s \text{ and timestep } t:}$$
  $$h_s^{feature} = \text{MultiHeadAttention}([h_{s,f1,t}, ..., h_{s,f13,t}], ...)$$

- **Feed-forward network**: Independent processing at each position
- **Triple layer normalization**: Stabilizes learning across attention mechanisms

*3. TemporalTransformerLayer (Temporal)*
- Self-attention over 24 timesteps for all nodes
- Multi-head attention capturing temporal dependencies
- Feed-forward network with dimension expansion (d_model × 2)
- Processes all nodes and features simultaneously across time

*4. 2D + Temporal Positional Encoding (Three-Dimensional)*
$$PE_{spatial}(s, f, 2i) = \sin\left(\frac{s \times n_{features} + f}{10000^{2i/(d_{model}/2)}}\right)$$
$$PE_{temporal}(t, 2i) = \sin\left(\frac{t}{10000^{2i/(d_{model}/2)}}\right)$$
$$PE_{combined} = \text{Concatenate}(PE_{spatial}, PE_{temporal})$$
- Encodes station position, feature index, AND time step
- Full d_model dimensions = d_model/2 (spatial) + d_model/2 (temporal)

*5. Station Aggregation (Multi-Layer Hierarchy)*
- Input: Flattened spatiotemporal tensor: $(batch, 26 \times 24 \times 128)$ = $(batch, 79,872)$
- Dense layers with progressive dimension reduction
- Layer sizes: $(79,872 → 2,048 → 1,024 → 512 → 128)$ for d_model=128
- ReLU activation with dropout (0.1) between layers

*6. Prediction Head*
- Dense layers: $d_{model} → d_{model}/2 → d_{model}/4 → 1$
- Sigmoid activation for normalized output [0, 1]

**Complete Forward Pass (Spatiotemporal):**

$$\text{Input: } X \in \mathbb{R}^{26 \times 24} \quad \text{(26 nodes, 24 timesteps)}$$

$$\text{Step 1 - Input Projection (per timestep):}$$
$$H_0^{(t)} = \text{Linear}_{in}(X_{:,t}), \quad H_0^{(t)} \in \mathbb{R}^{26 \times d_{model}}$$

$$\text{Step 2 - Add Positional Encodings (Spatial + Temporal):}$$
$$H_0^{(t)} := H_0^{(t)} + PE_{spatial} + PE_{temporal}^{(t)}$$

$$\text{Step 3 - Spatial Graph Attention (per timestep, num\_graph\_layers times):}$$
$$H_1^{(t)} = \text{MultiHeadGraphAttention2D}(H_0^{(t)}, \mathcal{G})$$

$$\text{Step 4 - Reshape for Spatial-Temporal Processing:}$$
$$H_{spatial} = \text{Stack}([H_1^{(1)}, H_1^{(2)}, ..., H_1^{(24)}]) \in \mathbb{R}^{26 \times 24 \times d_{model}}$$

$$\text{Step 5 - Reshape to Decomposed Spatial Dimensions:}$$
$$H_{decomposed} = \text{Reshape}(H_{spatial}, [batch, 2, 13, 24, d_{model}])$$

$$\text{Step 6 - Station-wise Attention (num\_spatial\_layers times):}$$
$$\text{for } f=1 \text{ to } 13, t=1 \text{ to } 24:$$
$$H_{decomposed}[:, :, f, t, :] := \text{StationAttn}(H_{decomposed}[:, :, f, t, :])$$

$$\text{Step 7 - Feature-wise Attention (num\_spatial\_layers times):}$$
$$\text{for } s=1 \text{ to } 2, t=1 \text{ to } 24:$$
$$H_{decomposed}[:, s, :, t, :] := \text{FeatureAttn}(H_{decomposed}[:, s, :, t, :])$$

$$\text{Step 8 - Flatten Back to Temporal Sequence:}$$
$$H_{temporal} = \text{Reshape}(H_{decomposed}, [batch, 26, 24, d_{model}])$$

$$\text{Step 9 - Temporal Transformer (num\_temporal\_layers times):}$$
$$H_{temporal} := \text{TemporalTransformer}(H_{temporal})$$

$$\text{Step 10 - Flatten All Dimensions:}$$
$$H_{flat} = \text{Flatten}(H_{temporal}) \in \mathbb{R}^{batch \times (26 \times 24 \times d_{model})}$$

$$\text{Step 11 - Station Aggregation:}$$
$$H_{agg} = \text{StationAggregation}(H_{flat}) \in \mathbb{R}^{batch \times d_{model}}$$

$$\text{Step 12 - Final Prediction:}$$
$$\hat{y} = \sigma(\text{PredictionHead}(H_{agg})) \in [0, 1]$$

**Key Advantages Over 2D_GraphTransformer:**

| Aspect | 2D Graph Transformer | 2D Spatiotemporal Graph Transformer |
|--------|---------------------|--------------------------------------|
| **Data Type** | Single timestep (n_in=1) | Temporal sequences (seq_length=24) |
| **Temporal Modeling** | None (spatial only) | Full temporal transformer layers |
| **Graph Attention** | Applied once | Applied per timestep |
| **Positional Encoding** | 2D (station × feature) | 2.5D (station × feature × time) |
| **Attention Layers** | Station-wise + Feature-wise | Station-wise + Feature-wise + Temporal |
| **Input Dimension** | 26 nodes | 26 × 24 = 624 temporal features |
| **Parameters** | ~800K | ~167M |
| **Computational Complexity** | O(n³d) | O(n³d × t) where t=24 |
| **Use Case** | Current pollution snapshot | 24-hour trend analysis |

**SHAP Interpretability with Temporal Dimension:**
- KernelExplainer with 30 background samples
- Analyzes 624 spatiotemporal features (26 nodes × 24 timesteps)
- Feature names include temporal indicators: `t0_eMalahleni_PM2.5`, `t12_Middelburg_SO2`, etc.
- Identifies which features and time steps are most important for predictions
- Captures temporal importance patterns (e.g., recent vs. historical data)

**Mathematical Fix (Positional Encoding Bug):**
The original implementation had a dimension mismatch where spatial encoding was $d_{model}/2$ but wasn't properly combined with temporal encoding. Fixed by:
$$PE_{combined} = \text{Concatenate}(PE_{spatial}[d_{model}/2], PE_{temporal}[d_{model}/2])$$
This ensures full $d_{model}$ dimensions after projection.

### 14. 2D_GraphTransformer_Grid_Search.py
- **Purpose**: Comprehensive hyperparameter optimization for 2D Graph Transformer model (spatial only)
- **Total Combinations**: 6,561 parameter combinations
- **Search Strategy**: Nested loops with systematic exploration
- **Epochs per Configuration**: 50 (with early stopping patience=8)
- **Grid Parameters**:
  
  | Parameter | Range | Count |
  |-----------|-------|-------|
  | d_model | [64, 128, 256] | 3 |
  | num_graph_layers | [1, 2, 3] | 3 |
  | num_spatial_layers | [1, 2, 3] | 3 |
  | num_heads | [4, 8, 16] | 3 |
  | dropout | [0.1, 0.2, 0.3] | 3 |
  | learning_rate | [0.001, 0.0005, 0.0001] | 3 |
  | batch_size | [8, 16, 32] | 3 |
  | input_dim (fixed) | 1 | 1 |

- **Features**:
  - Systematic nested loop exploration (learning_rate → batch_size → dropout → heads → spatial_layers → graph_layers → d_model)
  - Early stopping per configuration
  - Memory cleanup between runs
  - CUDA support
  - Comprehensive results logging
  - Top 10 configurations tracking
  - Visualization of parameter effects

**Grid Search Mathematical Formulation:**
$$(\theta^*, \phi^*) = \arg\min_{\theta \in \Theta, \phi \in \Phi} \mathcal{L}_{val}(M(X_{val}; \theta, \phi), y_{val})$$

where:
- $\Theta$: Architecture parameters (d_model, num_graph_layers, num_spatial_layers, num_heads)
- $\Phi$: Training hyperparameters (dropout, learning_rate, batch_size)
- $\mathcal{L}_{val}$: Validation MSE loss

**Output Files:**
- `2d_graph_transformer_grid_search_results.csv`: All 6,561 results
- `2d_graph_transformer_grid_top_10.csv`: Best 10 configurations
- `2d_graph_transformer_grid_best_model.pth`: Best model weights
- `2d_graph_transformer_grid_search_analysis.png`: Performance visualizations
- `2d_graph_transformer_grid_search_summary.txt`: Executive summary

**Optimization Metrics Tracked:**
- MSE, RMSE, MAE, R² scores
- Validation loss
- Training time per configuration
- Number of parameters
- Epochs trained before early stopping

## File Organization

```
Prediction/
├── CNN LSTM-Grid search.ipynb                      # Hybrid model optimization
├── CNN LSTM.ipynb                                  # Hybrid model implementation  
├── CNN-Grid search.ipynb                           # CNN optimization
├── CNN.ipynb                                       # Pure CNN implementation
├── LSTM-Grid search.ipynb                          # LSTM optimization
├── Vanilla LSTM.ipynb                              # Basic LSTM implementation
├── 2DCNN.ipynb                                     # 2D CNN for multi-station
├── 2DCNN LSTM.ipynb                                # 2D CNN-LSTM hybrid
├── GCN_air_pollution.py                            # Graph Convolutional Network (1 station)
├── GraphTransformer_air_pollution.py               # Graph Transformer Network (1 station, ~500K params)
├── GCN_Grid_Search.py                              # GCN hyperparameter optimization
├── GraphTransformer_Grid_Search.py                 # Graph Transformer optimization (6,561 configs)
├── 2D_GCN_air_pollution.py                         # 2D GCN for multi-station spatial modeling (~150K params)
├── 2D_GraphTransformer_air_pollution.py            # 2D Graph Transformer (multi-station, spatial only, ~800K params)
├── 2D_GraphTransformer_SpatioTemporal_air_pollution.py  # 2D Spatiotemporal Graph Transformer (multi-station + temporal, ~167M params) ⭐ LARGEST
├── 2D_GraphTransformer_Grid_Search.py              # 2D Graph Transformer optimization (6,561 configs)
├── code_summary.md                                 # This comprehensive documentation
├── eMalahleniIM.csv                                # Station 1 air quality data (87,646 samples, 13 features)
└── MiddelburgIM.csv                                # Station 2 air quality data (87,647 samples, 13 features)
```

## Summary

This codebase represents a comprehensive machine learning approach to environmental health monitoring, comparing different deep learning architectures for air quality prediction with:

- **Systematic model comparison**: 16 distinct neural network approaches 
  - Single-station traditional: LSTM, CNN, CNN-LSTM (3 models + 3 grid searches)
  - Single-station graph-based: GCN, Graph Transformer (2 models + 2 grid searches)
  - Multi-station 2D: 2D CNN, 2D CNN-LSTM, 2D GCN (3 models)
  - Multi-station graph: 2D Graph Transformer (spatial), 2D Spatiotemporal Graph Transformer (spatial + temporal) (2 models + 1 grid search)

- **Progressive Complexity Levels**:
  - **Level 1 - Basic Temporal**: LSTM, CNN, CNN-LSTM for single-station temporal patterns
  - **Level 2 - Spatial Relationships**: GCN for single-station feature dependencies
  - **Level 3 - Spatial Attention**: Graph Transformer for single-station state-of-the-art
  - **Level 4 - Multi-Station 2D Spatial**: 2D CNN, 2D CNN-LSTM, 2D GCN for multi-location patterns
  - **Level 5 - Multi-Station Spatial Graphs**: 2D Graph Transformer for multi-station spatial attention
  - **Level 6 - Multi-Station Spatiotemporal**: 2D Spatiotemporal Graph Transformer (ULTIMATE APPROACH) ⭐

- **Thorough hyperparameter optimization**: 
  - GCN: 648 parameter combinations
  - Graph Transformer (single-station): 6,561 parameter combinations
  - 2D Graph Transformer (spatial only): 6,561 parameter combinations
  - Total: 13,770+ configurations explored

- **Comprehensive evaluation**: Multiple metrics (MSE, RMSE, MAE, R²) and visualization approaches
- **Model interpretability**: SHAP analysis with feature-specific names and temporal indicators for understanding predictions
- **Advanced spatial-temporal modeling**: 
  - 1D and 2D graph neural networks
  - Transformer attention mechanisms
  - Multi-level spatial (station-wise, feature-wise) and temporal attention
  - 2D/2.5D positional encoding for location and temporal awareness

- **State-of-the-art techniques**: 
  - Transformer attention with multi-head mechanisms
  - Graph neural networks for non-Euclidean relationships
  - Decomposed attention (station-wise + feature-wise)
  - 2D and 2.5D positional encodings
  - TimeDistributed convolutions
  - Residual connections and layer normalization

- **Multi-dimensional analysis**: 
  - 1D temporal: LSTM, CNN for single station time series
  - 2D spatial: 2D CNN, 2D CNN-LSTM for multi-station grid arrangements
  - Graph-based: GCN, Graph Transformer for feature dependencies
  - 2.5D spatiotemporal: 2D Spatiotemporal Graph Transformer for full spatial-temporal integration

- **Practical application**: Real-world air quality forecasting for health impact assessment across multiple monitoring stations

### Model Progression with Key Differences:

**1. Single-Station Models (LSTM, CNN, CNN-LSTM)**
- Input: 13 features × 1 timestep
- Output: Single pollution prediction
- Use case: Quick baseline comparison

**2. Single-Station Graph Models (GCN, Graph Transformer)**
- Input: 13-node graph × temporal sequences
- Graph structure: Feature correlation-based
- Graph Transformer advantages:
  - Multi-head attention over features
  - Temporal transformer for time series
  - Better feature importance understanding via attention weights

**3. Multi-Station 2D Models (2D CNN, 2D CNN-LSTM)**
- Input: 2 stations × 13 features = 2D grid
- 2D kernel operations across stations and features
- Limitation: Single timestep (no temporal modeling except in CNN-LSTM)

**4. 2D Graph Transformer (Spatial Only)**
- Input: 26-node graph (2 stations × 13 features), single timestep
- Graph structure: Multi-level (intra-station, inter-station, cross-feature)
- Attention: Station-wise + Feature-wise decomposed attention
- Parameters: ~800K
- Strength: Spatial relationships between stations and features

**5. 2D Spatiotemporal Graph Transformer (ULTIMATE) ⭐**
- Input: 26-node graph × 24 timesteps = 624 temporal features
- Graph structure: Multi-level spatial + 24-hour temporal sequences
- Attention: Station-wise + Feature-wise + Temporal (three decomposed attention layers)
- Parameters: **~167M** (most capable)
- Strengths:
  - Captures spatial dependencies between stations
  - Captures feature interdependencies 
  - Captures 24-hour temporal patterns
  - Can identify importance of recent vs. historical data
  - Analyzes how pollution propagates across time and space

### Why 2D Spatiotemporal Graph Transformer is Ultimate:

| Capability | 2D GraphTransformer | 2D Spatiotemporal |
|------------|-------------------|-------------------|
| Multi-station data | ✓ | ✓ |
| Spatial relationships | ✓ (complete) | ✓ (complete) |
| 24-hour history | ✗ (single timestep) | ✓ (full sequences) |
| Temporal dependencies | ✗ | ✓ (timestamp-aware) |
| Temporal attention weights | ✗ | ✓ (what times matter) |
| Explainability via time | ✗ | ✓ (why + when) |
| Parameters | 800K | 167M |
| Training time | ~30 mins | Several hours |
| Best for | Snapshot analysis | Trend forecasting |

### Key Differentiators of 2D Spatiotemporal Model:

- **Data Integration**: Full 24-hour temporal sequences merged with 2 stations
- **Graph Construction**: Multi-level edges (intra-station, inter-station, cross-feature, all weighted)
- **Spatial Attention**: Station-wise (2 stations) and feature-wise (13 features) decomposed attention
- **Temporal Attention**: Explicit temporal transformer learning which timesteps matter
- **2.5D Positional Encoding**: Encodes station position, feature index, AND time step simultaneously
- **Model Scale**: 167M parameters for capturing complex spatiotemporal patterns
- **SHAP Analysis**: 624 spatiotemporal features with temporal indicators (t0_station_feature, t1_station_feature, etc.)

### Output Comparison:

- **2D GraphTransformer**: "The pollution at Middelburg SO2 and eMalahleni PM10 are the most important today"
- **2D Spatiotemporal**: "The pollution at Middelburg SO2 from 12 hours ago and eMalahleni PM10 from 2 hours ago are most important"

This shows how the spatiotemporal model provides superior insights into **both what and when** matter for predictions.

### File Summary:

| Type | Count | Files |
|------|-------|-------|
| Notebooks (Keras/TF) | 8 | CNN, CNN LSTM, LSTM, 2D variations + grid searches |
| Scripts (PyTorch) | 8 | GCN, GCN Grid, GraphTransformer, 2D variations, 2D Spatiotemporal |
| CSV Data | 2 | eMalahleniIM.csv, MiddelburgIM.csv |
| Documentation | 1 | code_summary.md |
| **Total** | **19** | |