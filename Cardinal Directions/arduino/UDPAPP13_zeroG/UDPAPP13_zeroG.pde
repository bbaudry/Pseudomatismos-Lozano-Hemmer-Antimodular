//http://asynclabs.com/forums/viewtopic.php?f=15&t=361&start=30

//todo:
//only reset counter when IR sensor first gets interruppted not during the hole time of interruption

#include <avr/interrupt.h>   
#include <avr/io.h> 


extern "C" {
#include "uip.h"
}
#include <WiShield.h>

// Wireless configuration parameters ----------------------------------------
unsigned char local_ip[]       = {
  10, 0, 1, 222};  // IP address of WiShield
unsigned char gateway_ip[]     = {
  10, 0, 1, 1};   // router or gateway IP address
unsigned char subnet_mask[]    = {
  255, 255, 255, 0}; // subnet mask for the local network
const prog_char ssid[] PROGMEM = {
  "cardinal"};       // max 32 bytes

unsigned char security_type = 1;   // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2

// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {
  "hemmer1234567"};   // max 64 characters
  
// WEP 128-bit keys
// sample HEX keys
prog_uchar wep_keys[] PROGMEM = {
  0x68,0x65,0x6d,0x6d,0x65,0x72,0x31,0x32,0x33,0x34,0x35,0x36,0x37	// Key 0 = hemmer1234567
};

#define WIRELESS_MODE_INFRA 1
#define WIRELESS_MODE_ADHOC 2
unsigned char wireless_mode = WIRELESS_MODE_ADHOC; //WIRELESS_MODE_ADHOC;
unsigned char ssid_len;
unsigned char security_passphrase_len;
//---------------------------------------------------------------------------

//init
boolean initDone = false;
int initStage = 0;
boolean doHoming = false;

//receive udp
char* message;
char buffer[6]; //a1234
int received;
unsigned long timer = 0;
char last_temp_ID;

//combine message
unsigned long sendTimer;
//byte command[9];
char Ccmd[9];
byte checksum;

//motor
//int dirPin = 14; //2;
int stepperPin = 3; //15; //3;
unsigned int frequency = 375; //345; //380; //2000;
int motorTask = 0;
int motorValue = 0;
unsigned long motorTimer = 0;
boolean stepPhase = false;

//encoder
int encoderPinA = 16; //A2
int encoderPinB = 17; //A3
int dir = 1;
int linesPerRevolution = 9600; //500 lines * 4 edges * gear ratio (48:10);

volatile int counterValue = 1;
//unsigned int lastcounterValue = counterValue;
//volatile boolean print_flag = false;

boolean A_set = false;
boolean B_set = false;
int encoderPosition = 0;
unsigned int wrappedCounter = 1;

//IR sensor
int IRpin = 9;
int buttonState;             // the current reading from the input pin
int last_buttonState;
int last_reading = LOW;   // the previous reading from the input pin
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 20;    // the debounce time; increase if the output flickers

//motion sensors
unsigned long sensorTimer = 0;
byte sensorByte = 0;

void setup()
{
  Serial.begin(9600);
  Serial.println("UDPAPP13_zeroG");
  WiFi.init();
  message = "";

  //motor
  pinMode(stepperPin, OUTPUT);

  //setup_encoder();
  pinMode(encoderPinA, INPUT);
  digitalWrite(encoderPinA, HIGH);       // turn on pullup resistor
  pinMode(encoderPinB, INPUT);
  digitalWrite(encoderPinB, HIGH);       // turn on pullup resistor

  PCICR |= (1 << PCIE1);
  //  PCMSK1 |= (1 << PCINT12); //pin 18 = analog 4
  //  PCMSK1 |= (1 << PCINT13);  //pin19 = analog 5
  PCMSK1 |= (1 << PCINT10); // pin 16 = analog 2
  PCMSK1 |= (1 << PCINT11); // pin 17 = analog 3

  //IPR sensor
  pinMode(IRpin, INPUT);

  setup_sensors();
  sensorTimer = millis();

}

ISR( PCINT1_vect )
{
  A_set = digitalRead(encoderPinA) == HIGH; 
  counterValue += (A_set == B_set) ? +1 : -1; 

  B_set = digitalRead(encoderPinB) == HIGH;
  counterValue += (A_set != B_set) ? +1 : -1; 
  //print_flag = true;

  counterValue = counterValue % linesPerRevolution; //keeps the counter between -9600 and 9600
}

//-------------------------------------------
void loop()
{ 


  wrappedCounter = 0;
  if(counterValue < 0 ) wrappedCounter = linesPerRevolution + counterValue;
  else wrappedCounter = counterValue;
  encoderPosition = map(wrappedCounter,0,linesPerRevolution,0,2400); //1200 = (60 frames per sec) * (20 sec per 360 degrees)


  /*
  Serial.print(wrappedCounter);
   Serial.print("   ");
   Serial.print(counterValue);
   Serial.println();
   */

  //print_flag = false;


  checkIRsensor();

  //collect and send sensor data onyl every x millis
  /*
  if(millis()-sensorTimer > 100 && ! Serial.available()){
    sensorTimer = millis();
    collectSensorValues();
  }
*/

 if(0 == uip_poll() && uip_newdata() == false) collectSensorValues();


  WiFi.run(); //send and receive info to and from iPod



  if(doHoming == true){
    if(wrappedCounter == 0){
      motorTask = 0;
      doHoming = false;
      Serial.println("homing done");
    } 
    else{
      motorTask = 2;
    }
  }
  
  if(doHoming == false){
    udpReceive(); //analyzise received info from iPod
  }

  motorControl(motorTask,motorValue);


}

extern "C"
{
  void udpapp_init(void)
  {
    uip_ipaddr_t addr;
    struct uip_udp_conn *c;

    //  uip_ipaddr(&addr, 255, 255, 255, 255);
    uip_ipaddr(&addr, 10,0,1,119); //send data to this IP address
    uip_connect(&addr, HTONS(11999)); //the port on the mac

    c = uip_udp_new(&addr, HTONS(0));
    if(c != NULL) {
      uip_udp_bind(c, HTONS(1234));
    }
  }

  static void send_data(void)
  {

    char str[16];
    //  sprintf(str, "55:1:0:%c:%i:%i",sensorByte,sensorByte,encoderPosition);
    sprintf(str, "55:1:%i:%i",sensorByte,encoderPosition);

/*
    Serial.print(str); 
    Serial.print("  "); 
    Serial.print(strlen(str)); 
    Serial.println(); 
*/
    memcpy(uip_appdata, str, strlen(str));
    uip_send(uip_appdata, strlen(str));

  }

  unsigned char parse_msg(void)
  {
    //to, from, packet size
    memcpy(message,uip_appdata,5);
    return 1;
  }

  void udpapp_appcall(void)
  {
    //send data on the poll timer timeout

    if(0 != uip_poll()) {
      send_data();
    } 
    else{

    }

    if(uip_newdata()) {
      parse_msg();
    } 
  }   

  void dummy_app_appcall(void)
  {
  }
}
