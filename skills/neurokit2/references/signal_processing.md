# General Signal Processing

## Overview

NeuroKit2 provides comprehensive signal processing utilities applicable to any time series data. These functions support filtering, transformation, peak detection, decomposition, and analysis operations that work across all signal types.

## Preprocessing Functions

### signal_filter()

Apply frequency-domain filtering to remove noise or isolate frequency bands.

```python
filtered = nk.signal_filter(signal, sampling_rate=1000, lowcut=None, highcut=None,
                            method='butterworth', order=2)
```

**Filter types (via lowcut/highcut combinations):**

**Lowpass** (highcut only):
```python
lowpass = nk.signal_filter(signal, sampling_rate=1000, highcut=50)
```
- Removes frequencies above highcut
- Smooths signal, removes high-frequency noise

**Highpass** (lowcut only):
```python
highpass = nk.signal_filter(signal, sampling_rate=1000, lowcut=0.5)
```
- Removes frequencies below lowcut
- Removes baseline drift, DC offset

**Bandpass** (both lowcut and highcut):
```python
bandpass = nk.signal_filter(signal, sampling_rate=1000, lowcut=0.5, highcut=50)
```
- Retains frequencies between lowcut and highcut
- Isolates specific frequency band

**Bandstop/Notch** (powerline removal):
```python
notch = nk.signal_filter(signal, sampling_rate=1000, method='powerline', powerline=50)
```
- Removes 50 or 60 Hz powerline noise
- Narrow notch filter

**Methods:**
- `'butterworth'` (default): Smooth frequency response, flat passband
- `'bessel'`: Linear phase, minimal ringing
- `'chebyshev1'`: Steeper rolloff, ripple in passband
- `'chebyshev2'`: Steeper rolloff, ripple in stopband
- `'elliptic'`: Steepest rolloff, ripple in both bands
- `'powerline'`: Notch filter for 50/60 Hz

**Order parameter:**
- Higher order: Steeper transition, more ringing
- Lower order: Gentler transition, less ringing
- Typical: 2-5 for physiological signals

### signal_sanitize()

Drop a Pandas Series' custom index, returning the values as a plain NumPy array (use after set_index). It does not remove NaN/inf; use `signal_fillmissing` or pandas `dropna` for that.

```python
clean_signal = nk.signal_sanitize(signal)
```

**Use cases:**
- Handle missing data points
- Remove artifacts marked as NaN
- Prepare signal for algorithms requiring continuous data

### signal_resample()

Change sampling rate of signal (upsample or downsample).

```python
resampled = nk.signal_resample(signal, sampling_rate=1000, desired_sampling_rate=500,
                               method='interpolation')
```

**Methods:**
- `'interpolation'`: Cubic spline interpolation
- `'FFT'`: Frequency-domain resampling
- `'poly'`: Polyphase filtering (best for downsampling)

**Use cases:**
- Match sampling rates across multi-modal recordings
- Reduce data size (downsample)
- Increase temporal resolution (upsample)

### signal_fillmissing()

Interpolate missing or invalid data points.

```python
filled = nk.signal_fillmissing(signal, method='linear')
```

**Methods:**
- `'linear'`: Linear interpolation
- `'nearest'`: Nearest neighbor
- `'pad'`: Forward/backward fill
- `'cubic'`: Cubic spline
- `'polynomial'`: Polynomial fitting

## Transformation Functions

### signal_detrend()

Remove slow trends from signal.

```python
detrended = nk.signal_detrend(signal, method='polynomial', order=1)
```

**Methods:**
- `'polynomial'`: Fit and subtract polynomial (order 1 = linear)
- `'loess'`: Locally weighted regression
- `'tarvainen2002'`: Smoothness priors detrending

**Use cases:**
- Remove baseline drift
- Stabilize mean before analysis
- Prepare for stationarity-assuming algorithms

### signal_decompose()

Decompose signal into constituent components.

```python
components = nk.signal_decompose(signal, sampling_rate=1000, method='emd')
```

**Methods:**

**Empirical Mode Decomposition (EMD):**
```python
components = nk.signal_decompose(signal, sampling_rate=1000, method='emd')
```
- Data-adaptive decomposition into Intrinsic Mode Functions (IMFs)
- Each IMF represents different frequency content (high to low)
- No predefined basis functions
- Requires the optional `EMD-signal` package (`uv pip install EMD-signal`); the `'ssa'` method below has no extra dependency

**Singular Spectrum Analysis (SSA):**
```python
components = nk.signal_decompose(signal, method='ssa')
```
- Decomposes into trend, oscillations, and noise
- Based on eigenvalue decomposition of trajectory matrix

**Wavelet decomposition:**
- Time-frequency representation
- Localized in both time and frequency

**Returns:**
- Dictionary with component signals
- Trend, oscillatory components, residual

**Use cases:**
- Isolate physiological rhythms
- Separate signal from noise
- Multi-scale analysis

### signal_recompose()

Reconstruct signal from decomposed components.

```python
reconstructed = nk.signal_recompose(components, method='wcorr', threshold=0.5)
```

**Use case:**
- Selective reconstruction after decomposition
- Remove specific IMFs or components
- Adaptive filtering

### signal_binarize()

Convert continuous signal to binary (0/1) based on threshold.

```python
binary = nk.signal_binarize(signal, method='threshold', threshold=0.5)
```

**Methods:**
- `'threshold'` (default): Values above `threshold` become 1 (default `threshold='auto'`, i.e. the signal mean)
- `'mixture'`: Gaussian mixture model (two-class clustering into 0/1)

**Use case:**
- Event detection from continuous signal
- Trigger extraction
- State classification

### signal_distort()

Add controlled noise or artifacts for testing.

```python
distorted = nk.signal_distort(signal, sampling_rate=1000, noise_amplitude=0.1,
                              noise_frequency=50, artifacts_amplitude=0.5)
```

**Parameters:**
- `noise_amplitude`: Gaussian noise level
- `noise_frequency`: Sinusoidal interference (e.g., powerline)
- `artifacts_amplitude`: Random spike artifacts
- `artifacts_number`: Number of artifacts to add

**Use cases:**
- Algorithm robustness testing
- Preprocessing method evaluation
- Realistic data simulation

### signal_interpolate()

Interpolate signal at new time points or fill gaps.

```python
interpolated = nk.signal_interpolate(x_values, y_values, x_new=None, method='quadratic')
```

**Methods:**
- `'linear'`, `'quadratic'`, `'cubic'`: Polynomial interpolation
- `'nearest'`: Nearest neighbor
- `'monotone_cubic'`: Preserves monotonicity

**Use case:**
- Convert irregular samples to regular grid
- Upsample for visualization
- Align signals with different time bases

### signal_merge()

Combine multiple signals with different sampling rates.

```python
merged = nk.signal_merge(signal1, signal2, time1=None, time2=None, sampling_rate=None)
```

**Use case:**
- Multi-modal signal integration
- Combine data from different devices
- Synchronize based on timestamps

### signal_flatline()

Identify periods of constant signal (artifacts or sensor failure).

```python
flatline_pct = nk.signal_flatline(signal, threshold=0.01)
```

**Returns:**
- `float`: the proportion (0.0-1.0) of samples where the signal is flat (consecutive absolute difference < threshold)

### signal_noise()

Generate colored noise (it does not take an input signal; to add noise to a signal use `signal_distort`).

```python
noise = nk.signal_noise(duration=10, sampling_rate=1000, beta=1)  # beta: 0=white, 1=pink, 2=brown
```

**Noise types:**
- `'gaussian'`: White noise
- `'pink'`: 1/f noise (common in physiological signals)
- `'brown'`: Brownian (random walk)
- `'powerline'`: Sinusoidal interference (50/60 Hz)

### signal_surrogate()

Generate surrogate signals preserving certain properties.

```python
surrogate = nk.signal_surrogate(signal, method='IAAFT')
```

**Methods:**
- `'IAAFT'`: Iterated Amplitude Adjusted Fourier Transform
  - Preserves amplitude distribution and power spectrum
- `'random_shuffle'`: Random permutation (null hypothesis testing)

**Use case:**
- Nonlinearity testing
- Null hypothesis generation for statistical tests

## Peak Detection and Correction

### signal_findpeaks()

Detect local maxima (peaks) in signal.

```python
peaks_dict = nk.signal_findpeaks(signal, height_min=None, height_max=None,
                                 relative_height_min=None, relative_height_max=None)
```

**Key parameters:**
- `height_min/max`: Absolute amplitude thresholds
- `relative_height_min/max`: Height thresholds relative to a baseline (in SD units)
- `relative_mean` / `relative_median` / `relative_max`: Choose the baseline for the relative thresholds (mean is the default)

**Returns:**
- Dictionary with keys:
  - `'Peaks'`: Peak indices
  - `'Distance'`: Inter-peak intervals
  - `'Height'`: Peak amplitudes
  - `'Width'`, `'Onsets'`, `'Offsets'`: Peak width and onset/offset indices

**Use cases:**
- Generic peak detection for any signal
- R-peaks, respiratory peaks, pulse peaks
- Event detection

### signal_fixpeaks()

Correct detected peaks for artifacts and anomalies.

```python
corrected = nk.signal_fixpeaks(peaks, sampling_rate=1000, iterative=True,
                               method='Kubios', interval_min=None, interval_max=None)
```

**Methods:**
- `'Kubios'`: Kubios HRV software method (default)
- `'Malik1996'`: Task Force Standards (1996)
- `'Kamath1993'`: Kamath's approach

**Corrections:**
- Remove physiologically implausible intervals
- Interpolate missing peaks
- Remove extra detected peaks (duplicates)

**Use case:**
- Artifact correction in R-R intervals
- Improve HRV analysis quality
- Respiratory or pulse peak correction

## Analysis Functions

### signal_rate()

Compute instantaneous rate from event occurrences (peaks).

```python
rate = nk.signal_rate(peaks, sampling_rate=1000, desired_length=None)
```

**Method:**
- Calculate inter-event intervals
- Convert to events per minute
- Interpolate to match desired length

**Use case:**
- Heart rate from R-peaks
- Breathing rate from respiratory peaks
- Any periodic event rate

### signal_period()

Compute the instantaneous period (in seconds) from detected event locations (peaks).

```python
period = nk.signal_period(peaks, sampling_rate=1000, desired_length=None,
                          interpolation_method='monotone_cubic')
```

**Parameters:**
- `peaks`: Indices (or a boolean/marker array) of detected events, e.g. R-peaks from `ecg_peaks`
- `desired_length`: If set, interpolate the period series to this length (e.g. the original signal length)
- `interpolation_method`: Interpolation used between events (default `'monotone_cubic'`)

**Returns:**
- An array of the period (in seconds) between successive events, optionally interpolated to `desired_length`

**Use case:**
- Period (and, as its reciprocal, rate) from cardiac or respiratory peaks
- Convert event series to a continuous instantaneous-period signal

### signal_phase()

Compute instantaneous phase of signal.

```python
phase = nk.signal_phase(signal, method='radians')
```

**Methods (output units):**
- `'radians'`: Phase in radians (default)
- `'degrees'`: Phase between 0 and 360
- `'percents'`: Phase between 0 and 1

**Returns:**
- Phase in radians (-π to π) or 0 to 1 (normalized)

**Use cases:**
- Phase-locked analysis
- Synchronization measures
- Phase-amplitude coupling

### signal_psd()

Compute Power Spectral Density.

```python
psd_df = nk.signal_psd(signal, sampling_rate=1000, method='welch', show=False)
# psd_df is a DataFrame with columns "Frequency" and "Power"
```

**Methods:**
- `'welch'`: Welch's periodogram (windowed FFT, default)
- `'multitapers'`: Multitaper method (superior spectral estimation; requires the optional `mne` package)
- `'lomb'`: Lomb-Scargle (unevenly sampled data; requires the optional `astropy` package)
- `'burg'`: Autoregressive (parametric)

**Returns:**
- A DataFrame with columns `Frequency` (Hz) and `Power` (units²/Hz)

**Use case:**
- Frequency content analysis
- HRV frequency domain
- Spectral signatures

### signal_power()

Compute power in specific frequency bands.

```python
power_df = nk.signal_power(signal, frequency_band=[(0.003, 0.04), (0.04, 0.15), (0.15, 0.4)], sampling_rate=1000)
```

**Returns:**
- Dictionary with absolute and relative power per band
- Peak frequencies

**Use case:**
- HRV frequency analysis
- EEG band power
- Rhythm quantification

### signal_autocor()

Compute autocorrelation function.

```python
autocorr, info = nk.signal_autocor(signal, lag=1000, show=False)
```

**Interpretation:**
- High autocorrelation at lag: signal repeats every lag samples
- Periodic signals: peaks at multiples of period
- Random signals: rapid decay to zero

**Use cases:**
- Detect periodicity
- Assess temporal structure
- Memory in signal

### signal_zerocrossings()

Count zero crossings (sign changes).

```python
n_crossings = nk.signal_zerocrossings(signal)
```

**Interpretation:**
- More crossings: higher frequency content
- Related to dominant frequency (rough estimate)

**Use case:**
- Simple frequency estimation
- Signal regularity assessment

### signal_changepoints()

Detect abrupt changes in signal properties (mean, variance).

```python
changepoints = nk.signal_changepoints(signal, change='meanvar', penalty=10, show=False)
```

**Parameter:**
- `change='meanvar'` (default): detect changes in the signal's mean and variance

**Parameters:**
- `penalty`: Controls sensitivity (higher = fewer changepoints)

**Returns:**
- Indices of detected changepoints
- Segments between changepoints

**Use cases:**
- Segment signal into states
- Detect transitions (e.g., sleep stages, arousal states)
- Automatic epoch definition

### signal_synchrony()

Assess synchronization between two signals.

```python
sync = nk.signal_synchrony(signal1, signal2, method='correlation')
```

**Methods:**
- `'hilbert'` (default): instantaneous phase synchrony via the Hilbert transform
- `'correlation'`: rolling-window Pearson correlation

**Use cases:**
- Heart-brain coupling
- Inter-brain synchrony
- Multi-channel coordination

### signal_smooth()

Apply smoothing to reduce noise.

```python
smoothed = nk.signal_smooth(signal, method='convolution', kernel='boxzen', size=10)
```

**Methods:**
- `'convolution'`: Apply kernel (boxcar, Gaussian, etc.)
- `'median'`: Median filter (robust to outliers)
- `'savgol'`: Savitzky-Golay filter (preserves peaks)
- `'loess'`: Locally weighted regression

**Kernel types (for convolution):**
- `'boxcar'`: Simple moving average
- `'gaussian'`: Gaussian-weighted average
- `'hann'`, `'hamming'`, `'blackman'`: Windowing functions

**Use cases:**
- Noise reduction
- Trend extraction
- Visualization enhancement

### signal_timefrequency()

Time-frequency representation (spectrogram).

```python
tf, time, freq = nk.signal_timefrequency(signal, sampling_rate=1000, method='stft',
                                        max_frequency=50, show=False)
```

**Methods:**
- `'stft'`: Short-Time Fourier Transform
- `'cwt'`: Continuous Wavelet Transform

**Returns:**
- `tf`: Time-frequency matrix (power at each time-frequency point)
- `time`: Time bins
- `freq`: Frequency bins

**Use cases:**
- Non-stationary signal analysis
- Time-varying frequency content
- EEG/MEG time-frequency analysis

## Simulation

### signal_simulate()

Generate various synthetic signals for testing.

```python
signal = nk.signal_simulate(duration=10, sampling_rate=1000, frequency=[5, 10],
                            amplitude=[1.0, 0.5], noise=0.1)
```

**Signal types:**
- Sinusoidal oscillations (specify frequencies)
- Multiple frequency components
- Gaussian noise
- Combinations

**Use cases:**
- Algorithm testing
- Method validation
- Educational demonstrations

## Visualization

### signal_plot()

Visualize signal and optional markers.

```python
nk.signal_plot(signal, sampling_rate=1000, peaks=None, show=True)
```

**Features:**
- Time axis in seconds
- Peak markers
- Multiple subplots for signal arrays

## Practical Tips

**Choosing filter parameters:**
- **Lowcut**: Set below lowest frequency of interest
- **Highcut**: Set above highest frequency of interest
- **Order**: Start with 2-5, increase if transition too slow
- **Method**: Butterworth is safe default

**Handling edge effects:**
- Filtering introduces artifacts at signal edges
- Pad signal before filtering, then trim
- Or discard initial/final seconds

**Dealing with gaps:**
- Small gaps: `signal_fillmissing()` with interpolation
- Large gaps: Segment signal, analyze separately
- Mark gaps as NaN, use interpolation carefully

**Combining operations:**
```python
# Typical preprocessing pipeline
signal = nk.signal_sanitize(raw_signal)  # reset to default integer index
signal = nk.signal_filter(signal, sampling_rate=1000, lowcut=0.5, highcut=40)  # Bandpass
signal = nk.signal_detrend(signal, method='polynomial', order=1)  # Remove linear trend
```

**Performance considerations:**
- Filtering: FFT-based methods faster for long signals
- Resampling: Downsample early in pipeline to speed up
- Large datasets: Process in chunks if memory-limited

## References

- Virtanen, P., et al. (2020). SciPy 1.0: fundamental algorithms for scientific computing in Python. Nature methods, 17(3), 261-272.
- Tarvainen, M. P., Ranta-aho, P. O., & Karjalainen, P. A. (2002). An advanced detrending method with application to HRV analysis. IEEE Transactions on Biomedical Engineering, 49(2), 172-175.
- Huang, N. E., et al. (1998). The empirical mode decomposition and the Hilbert spectrum for nonlinear and non-stationary time series analysis. Proceedings of the Royal Society of London A, 454(1971), 903-995.
