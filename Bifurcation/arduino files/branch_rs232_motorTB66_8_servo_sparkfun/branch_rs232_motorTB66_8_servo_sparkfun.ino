//#include <MotorControl.h>
#include <Servo.h> 
#include <SoftwareSerial.h>

//using digikey level shifter rs232 28560D-ND
//projector Hitachi CP-AW250N
//using sparkfun Motor Driver 1A Dual TB6612FNG

Servo myservo;  // create servo object to control a servo 

SoftwareSerial mySerial1(11,12); 
//rs232C needs to be cross
boolean initDone = false;
int initStage = 0;
byte hexOff[]  = {
  0xbe, 0xef, 0x03, 0x06, 0x00, 0x2a, 0xd3, 0x01, 0x00, 0x00, 0x60, 0x00, 0x00      };
byte hexOn[]  = {
  0xbe, 0xef, 0x03, 0x06, 0x00, 0xba, 0xd2, 0x01, 0x00, 0x00, 0x60, 0x01, 0x00      };
byte hexInputComputer1[]  = {
  0xbe, 0xef, 0x03, 0x06, 0x00, 0xfe, 0xd2, 0x01, 0x00, 0x00, 0x20, 0x00, 0x00      };

byte hexMirror[]  = {
  0xbe, 0xef, 0x03, 0x06, 0x00, 0xba, 0xd2, 0x01, 0x00, 0x00, 0x60, 0x01, 0x00      };
//byte hexColotTemp[]  = {  0xbe, 0xef, 0x03, 0x06, 0x00, 0xba, 0xd2, 0x01, 0x00, 0x00, 0x60, 0x01, 0x00      };
byte hexEcoMode[]  = {  
  0xbe, 0xef, 0x03, 0x06, 0x00, 0xab, 0x22, 0x01, 0x00, 0x00, 0x33, 0x01, 0x00      };
byte hexNormalMode[]  = {  
  0xbe, 0xef, 0x03, 0x06, 0x00, 0x3b, 0x23, 0x01, 0x00, 0x00, 0x33, 0x00, 0x00      };

//motor
/*
PWMA = PWM Motor 1            VM = Battery +
AIN2 = Motor 1 Dir            VCC = Arduino +5
AIN1 = Motor 1 Dir            GND = Battery -
STBY = HIGH ON, LOW OFF       A01 = Motor 1 
BIN1 = Motor 2 Dir            A02 = Motor 1
BIN2 = Motor 2 Dir            B02 = Motor 2
PWMB = PWM Motor 2            B01 = Motor 2
GND  = Battery -              GND = Battery -

*/
//http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1280519240
//MotorControl MotorLeft(3,5,6); ////pwm pin,AIN2,AIN1 

int pinEnable = 3; //STBY
int pinFWD = 4; //AIN2
int pinREV = 5; //AIN1
int pinSPEED = 6; //PWM A
int dir = 1;
boolean dirTrigger = false;
unsigned long timer = 0;
int motorSpeed = 90; //150;

void setup()  
{
  Serial.begin(9600);
  Serial.println("branch_rs232_TB66_7");
  showHelp();

  // set the data rate for the NewSoftSerial port
  mySerial1.begin(19200); //9600);




  // MotorLeft.SpeedWrite(-motorSpeed);

  pinMode(pinFWD, OUTPUT);
  pinMode(pinREV, OUTPUT);
  pinMode(pinEnable, OUTPUT);
  
  digitalWrite(pinEnable,HIGH);
  //digitalWrite(pinFWD,LOW);
  //digitalWrite(pinREV,HIGH);
  digitalWrite(pinFWD,HIGH);
  digitalWrite(pinREV,LOW);
  //analogWrite(pinSPEED, motorSpeed);
  myservo.attach(pinSPEED);
  //servo.writeMicroseconds(motorSpeed);
  myservo.write(motorSpeed);
}

void loop()
{

  if (Serial.available()){
    handleInput(Serial.read());
  }

  if(initDone == false){

    if(millis() > 2000 && initStage == 0){
      projectorOn();
      initStage++;
    }
    if(millis() > 4000 && initStage == 1){
      projectorOn();
      initStage++;
    }
    if(millis() > 5000 && initStage == 2){
      normalmode();
      initStage++;
      initDone = true;
    }
  }

  if(millis() - timer > 1000*60*120){
    timer = millis();
    dirTrigger = true;
  }



  if(dirTrigger == true){
    dirTrigger = false;
    // MotorLeft.SpeedWrite(motorSpeed * dir); 
    Serial.println("updated motor");

    if(dir == -1){
      digitalWrite(pinFWD,LOW);
      digitalWrite(pinREV,HIGH);
     // analogWrite(pinSPEED, motorSpeed);
     //servo.writeMicroseconds(motorSpeed);
myservo.write(motorSpeed);
    }

    if(dir == 1){
      digitalWrite(pinFWD,HIGH);
      digitalWrite(pinREV,LOW);
      //analogWrite(pinSPEED, motorSpeed);
      //servo.writeMicroseconds(motorSpeed);
myservo.write(motorSpeed);
    }
    if(dir == 0){
      digitalWrite(pinFWD,LOW);
      digitalWrite(pinREV,LOW);
     // analogWrite(pinSPEED, 0);
     //servo.writeMicroseconds(motorSpeed);
myservo.write(90);
    }
  }



}


void projectorOff(){
  for(int i =0 ; i<13;i++){
    mySerial1.print((char)hexOff[i]);  
  }
  Serial.print("pOff");  
}

void projectorOn(){
  for(int i =0 ; i<13;i++){
    mySerial1.print((char)hexOn[i]);  
  }
  Serial.println("pOn");  
}


void ecomode(){
  for(int i =0 ; i<13;i++){
    mySerial1.print((char)hexEcoMode[i]);  
  }
  Serial.println("eco mode");  
}

void normalmode(){
  for(int i =0 ; i<13;i++){
    mySerial1.print((char)hexNormalMode[i]);  
  }
  Serial.println("normal mode");  
}




















