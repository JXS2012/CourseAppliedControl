function Hd = hp
%HP Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.8 and the Signal Processing Toolbox 6.11.
%
% Generated on: 05-Dec-2014 17:15:16
%

% FIR Window Highpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 100;  % Sampling Frequency

Fstop = 0.05;            % Stopband Frequency
Fpass = 0.08;            % Passband Frequency
Dstop = 0.0001;          % Stopband Attenuation
Dpass = 0.057501127785;  % Passband Ripple
flag  = 'scale';         % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fstop Fpass]/(Fs/2), [0 1], [Dpass Dstop]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
Hd = dfilt.dffir(b);

% [EOF]
