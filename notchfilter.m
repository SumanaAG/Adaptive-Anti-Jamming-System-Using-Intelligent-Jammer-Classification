function [filteredSignal, convergenceTime, steadyStateOutputPower, ...
          jammingMargin, SNR_improvement] = ...
          notchfilter(rxSignal, auxSignal, txSignal, fs)

N = length(rxSignal);

filteredSignal = zeros(size(rxSignal));

%% PARAMETERS

r = 0.999;                 % Very narrow notch

minFreq = 10;
maxFreq = 100;

%% FREQUENCY ESTIMATION

aux = auxSignal(:);

% Remove DC
aux = aux - mean(aux);

% Analytic signal
z = hilbert(aux);

% Instantaneous phase
phase = unwrap(angle(z));

% Instantaneous frequency
instFreq = [0; diff(phase)] * fs/(2*pi);

% Smooth frequency estimate
instFreq = movmean(instFreq,15);

% Limit frequency
instFreq(instFreq < minFreq) = minFreq;
instFreq(instFreq > maxFreq) = maxFreq;

freqHistory = instFreq(:)';

%% FILTER STATES

x1 = 0;
x2 = 0;

y1 = 0;
y2 = 0;

%% ADAPTIVE NOTCH FILTER

for n = 1:N

    notchFreq = freqHistory(n);

    w0 = 2*pi*notchFreq/fs;

    % Notch coefficients
    b0 = 1;
    b1 = -2*cos(w0);
    b2 = 1;

    a1 = -2*r*cos(w0);
    a2 = r^2;

    x0 = rxSignal(n);

    y0 = b0*x0 + b1*x1 + b2*x2 ...
         - a1*y1 - a2*y2;

    filteredSignal(n) = y0;

    % Update states
    x2 = x1;
    x1 = x0;

    y2 = y1;
    y1 = y0;

end

%% CONVERGENCE TIME
actualFreq = linspace(minFreq,maxFreq,N);

freqError = abs(freqHistory - actualFreq);

freqThreshold = 5;       % ±5 Hz

stableSamples = round(0.05*fs);

convergenceSample = NaN;

for n = 1:(N-stableSamples)

    if all(freqError(n:n+stableSamples) < freqThreshold)

        convergenceSample = n;
        break;

    end

end

if ~isnan(convergenceSample)

    convergenceTime = convergenceSample/fs;

else

    convergenceTime = NaN;

end

%% STEADY STATE OUTPUT POWER
steadyStart = round(0.9*N);

steadyStateSignal = ...
    filteredSignal(steadyStart:end);

steadyStateOutputPower = ...
    mean(abs(steadyStateSignal).^2);

%% MATCH LENGTHS
L = min([length(rxSignal), ...
         length(filteredSignal), ...
         length(txSignal)]);

rx = rxSignal(1:L);
out = filteredSignal(1:L);
tx = txSignal(1:L);

%% SNR BEFORE

errorBefore = rx - tx;

signalPower = mean(abs(tx).^2);

errorPowerBefore = ...
    mean(abs(errorBefore).^2);

SNR_before = ...
    10*log10(signalPower/errorPowerBefore);

%% SNR AFTER
errorAfter = out - tx;

errorPowerAfter = ...
    mean(abs(errorAfter).^2);

SNR_after = ...
    10*log10(signalPower/errorPowerAfter);

%% SNR IMPROVEMENT


SNR_improvement = ...
    SNR_after - SNR_before;

%% JAMMING SUPPRESSION


jammerBefore = rx - tx;
jammerAfter = out - tx;

jammerPowerBefore = ...
    mean(abs(jammerBefore).^2);

jammerPowerAfter = ...
    mean(abs(jammerAfter).^2);

jammingMargin = ...
    10*log10(jammerPowerBefore/jammerPowerAfter);

end