//written for zdot epir sensors

int sensorNum = 8;

int buttonPin[8] = {
  19,18,4,5,6,7,14,15}; //18,19,4,5,6,7,15,14}; //4,11,10,9,8,7,6,5};   // the number of the motion sensors
//sensor number
//0   7   6   5   4   3   2   1
//A4 A5  D4  D5  D6  D7  A1  A0
//18 19   4   5   6   7  15  14

byte sensorChecksum;

unsigned long buttonTimer[8] = {
  0,0,0,0,0,0,0,0}; //5,6,7,8,9,10,11};     // the number of the pushbutton pin
boolean sensorState[8] = {
  0,0,0,0,0,0,0,0}; //5,6,7,8,9,10,11};     // the number of the pushbutton pin




void setup_sensors() {

  for(int i=0; i<sensorNum; i++){   
    // initialize the pushbutton pin as an input:
    pinMode(buttonPin[i], INPUT);     
    digitalWrite(buttonPin[i], HIGH);       // turn on pullup resistors   
  }
}


// send 2bit command to computer
void collectSensorValues(){

  //to prevent noise readings, i.e. one sensor gets tripped by the developing heat of the ipod and motor board
  //only when two or more sensors are active active information is passed on to the ipod
  //i should do this in the ipod software, but don't want to touch it at this point
  
  int activeSensorCount = 0;
  for(int i=0; i<sensorNum; i++){   
    sensorState[i] = digitalRead(buttonPin[i]);
    if(sensorState[i] == 0) activeSensorCount++;
  }

  for(int i=0; i<sensorNum; i++){  

    if(sensorState[i] == 1) sensorByte |=  (1 << i);// set 1
    if(activeSensorCount >= 1){
      if(sensorState[i] == 0) sensorByte &= ~(1 << i);//set 0 == active sensor
    }
  }

}














