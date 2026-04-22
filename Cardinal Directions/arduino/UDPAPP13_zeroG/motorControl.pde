
void motorControl(int task, int tempValue){

  if(task == 0){
    //stop
    noTone(stepperPin);
  }
  if(task == 1){
    //move
    tone(stepperPin, frequency);
  }

  if(task == 2){
    //homing faster than regular speed
    tone(stepperPin, frequency*3);
  }
  if(task == 3){
    //set frequency = speed
      frequency = tempValue;
      tone(stepperPin, frequency);
      motorTask = 1;
  }
  if(task == 4){
    //move fast
    tone(stepperPin, frequency*3);
  }
  
  
}

