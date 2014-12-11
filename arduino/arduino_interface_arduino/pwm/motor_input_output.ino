#include <Encoder.h>
#include<elapsedMillis.h>

#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"

#define output_interval 2              // sampling interval for output encoder position
#define input_interval 1000             // interval between switching voltages

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield(); 

// Select which 'port' M1, M2, M3 or M4. In this case, M1
Adafruit_DCMotor *myMotor = AFMS.getMotor(1);

float output_input_val = 0;               // voltage values
long encoder_val = 0;             // encoder values
long square_input =0;            // square wave input
long motor_voltage = 0;           // PWM motor voltage signal (0-255) 

Encoder my_enc(2, 3);            // encoder pins (these are the ardunios interrupt pins)
elapsedMillis output_timer,compensator_timer,input_timer;     // constantly counting

int analogPinPositive = 3;               // used to read postive voltage input from ardunio
int analogPinNegative = 2;               // used to read negative voltages input from ardunio

void setup()

{
  Serial.begin(115200);          // setup serial
  output_timer = 0;                    // initialize timer
  input_timer = 0;
  compensator_timer = 0;
  
  myMotor->setSpeed(150);
  myMotor->run(FORWARD);
  // turn on motor
  myMotor->run(RELEASE);
  
  Serial.println("Begin random voltage input test!");
  AFMS.begin(250);               // create with the default frequency 1.6KHz (AFMS.begin(1000) if you wanted 1KHz)
}



void loop()

{
  if (input_timer > input_interval)
    {
      input_timer = 0;
      motor_voltage = random(50,200);                     // randomly select a new motor voltage
      myMotor->setSpeed(motor_voltage);
      myMotor->run(FORWARD);
    }
  if (output_timer > output_interval) {
    compensator_timer = 0;
    square_input = analogRead(analogPinPositive)-analogRead(analogPinNegative);
    encoder_val = my_enc.read();                     // fetch encoder data
    Serial.println("in");
    Serial.println(square_input);
    Serial.println("out");                     // for serial
    Serial.println(encoder_val);                      // print encoder ata to serial
    output_timer = output_timer-output_interval;//+compensator_timer;
  }
}

