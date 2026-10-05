function rxSignal = channel(txSignal,jammerSignal,params)

%---------------------------------------------------
% Adds jammer and AWGN to transmitted signal
%
% r(t) = s(t) + j(t) + n(t)
%---------------------------------------------------

snr = params.SNR;

signalWithJammer = txSignal + jammerSignal;

rxSignal = awgn(signalWithJammer,snr,'measured');

end
