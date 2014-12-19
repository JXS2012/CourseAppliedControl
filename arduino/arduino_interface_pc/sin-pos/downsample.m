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

Fs = 500;
T = 1/Fs;
tend = min(input(1,end),output(1,end));
tstart = max(input(1,1),output(1,1));
t = tstart:T:tend;
u = interp1(input(1,:),input(2,1:end),t);
y = interp1(output(1,:),output(2,1:end)-output(2,1),t);
vel = diff(y)*Fs;
vel = [vel,vel(end)];

velf = vel;
for i = 2:size(velf,2)
   if abs(velf(i)-velf(i-1))>320
       velf(i) = velf(i-1);
   end
end

yf = y;
for i = 2:size(yf,2)
    if ((abs(yf(i)-yf(i-1))>2.4e5/Fs) || (abs(yf(i)-yf(i-1))<1e5/Fs))
        yf(i:end) = yf(i:end)-(yf(i)-yf(i-1));
    end
end

velff = diff(yf)*Fs;
velff = [velff,velff(end)];

for i = 2:size(velff,2)
    if (velff(i) == 0)
        velff(i) = velff(i-1);
    end
end

vellp = vel;
lpstep = 5;
for i = lpstep+1:size(y,2)
    vellp(i) = (yf(i)-yf(i-lpstep))/lpstep*Fs;
end

figure()
plot(vellp,'-r');
hold on
plot(velff,'-y');
%%
L = size(x,2);
NFFT = 2^nextpow2(L);
X = fft(x,NFFT)/L;
fdomain = Fs/2*linspace(0,1,NFFT/2+1);

figure()
subplot(2,1,1)
semilogx(fdomain, 2*abs(X(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
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


