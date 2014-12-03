#include <Encoder.h>

int analogPin = 3;     // potentiometer wiper (middle terminal) connected to analog pin 3

                       // outside leads to ground and +5V

int input_val = 0;           // variable to store the value read
long output_val = 0;

Encoder my_enc(2, 3);

void setup()

{

  Serial.begin(9600);          //  setup serial

}



void loop()

{

  input_val = analogRead(analogPin);    // read the input pin
  Serial.println("input val = ");
  Serial.println(input_val);             // debug value
  output_val = my_enc.read();
  Serial.println("output val = ");
  Serial.println(output_val);

}
