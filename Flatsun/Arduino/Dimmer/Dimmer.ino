int ledPin = 7; 
int analogPin = 0;

int lastDimmer;

void setup()
{
  pinMode(ledPin, OUTPUT);
  pinMode(analogPin, INPUT);
  
  lastDimmer = -1;
  
  Serial.begin(115200);
}

void loop()
{
  int dimmer = analogRead(analogPin);
  dimmer = dimmer >> 2;
  analogWrite(ledPin, dimmer);
  
  if (Serial.available()) {
    while (Serial.available()) {
      char value;
      size_t count = 1;      
      Serial.readBytes(&value, count);
    }  
    Serial.write(dimmer);
    lastDimmer = dimmer;
  }
  else {
    
// latch to the extremes so we don't filter out 254<->255 noise
    if (dimmer == 1) dimmer = 0;
    else if (dimmer == 254) dimmer = 255;
    
    int dif = abs(dimmer - lastDimmer);
    if (dif > 1) {
      Serial.write(dimmer);
      lastDimmer = dimmer;
    }  
  }  
  delay(50);
}
