#include <SPI.h>


int potPin = 2;    // select the input pin for the potentiometer
int directionValue = 0;       // variable to store the value coming from the sensor
int wheelValue = 0; // variable for the speed wheel
int dingDong = 0;

String result;

void setup() {
  Serial.begin(9600);
}

void loop() {
  directionValue = analogRead(A2);    // read the value from the pot
  wheelValue = analogRead(A0);            //read value from the wheel
  int hornX = analogRead(A3);
  int hornY = analogRead(A4);
  int hornZ = analogRead(A5);
  int dingDong = 0;

  float wheelVoltage = wheelValue * (5.0 / 1023.0);  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float directionVoltage = directionValue * (5.0 / 1023.0); 
  
  int wheelPourcent = (int) ((wheelVoltage * 100) / 5);
  int directionPourcent = (int) ((directionVoltage * 100) / 5);
  
  delay(500);
  if((hornX + 80) < analogRead(A3) || (hornX - 80) > analogRead(A3))
  dingDong = 1;
  
  if((hornY + 80) < analogRead(A4) || (hornY - 80) > analogRead(A4))
  dingDong = 1;
  
  if((hornZ + 80) < analogRead(A5) || (hornZ - 80) > analogRead(A5))
  dingDong = 1;
  
  
  result = String(dingDong) + "," + String(wheelPourcent); 
  result = result + ","+ String(directionPourcent) + "\n";  
     
  Serial.println(result);
  delay(500);
}

