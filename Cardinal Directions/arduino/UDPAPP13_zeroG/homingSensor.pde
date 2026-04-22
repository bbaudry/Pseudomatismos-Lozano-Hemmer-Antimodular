void checkIRsensor(){
  //IR sensor
  int reading = digitalRead(IRpin);
  if (reading != last_reading) {
    // reset the debouncing timer
    lastDebounceTime = millis();
  } 

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer
    // than the debounce delay, so take it as the actual current state:
    last_buttonState = buttonState;
    buttonState = reading;
  }

  //needs work
  //when it goes from off to on set counter to zero after that continoue counting
  if(buttonState == 1 && last_buttonState == 0){
    //sensor covered
    counterValue = 0;
    wrappedCounter = 0;
    // task = 1;
  }
  else{
    //sensor open
    // motorTask = 0;
  } 

  last_reading = reading;
}
