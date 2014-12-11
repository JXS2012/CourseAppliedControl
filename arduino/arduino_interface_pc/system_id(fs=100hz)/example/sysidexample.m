u = sign(randn(200,2)); % 2 inputs
y = randn(200,1);       % 1 output
ts = 0.1;               % The sampling interval
z = iddata(y,u,ts);
plot(z(:,1,1)) % Data subset with Input 1 and Output 1.
plot(z(:,1,2)) % Data subset with Input 2 and Output 1.
u = z.u;   % or, equivalently u = get(z,'u');
y = z.y;   % or, equivalently y = get(z,'y');
zp = z(48:79);
zs = z(:,1,2);  % The ':' refers to all the data time points.
plot(z(45:54,1,2)) % samples 45 to 54 of response from second input to the first output.
set(z,'InputName',{'Voltage';'Current'},'OutputName','Speed');
z.inputn = {'Voltage';'Current'}; % Autofill is used for properties
z.outputn = 'Speed';    % Upper and lower cases are also ignored
z.InputUnit = {'Volt';'Ampere'};
z.OutputUnit = 'm/s';
z2 = iddata(rand(200,1),ones(200,1),0.1,'OutputName','New Output',...
    'InputName','New Input');
z3 = [z,z2]
plot(z3(:,1,1)) % Data subset with Input 2 and Output 1.