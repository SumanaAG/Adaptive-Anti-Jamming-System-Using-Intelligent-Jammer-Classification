function filteredSignal = lmsfilter(rxSignal, referenceSignal)

mu = 0.001;

N = length(rxSignal);

w = 0;

filteredSignal = zeros(size(rxSignal));

for n = 1:N

    x = referenceSignal(n);

    jammerEstimate = w * x;

    error = rxSignal(n) - jammerEstimate;

    w = w + mu * error * x;

    filteredSignal(n) = error;

end

end