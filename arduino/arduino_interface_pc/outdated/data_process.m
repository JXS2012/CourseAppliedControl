clear
clc
f = fopen('100hz/input.txt','r');
input = fscanf(f, 'time %f voltage %f\n',[2 inf]);
fclose(f);

f = fopen('100hz/output.txt','r');
output = fscanf(f, 'time %f vel %f\n',[2 inf]);
fclose(f);

for i=10:size(output,2)
    if (output(i)>5e4 || output(i)<2e4)
        output(i) = output(i-1);
    end
end

% sample_rate = 100.;
% sample_time = 0:1/sample_rate:input(1,end);
% sample_input = interp1(input(1,:),input(2,:),sample_time);
% sample_output = interp1(output(1,:), output(2,:), sample_time);
% 
% 
% figure(1)
% plot(input(1,:),input(2,:),'r');
% hold on;
% plot(sample_time,sample_input);
% 
% figure(2)
% plot(output(1,:),output(2,:),'r');
% hold on;
% plot(sample_time,sample_output)
% 
% figure(3)
% plot(sample_time,sample_input/max(sample_input),sample_time,sample_output/max(sample_output));
% 
% beta_input = nlinfit(sample_time,sample_input,@myfun,[0.9;31;0;2.5]);
% beta_output = nlinfit(sample_time,sample_output,@myfun,[1000;31;0;2.5]);

% output_fit = myfun(beta_output,sample_time);
% figure()
% plot(sample_time, output_fit, '-r');
% hold on
% plot(sample_time, sample_output,'--');

% freq_input = beta_input(2)/(2*3.14)
% freq_output = beta_output(2)/(2*3.14)
% 
% phi_input = beta_input(3)
% phi_output = beta_output(3)
