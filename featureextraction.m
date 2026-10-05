function features = featureextraction(rxSignal)

% Sampling frequency
fs = 800;

% Signal length
N = length(rxSignal);

%% 1. RMS

rmsValue = sqrt(mean(rxSignal.^2));


%% FFT

X = abs(fft(rxSignal));

% Positive-frequency part
halfN = floor(N/2) + 1;

X = X(1:halfN);

% Frequency vector
f = (0:halfN-1) * (fs/N);

% Power spectrum
P = X.^2;

totalPower = sum(P);


%% 2. Dominant Frequency

[~, index] = max(X);

dominantFreq = f(index);


%% 3. Spectral Bandwidth

if totalPower == 0

    spectralBandwidth = 0;

else

    % Spectral centroid
    spectralCentroid = sum(f .* P) / totalPower;

    % Spectral bandwidth
    spectralBandwidth = sqrt( ...
        sum(P .* (f - spectralCentroid).^2) / totalPower);

end


%% 4. Spectral Entropy

if totalPower == 0

    spectralEntropy = 0;

else

    % Normalize power spectrum
    probability = P / totalPower;

    % Remove zero values
    probability = probability(probability > 0);

    % Spectral entropy
    spectralEntropy = ...
        -sum(probability .* log2(probability)) / log2(length(P));

end


%% 5. Frequency Variation

% Divide the signal into 8 time segments
numSegments = 8;

segmentLength = floor(N / numSegments);

dominantFrequencies = zeros(1, numSegments);

for k = 1:numSegments

    startIndex = (k-1)*segmentLength + 1;
    endIndex = k*segmentLength;

    segment = rxSignal(startIndex:endIndex);

    % FFT of segment
    X_segment = abs(fft(segment));

    segmentN = length(segment);

    % Positive-frequency part
    halfSegmentN = floor(segmentN/2) + 1;

    X_segment = X_segment(1:halfSegmentN);

    % Frequency vector for segment
    f_segment = (0:halfSegmentN-1) * (fs/segmentN);

    % Find dominant frequency
    [~, indexSegment] = max(X_segment);

    dominantFrequencies(k) = f_segment(indexSegment);

end

% Standard deviation of dominant frequency
frequencyVariation = std(dominantFrequencies);


%% Feature Vector

features = [rmsValue ...
            dominantFreq ...
            spectralBandwidth ...
            spectralEntropy ...
            frequencyVariation];

end