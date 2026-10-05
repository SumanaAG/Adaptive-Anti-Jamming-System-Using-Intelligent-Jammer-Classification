function referenceSignal = correlator(auxSignal, jammerType, params)

switch jammerType

    case 1
        referenceSignal = zeros(size(auxSignal));

    case 2
        referenceSignal = auxSignal;

    case 3
        referenceSignal = auxSignal;

end

end