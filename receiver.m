function recoveredBits = receiver(rxSignal,pn)

pnLength = length(pn);

numBits = length(rxSignal)/pnLength;

recoveredBits = zeros(1,numBits);

index = 1;

for i = 1:numBits

    chips = rxSignal(index:index+pnLength-1);

    despread = chips .* pn;

    value = sum(despread);

    if value >= 0
        recoveredBits(i) = 1;
    else
        recoveredBits(i) = 0;
    end

    index = index + pnLength;

end

end