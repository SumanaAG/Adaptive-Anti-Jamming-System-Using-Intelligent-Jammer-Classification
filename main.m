clc
clear
close all

% System Parameters
% numSamplesPerClass = 100000;
% totalSamples = numSamplesPerClass * 4;
% dataset = zeros(totalSamples,6);
% row = 1;

params.N = 1000;
params.PNLength = 8;

params.f = 25;

params.sweepStart = 10;
params.sweepEnd = 100;

params.fs = 800;


% fprintf('Jammer Amplitude = %.4f\n', params.A);
 params.jammerLabel = 4;
  % params.jammerLabel = randi([1 4]);

% for label = 1:4
   fprintf('Jammer Type = %d\n', params.jammerLabel);

% 
%     for sample = 1:numSamplesPerClass
 params.A = 0.5 + 2*rand;
% params.SNR = randi([0 20]);
SNR_dB = 0:2:20;

%% Number of independent trials
numTrials = 1000;

%Store BER results
BERBefore = zeros(size(SNR_dB));
BERAfter  = zeros(size(SNR_dB));

for k = 1:length(SNR_dB)
    params.SNR = SNR_dB(k);

    % Accumulate errors over 1000 trials
    totalErrorsBefore = 0;
    totalErrorsAfter  = 0;
    totalBits = 0;

    for trial = 1:numTrials

 %% Transmitter
[txSignal,bits,bpsk,pn] = transmitter(params);

%% Jammer
[jammerSignal, jammerLabel] = jammer(length(txSignal),params);

%% Channel
rxSignal = channel(txSignal,jammerSignal,params);

%% AUXILIARY ANTENNA PATH
% Auxiliary antenna receives jammer through a different path
attenuation = 0.8;
auxNoise = 0.05 * randn(size(jammerSignal));
auxSignal = attenuation * jammerSignal + auxNoise;

%% MIXER / CORRELATOR
referenceSignal = correlator(auxSignal, jammerLabel, params);

% BER Before LMS
recoveredBitsBefore = receiver(rxSignal,pn);
bitErrorsBefore = sum(bits ~= recoveredBitsBefore);

%for notch filter
convergenceTime = NaN;
steadyStateOutputPower = NaN;
jammingMargin = NaN;
SNR_improvement = NaN;

%% Adaptive Filtering

if jammerLabel == 1

    % No jammer
    filteredSignal = rxSignal;

elseif jammerLabel == 2

    % Tone jammer -> LMS
    filteredSignal = lmsfilter(rxSignal, referenceSignal);

elseif jammerLabel == 3

    % Sweep jammer -> Adaptive Notch
    [filteredSignal, convergenceTime, ...
     steadyStateOutputPower, jammingMargin, ...
     SNR_improvement] = ...
     notchfilter(rxSignal, auxSignal, txSignal, params.fs);

 elseif jammerLabel == 4

    % Broadband jammer
    % Wavelet Packet + Sub-band LMS

    filteredSignal = ...
    waveletLMSfilter(rxSignal, auxSignal);
end

%% BER After Filtering

recoveredBitsAfter = receiver(filteredSignal,pn);

bitErrorsAfter = sum(bits ~= recoveredBitsAfter);

 %% Accumulate errors

        totalErrorsBefore = ...
            totalErrorsBefore + bitErrorsBefore;

        totalErrorsAfter = ...
            totalErrorsAfter + bitErrorsAfter;

        totalBits = ...
            totalBits + length(bits);

    end

    BERBefore(k) = ...
        totalErrorsBefore / totalBits;

    BERAfter(k) = ...
        totalErrorsAfter / totalBits;


    fprintf('SNR = %2d dB : Before  = %.4f   After = %.4f\n', ...
        SNR_dB(k), ...
        BERBefore(k), ...
        BERAfter(k));
end
% features = featureextraction(rxSignal);
% 
%         % Save one row in the dataset
%         dataset(row,:) = [features jammerLabel];
% 
%         row = row + 1;
    % end
% end

% fprintf('Bit Errors = %d\n', bitErrors);
% fprintf('BER = %.4f\n', BER);

% dataset = dataset(randperm(size(dataset,1)), :);   % shuffle
% featureNames = {'rmsValue','dominantFreq','spectralBandwidth', ...
%                 'spectralEntropy','frequencyVariation','Label'};
% datasetTable = array2table(dataset, 'VariableNames', featureNames);
% writetable(datasetTable, 'jammerDataset.csv');     % save with headers
% disp('4L-sample dataset generated and saved successfully!');

% disp('Actual Labels:')
% disp(YTest(1:10))
% 
% disp('Predicted Labels:')
% disp(YPred(1:10))

%% Display
% 
% disp('================ TRANSMITTER ================')
% disp('Original Bits:')
% disp(bits)
% 
% disp('BPSK Symbols:')
% disp(bpsk)
% 
% disp('PN Sequence:')
% disp(pn)
% 
% disp('Spread Signal:')
% disp(txSignal)

% disp('================ JAMMER =====================')
% disp('Jammer Label:')
% disp(jammerLabel)
% 
% disp('Jammer Signal:')
% disp(jammerSignal)
% 
% disp('================ CHANNEL ====================')
% disp('Received Signal:')
% disp(rxSignal)

% disp('================ RECEIVER ===================')
% disp('Recovered Bits:')
% disp(recoveredBits)

% Display BER
% fprintf('BER Before LMS = %.4f\n',BERBeforeLMS);
% fprintf('BER After LMS  = %.4f\n',BERAfterLMS);


%% Plot
% figure
% 
% subplot(4,1,1)
% plot(txSignal)
% title('Spread Signal')
% 
% subplot(4,1,2)
% plot(jammerSignal)
% title('Jammer Signal')
% 
% subplot(4,1,3)
% plot(rxSignal)
% title('Received Signal')
% 
% subplot(4,1,4)
% stem(bits,'filled')
% hold on
% stem(recoveredBits,'r')
% hold off
% 
% title('Original vs Recovered Bits')
% legend('Original','Recovered')
% ylim([-0.2 1.2])

%% BER PLOT

figure;

semilogy(SNR_dB,BERBefore,'-o', ...
    'LineWidth',2, ...
    'MarkerSize',7);

hold on;

semilogy(SNR_dB,BERAfter,'-s', ...
    'LineWidth',2, ...
    'MarkerSize',7);

grid on;

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');

title('BER Performance Before and After Technique');

legend('Before ','After ', ...
    'Location','southwest');

xlim([0 20]);
