clear
clc
close all
f = fopen('input.txt','r');
input = fscanf(f, 'time %f voltage %f\n',[2 inf]);
fclose(f);
input(2,:) = input(2,:)-mean(input(2,:));

f = fopen('output.txt','r');
output = fscanf(f, 'time %f vel %f\n',[2 inf]);
fclose(f);

for i=10:size(output,2)
    if (output(i)>5e4 || output(i)<2e4)
        output(i) = output(i-1);
    end
end
output(2,:) = output(2,:)-mean(output(2,:));

Fs = 100;
T = 1/Fs;
L = size(output,2);
t = (0:L-1)*T;
x = input(2,1:end-1);
y = output(2,:);

figure()
plot(Fs*t,x)
title('Input Voltage Signal')
xlabel('time (10 ms)')

figure()
plot(Fs*t,y)
title('Output Vel Signal')
xlabel('time (10 ms)')

NFFT = 2^nextpow2(L);
X = fft(x,NFFT)/L;
Y = fft(y,NFFT)/L;
fdomain = Fs/2*linspace(0,1,NFFT/2+1);

figure()
plot(fdomain, 2*abs(X(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')

figure()
plot(fdomain, 2*abs(Y(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')


Fstop1 = 3;               % First Stopband Frequency
Fpass1 = 3.5;             % First Passband Frequency
Fpass2 = 22;              % Second Passband Frequency
Fstop2 = 23;              % Second Stopband Frequency
Dstop1 = 0.001;           % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

xf = filter(Hd,x);
yf = filter(Hd,y);
xdft = fft(xf,NFFT)/L;
ydft = fft(yf,NFFT)/L;

figure()
plot(fdomain, 2*abs(xdft(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of filtered x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')

figure()
plot(fdomain, 2*abs(ydft(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of filtered y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

g = ydft./xdft;

sampled_freq =[5,7,9,11,14,17,20];
bi = interp1(fdomain,abs(g(1:NFFT/2+1)),sampled_freq);
phi = interp1(fdomain,angle(g(1:NFFT/2+1)),sampled_freq);

figure()
subplot(2,1,1)
plot(fdomain, abs(g(1:NFFT/2+1)));
subplot(2,1,2)
plot(fdomain,angle(g(1:NFFT/2+1)));


figure()
subplot(2,1,1)
plot(sampled_freq, bi,'o');
subplot(2,1,2)
plot(sampled_freq,phi,'o');



%%

data = iddata(y',x',T);
data.int='foh';
Datf = fft(data);
figure()
plot(Datf)

ge = etfe(data);
gs = spa(data);
figure()
bode(ge)


