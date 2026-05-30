# Time Series Forecasting

Aeon provides forecasting algorithms for predicting future time series values.

## Naive and Baseline Methods

Simple forecasting strategies for comparison:

- `NaiveForecaster` - Multiple strategies: last value, mean, seasonal naive
  - Parameters: `strategy` ("last", "mean", "seasonal_last"), `seasonal_period`
  - **Use when**: Establishing baselines or simple patterns

## Statistical Models

Classical time series forecasting methods:

### ARIMA
- `ARIMA` - AutoRegressive Integrated Moving Average
  - Parameters: `p` (AR order), `d` (differencing), `q` (MA order)
  - **Use when**: Linear patterns, stationary or difference-stationary series

### Exponential Smoothing
- `ETS` - Error-Trend-Seasonal decomposition
  - Parameters: `error_type`, `trend_type`, `seasonality_type` (plus `seasonal_period`)
  - **Use when**: Trend and seasonal patterns present

### Threshold Autoregressive
- `TAR` - Threshold Autoregressive model for regime switching
- `AutoTAR` - Automated threshold discovery
  - **Use when**: Series exhibits different behaviors in different regimes

### Theta Method
- `Theta` - Classical Theta forecasting
  - Parameters: `theta`, `weight` for decomposition
  - **Use when**: Simple but effective baseline needed

### Time-Varying Parameter
- `TVP` - Time-varying parameter model with Kalman filtering
  - **Use when**: Parameters change over time

## Deep Learning Forecasters

Neural networks for complex temporal patterns:

- `TCNForecaster` - Temporal Convolutional Network
  - Dilated convolutions for large receptive fields
  - **Use when**: Long sequences, need non-recurrent architecture

- `DeepARNetwork` - Probabilistic forecasting with RNNs
  - Provides prediction intervals
  - **Use when**: Need probabilistic forecasts, uncertainty quantification

## Regression-Based Forecasting

Apply regression to lagged features:

- `RegressionForecaster` - Wraps regressors for forecasting
  - Parameters: `window_length`, `horizon`
  - **Use when**: Want to use any regressor as forecaster

## Quick Start

```python
from aeon.forecasting import NaiveForecaster
from aeon.forecasting.stats import ARIMA
import numpy as np

# Create time series
y = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

# Naive baseline
naive = NaiveForecaster(strategy="last")
naive.fit(y)
forecast_naive = naive.iterative_forecast(y, prediction_horizon=3)

# ARIMA model
arima = ARIMA(p=1, d=1, q=1)
# Multi-step forecast (next 3 steps)
forecast_arima = arima.iterative_forecast(y, prediction_horizon=3)
```

## Forecasting Horizon

The forecasting horizon (`fh`) specifies which future time points to predict:

```python
# aeon forecasters take an integer prediction horizon (number of future steps ahead)
prediction_horizon = 3
# multi-step forecast with an iterative forecaster:
# y_pred = forecaster.iterative_forecast(y, prediction_horizon=prediction_horizon)
```

## Model Selection

- **Baseline**: NaiveForecaster with seasonal_last strategy
- **Linear patterns**: ARIMA
- **Trend + seasonality**: ETS
- **Regime changes**: TAR, AutoTAR
- **Complex patterns**: TCNForecaster
- **Probabilistic**: DeepARNetwork
- **Long sequences**: TCNForecaster
- **Short sequences**: ARIMA, ETS

## Evaluation Metrics

Use standard forecasting metrics:

```python
from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    mean_absolute_percentage_error
)

# Calculate error
mae = mean_absolute_error(y_true, y_pred)
mse = mean_squared_error(y_true, y_pred)
mape = mean_absolute_percentage_error(y_true, y_pred)
```

## Exogenous Variables

Many forecasters support exogenous features:

```python
# Train with exogenous variables
forecaster.fit(y, exog=X_train)

# Multi-step forecast with future exogenous values
y_pred = forecaster.iterative_forecast(y, prediction_horizon=3, exog=X_test)
```

## Base Classes

- `BaseForecaster` - Abstract base for all forecasters
- `BaseDeepForecaster` - Base for deep learning forecasters

Extend these to implement custom forecasting algorithms.
