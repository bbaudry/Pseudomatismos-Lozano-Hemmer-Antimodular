
void udpReceive(){
  if(millis()-timer > 40){


    // Serial.print("buf raw = ");
    // Serial.println(message); 
    //  Serial.println();


    //taken from getSerial example
    char inputBytes[5];
    char * inputBytesPtr = &inputBytes[1];
    int ii;
    for(ii=0; ii<5; ii++){
      inputBytes[ii] = message[ii];
    }
    inputBytes[ii] =  '\0';        //   Put NULL character at the end

    char * thisChar = inputBytesPtr;     //  convert array of char to integer
    char temp_ID = inputBytes[0];

    if(temp_ID != last_temp_ID){
      int temp_value = atoi(thisChar);
      last_temp_ID = temp_ID;

      if(temp_ID == 's'){
        //stop
        motorTask = 0;
        motorValue = 0;
        Serial.println("task 0 = stop");
      }
      if(temp_ID == 'm'){
        //move
        motorTask = 1;
        motorValue = 0;
        Serial.println("task 1 = move");
      }
      if(temp_ID == 'h'){
        //home
        doHoming = true;
        motorTask = 2;
        motorValue = 0;
        Serial.println("task 2 = home");
      }
      if(temp_ID == 'f'){
        //set frequency
        motorTask = 3;
        motorValue = temp_value;
        Serial.println("task 3 = newSpeed");
      }
      if(temp_ID == 'z'){
        //set frequency
        motorTask = 4;
        motorValue = temp_value;
        Serial.println("task 4 = move fast");
      }
    }
    timer = millis();

  }
}



