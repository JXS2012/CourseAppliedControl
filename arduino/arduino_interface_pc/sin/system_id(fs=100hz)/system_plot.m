[mags,phases,wout] = bode(n4s2);
mag = zeros(1,size(mags,3));
for i = 1:size(mags,3)
    mag(i) = 20*log(mags(1,1,i))/log(10);
end

phase = zeros(1,size(phases,3));
for i = 1:size(phases,3)
    phase(i) = phases(1,1,i);
end

figure(1)
subplot(2,1,1);
semilogx(wout,mag);
xlabel('freq(rad/s)');
ylabel('Magnitude(dB)');

subplot(2,1,2);
semilogx(wout,phase);
xlabel('freq(rad/s)');
ylabel('Phase(deg)');