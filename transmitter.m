function [spreadSignal, bits, bpsk, pn] = transmitter(params)

%% Generate Random Bits
bits = randi([0 1],1,params.N);

%% BPSK Modulation
% 0 -> -1
% 1 -> +1
bpsk = 2*bits - 1;

%% Generate PN Sequence
pn = randi([0 1],1,params.PNLength);
pn = 2*pn - 1;

%% DSSS Spreading
spreadSignal = kron(bpsk,pn);

end
