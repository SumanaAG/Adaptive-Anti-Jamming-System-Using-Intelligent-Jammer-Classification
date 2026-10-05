function [jammerSignal, jammerLabel] = jammer(signalLength,params)

%------------------------------------------------------------
% Randomly generate one jammer
%
% Labels:
% 1 -> No Jammer
% 2 -> Tone Jammer
% 3 -> Sweep Jammer
% 4 -> Broadband Jammer
%------------------------------------------------------------

jammerLabel = params.jammerLabel;

t = (0:signalLength-1)/params.fs;

switch jammerLabel

    case 1          % No Jammer

        jammerSignal = zeros(1,signalLength);

    case 2          % Tone Jammer

        f = randi([10 100]);             % Frequency (Hz)
        A = params.A;              % Amplitude

        jammerSignal = A*sin(2*pi*f*t);
        
     case 3          % Sweep Jammer

    A = params.A;

    sweepStart = randi([10 40]);
    sweepEnd   = randi([70 120]);

    jammerSignal = A * chirp( ...
        t, ...
        sweepStart, ...
        t(end), ...
        sweepEnd);
    case 4          % Broadband Jammer

        A = params.A;

        jammerSignal = A*randn(1,signalLength);


end

end