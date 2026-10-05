function filteredSignal = waveletLMSfilter(rxSignal, auxSignal)

%% Convert signals to column vectors

rxSignal = rxSignal(:);
auxSignal = auxSignal(:);

N = length(rxSignal);

%% Wavelet packet parameters

waveletName = 'db4';
level = 3;

%% LMS parameters

mu = 0.01;
filterOrder = 8;

%% Wavelet packet decomposition

rxTree = wpdec(rxSignal, level, waveletName);
auxTree = wpdec(auxSignal, level, waveletName);

%% Initialize output

filteredSignal = zeros(N,1);

%% Process each sub-band

numBands = 2^level;

for band = 0:numBands-1

    %% Get current sub-band

    node = [level band];

    rxSubband = wprcoef(rxTree,node);
    auxSubband = wprcoef(auxTree,node);

    rxSubband = rxSubband(:);
    auxSubband = auxSubband(:);

    %% Match sub-band lengths

    L = min(length(rxSubband),length(auxSubband));

    rxSubband = rxSubband(1:L);
    auxSubband = auxSubband(1:L);

    %% Initialize LMS filter

    filteredSubband = zeros(L,1);
    weights = zeros(filterOrder,1);
    referenceBuffer = zeros(filterOrder,1);

    %% Apply LMS to current sub-band

    for n = 1:L

        referenceBuffer(2:end) = ...
            referenceBuffer(1:end-1);

        referenceBuffer(1) = auxSubband(n);

        jammerEstimate = ...
            weights' * referenceBuffer;

        error = ...
            rxSubband(n) - jammerEstimate;

        weights = weights + ...
            mu * error * referenceBuffer;

        filteredSubband(n) = error;

    end

    %% Recombine filtered sub-band

    filteredSignal(1:L) = ...
        filteredSignal(1:L) + filteredSubband;

end

%% Convert output to row vector

filteredSignal = filteredSignal(:)';

end