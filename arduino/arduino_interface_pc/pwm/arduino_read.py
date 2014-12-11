__author__ = 'jianxin'


import matplotlib.pyplot as plt
import serial
import time

ser = serial.Serial('/dev/ttyUSB0',115200)
freq = 500
input_signal = []
output_signal = []
input_time = []
output_time = []

ser.flush()
start = time.time()
while input_signal.__len__()<8*freq:
    x = ser.readline()
    flag = x.split()
    if flag != []:
        if flag[0] == 'in':
            y = int(ser.readline().split()[0])/1024.*5
            input_signal.append(y)
            input_time.append(time.time()-start)
        if flag[0] == 'out':
            y = float(ser.readline().split()[0])/48.*2*3.14*freq
            output_signal.append(int(y))
            output_time.append(time.time()-start)
print input_signal
print output_signal

output_vel = []
for i in range(len(output_signal)-1):
    output_vel.append((output_signal[i+1]-output_signal[i])/(output_time[i+1]-output_time[i]))

f = open('input.txt','w')
for item in zip(input_time,input_signal):
    f.write('time {0} voltage {1}\n'.format(item[0],item[1]))
f.close()

f = open('output.txt','w')
for item in zip(output_time[:],output_signal):
    f.write('time {0} vel {1}\n'.format(item[0],item[1]))
f.close()

fig1 = plt.figure(1)
ax = fig1.add_subplot(1,1,1)
ax.plot(input_time,input_signal)

fig2 = plt.figure(2)
ax = fig2.add_subplot(1,1,1)
ax.plot(output_time[:],output_signal)

plt.show()


