clear
clc
close all
f = fopen('input.txt','r');
input = fscanf(f, 'time %f voltage %f\n',[2 inf]);
fclose(f);
%input(2,:) = input(2,:)-mean(input(2,:));

f = fopen('output.txt','r');
output = fscanf(f, 'time %f vel %f\n',[2 inf]);
fclose(f);

% sigma = 25000;
% output(2,:) = output(2,:)-mean(output(2,:));
% for i=2:size(output,2)
%     if (abs(output(2,i))>sigma)
%         output(2,i) = output(2,i-1);
%     end
% end
% output(2,:) = output(2,:)-mean(output(2,:));

Fs = 500;
T = 1/Fs;
L = size(output,2);
t = (0:L-1)*T;
x = input(2,1:end-1);
y = output(2,1:end)-output(2,1);
%%
NFFT = 2^nextpow2(L);
X = fft(x,NFFT)/L;
Y = fft(y,NFFT)/L;
fdomain = Fs/2*linspace(0,1,NFFT/2+1);

Fpass = 20;              % Passband Frequency
Fstop = 21;              % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);


xf = filter(Hd,x);
yf = filter(Hd,y);
start = 2000;
xf = xf(start:end);
yf = yf(start:end);

Lf = size(yf,2);
tf = (0:Lf-1)*T;

xdft = fft(xf,NFFT)/Lf;
ydft = fft(yf,NFFT)/Lf;



figure()
subplot(2,1,1)
plot(Fs*t,x)
title('Input Voltage Signal')
xlabel('time (10 ms)')
subplot(2,1,2)
plot(Fs*tf,xf)
title('Filtered Input Voltage Signal')
xlabel('time (10 ms)')

figure()
subplot(2,1,1)
plot(Fs*t,y)
title('Output Vel Signal')
xlabel('time (10 ms)')
subplot(2,1,2)
plot(Fs*tf,yf)
title('Filtered Input Voltage Signal')
xlabel('time (10 ms)')


figure()
subplot(2,1,1)
semilogx(fdomain, 2*abs(X(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
subplot(2,1,2)
semilogx(fdomain, 2*abs(xdft(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of filtered x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')

figure()
subplot(2,1,1)
semilogx(fdomain, 2*abs(Y(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
subplot(2,1,2)
semilogx(fdomain, 2*abs(ydft(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of filtered y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

g = ydft./X;

sampled_freq =[0.1,0.5,0.7,3,5,7,9];
bi = interp1(fdomain,abs(g(1:NFFT/2+1)),sampled_freq);
phi = interp1(fdomain,angle(g(1:NFFT/2+1)),sampled_freq);

figure()
subplot(2,1,1)
plot(fdomain(2:end), abs(g(2:NFFT/2+1)));
title('Transfer function amplitude')
subplot(2,1,2)
plot(fdomain(2:end),angle(g(2:NFFT/2+1)));
title('Transfer function phase')


figure()
subplot(2,1,1)
plot(sampled_freq, bi,'o');
title('Sampled Transfer function amplitude')
subplot(2,1,2)
plot(sampled_freq,phi,'o');
title('Sampled Transfer function phase')



%%

data = iddata(y',x',T);
data.int='foh';
Datf = fft(data);
figure()
plot(Datf)

ge = etfe(data);
gs = spa(data);
figure()
bode(ge,gs)


