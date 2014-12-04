#include <Encoder.h>
#include<elapsedMillis.h>

int analogPin = 3;     

int input_val = 0;           // variable to store the value read
long output_val = 0;

Encoder my_enc(2, 3);
elapsedMillis timer0,timer1;
#define interval 10

void setup()

{

  Serial.begin(115200);          //  setup serial
  timer0 = 0;
}



void loop()

{
  if (timer0 > interval) {
    timer1 = 0;
    input_val = analogRead(analogPin);    // read the input pin
    Serial.println("in");
    Serial.println(input_val);             // debug value
    output_val = my_enc.read();
    Serial.println("out");
    Serial.println(output_val);
    timer0 = timer0-interval+timer1;
  }
}
