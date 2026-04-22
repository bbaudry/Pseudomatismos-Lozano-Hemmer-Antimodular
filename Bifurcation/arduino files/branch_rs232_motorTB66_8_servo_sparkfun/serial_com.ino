int serialNode = 0;

static void handleInput (char c) {

  if ('0' <= c && c <= '9')
    serialNode = 10 * serialNode + c - '0'; //combines any number with multiple digits, i.e. multiple char
  else if (c == ',') {

  } 
  else if ('a' <= c && c <='z') {
    Serial.print("\n> ");
    Serial.print((int) serialNode);

    if(serialNode <= 0) serialNode = 0;
    Serial.println(c);
    switch (c) {
    default:
      showHelp();
      break;
    case 's': 
      //stop
    //  MotorLeft.SpeedWrite(0); 
     dir = 0;
       dirTrigger = true;
      Serial.println("motorStop");
      break;
    case 'f': 
      //foward m0
      dir = 1;
       dirTrigger = true;
      //MotorLeft.SpeedWrite(motorSpeed);  
      Serial.println("motorForward");
      break;
    case 'r': 
      dir = -1;
       dirTrigger = true;
      //MotorLeft.SpeedWrite(-motorSpeed); 
      Serial.println("motorReverse");
      break;
    case 'm':
      motorSpeed = constrain(serialNode,0,255);
      dirTrigger = true;
      Serial.println("motorSpeed");
      break;

    case 'e': 
      if(serialNode == 123) ecomode();
      break;
    case 'n': 
      if(serialNode == 123) normalmode();
      break;

    case 'x': 
      if(serialNode == 123) projectorOff();
      break;
    case 'y': 
      if(serialNode == 123) projectorOn();
      break;
    }
    serialNode  = 0;
  } 
}

void showHelp()
{
  Serial.println();
  Serial.println();
  Serial.println("send speed,type of movement");
  Serial.println("motor selection choices:");
  Serial.println("f - forward");
  Serial.println("r - reverse");    
  Serial.println("s - stop");
  Serial.println("m - pwm motor speed 0-255");
  Serial.println("e - eco mode");    
  Serial.println("n - normal mode");
  Serial.println("123x - projectorOff");
  Serial.println("123y - projectorOn");
  Serial.println("h - help menu");
  Serial.println();
}
















