#!/usr/bin/env python

from Phidgets.PhidgetException import *
from Phidgets.Events.Events import *
from Phidgets.Devices.InterfaceKit import *

import time, sys
from threading import Thread
from threading import Lock

import matplotlib.pyplot as plt

sys.path.append("../lib")
import cflib
from cflib.crazyflie import Crazyflie

import logging
logging.basicConfig(level=logging.ERROR)


class IIRfilter:
    def __init__(self,num,den):
        self._num = num
        self._den = den
        self._x = []
        self._y = []
    def add_raw_data(self,newx):
        self._x.append(newx)
        newy = 0
        for i in range(len(self._num)):
            try:
                newy = newy + self._x[-1-i]*self._num[i]
            except:
                break
        for i in range(len(self._den)-1):
            try:
                newy = newy - self._y[-1-i]*self._den[i+1]
            except:
                break
        self._y.append(newy)
    def get_filter_data(self):
        return self._y[-1]

class MotorRampExample:
    """Example that connects to a Crazyflie and ramps the motors up/down and
    the disconnects"""
    def __init__(self, link_uri):
        """ Initialize and run the example with the specified link_uri """

        self._cf = Crazyflie()
        self.sonar = Sonar()

        self._cf.connected.add_callback(self._connected)
        self._cf.disconnected.add_callback(self._disconnected)
        self._cf.connection_failed.add_callback(self._connection_failed)
        self._cf.connection_lost.add_callback(self._connection_lost)

        self._cf.open_link(link_uri)
        self.flight_log = []
        print "Connecting to %s" % link_uri

    def _connected(self, link_uri):
        """ This callback is called form the Crazyflie API when a Crazyflie
        has been connected and the TOCs have been downloaded."""

        # Start a separate thread to do the motor test.
        # Do not hijack the calling thread!
        Thread(target=self._ramp_motors).start()

    def _connection_failed(self, link_uri, msg):
        """Callback when connection initial connection fails (i.e no Crazyflie
        at the speficied address)"""
        print "Connection to %s failed: %s" % (link_uri, msg)

    def _connection_lost(self, link_uri, msg):
        """Callback when disconnected after a connection has been made (i.e
        Crazyflie moves out of range)"""
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        """Callback when the Crazyflie is disconnected (called in all cases)"""
        print "Disconnected from %s" % link_uri

    def _ramp_motors(self):
        nominal_thrust = 36000
        kp = 80
        kd = 50
        ki = 0.5
        des_height = 30
        self.int_error = 0
        for i in range(2000):
            height = self.sonar.get_height()
            vel = self.sonar.get_vel()
            self.flight_log.append([41-height, -vel])
            time.sleep(0.01)
            self.int_error+=height-des_height
            thrust = nominal_thrust + (height-des_height)*kp + vel*kd +self.int_error*ki
            self._cf.commander.send_setpoint(0, 0, 0, thrust)
            if i % 10 == 0:
                print "current height {0} cm vel {1} cm/s integrated error {2} thrust {3}".format(height,vel,self.int_error,thrust)
        self._cf.commander.send_setpoint(0, 0, 0, 0)
        time.sleep(5)
        self.write_log()
        self._cf.close_link()

    def write_log(self):
        f = open("{0}.txt".format(time.time()),'w')
        for item in self.flight_log:
            f.write("{0} {1}\n".format(item[0],item[1]))
        f.close()
        fig1 = plt.figure(1)
        ax = fig1.add_subplot(1,1,1)
        ax.plot([item[0] for item in self.flight_log])

        fig2 = plt.figure(2)
        ax = fig2.add_subplot(1,1,1)
        ax.plot([item[1] for item in self.flight_log])
        plt.show()

class Sonar:
    def __init__(self):
        try:
            self.device = InterfaceKit()
        except RuntimeError as e:
            print("Runtime Error: %s" % e.message)

        self.height = 0
        self.vel = 0
        self.last_hit_time = 0
        self.lock = Lock()

        num = [0.0181,0.0543,0.0543,0.0181]
        den = [1,-1.76,1.1829,-0.2781]

        self.vzfilter = IIRfilter(num,den)

        try:
            self.device.setOnAttachHandler(self.AttachHandler)
            self.device.setOnDetachHandler(self.DetachHandler)
            self.device.openPhidget()
            self.device.setOnSensorChangeHandler(self.sensorChanged)
        except PhidgetException as e:
            self.LocalErrorCatcher(e)

    def AttachHandler(self,event):
        attachedDevice = event.device
        serialNumber = attachedDevice.getSerialNum()
        deviceName = attachedDevice.getDeviceName()
        attachedDevice.setRatiometric(True)
        attachedDevice.setSensorChangeTrigger(5,1)
        print("Hello to Device " + str(deviceName) + ", Serial Number: " + str(serialNumber))

    def DetachHandler(self,event):
        detachedDevice = event.device
        serialNumber = detachedDevice.getSerialNum()
        deviceName = detachedDevice.getDeviceName()
        print("Goodbye Device " + str(deviceName) + ", Serial Number: " + str(serialNumber))

    def sensorChanged(self,e):
    #    f = open('sonar.txt','a')
        with self.lock:
            current_hit = time.time()
            time_elapse = current_hit-self.last_hit_time
            if time_elapse > 0.1:
                #print ("Sensor height {0} cm vel {1} cm/s".format(self.height, self.vel))
                self.last_hit_time= current_hit
                self.vel = (e.value*1024.0/1000-self.height)/time_elapse
                self.vzfilter.add_raw_data(self.vel)
                self.vel = self.vzfilter.get_filter_data()
                self.height = e.value*1024.0/1000
            #    print ("Sensor %i: %i" % (e.index, height))
            #    f.write('Height at %.3f\n',height)
            #    f.close()
        return 0

    def LocalErrorCatcher(event):
        print("Phidget Exception: " + str(event.code) + " - " + str(event.details) + ", Exiting...")
        exit(1)

    def get_height(self):
        #with self.lock:
        return self.height

    def get_vel(self):
        #with self.lock:
        return self.vel

    def close_phidget(self):
        print("Closing...")
    #   f = open('sonar.txt','a')
    #   f.write('********************************\n')
    #   f.close()
        try:
            self.device.closePhidget()
        except PhidgetException as e:
            self.LocalErrorCatcher(e)

if __name__ == '__main__':

    # Initialize the low-level drivers (don't list the debug drivers)
    cflib.crtp.init_drivers(enable_debug_driver=False)
    # Scan for Crazyflies and use the first one found
    print "Scanning interfaces for Crazyflies..."
    available = cflib.crtp.scan_interfaces()
    print "Crazyflies found:"
    for i in available:
        print i[0]

    if len(available) > 0:
        le = MotorRampExample(available[0][0])
    else:
        print "No Crazyflies found, cannot run example"


    print("Press Enter to end anytime...")
    character = str(raw_input())
    
    le.sonar.close_phidget()
