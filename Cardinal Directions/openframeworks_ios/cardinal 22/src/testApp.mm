//uses ipod touch with iOS 4.1
//copy for guy bärtschi uses jailbroken ipod touch so activator turns app on when power goes on
//guy bärtschi copy uses model MC540C iOS4.1, SN C3RDD861DCP7
//AUTO LOCK 3 MINUTES
//bluetooth off, location service off
//video no widescreen, NTSC

//ipod's ip = 10.0.1.119, 255.255.255.0, 10.0.1.1, WEP passw: hemmer1234567

//use arduino sketch UDPAPP9adhoc
#include "testApp.h"
#include "MyGuiView.h"
#include "MSAShape3D.h"

MSA::Shape3D	myShape;

MyGuiView * myGuiViewController;

int tempSpeed;
//--------------------------------------------------------------
void testApp::setup(){	
	
	// register touch events
	ofRegisterTouchEvents(this);
	
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	glEnable(GL_DEPTH_TEST);
	
	ofDisableArbTex();
	
	initDone =  false; //true; // 
	storeNewSettings =   false; // true; //
	
	showGui = false;
	showAdmin = false;
	
	ofSetVerticalSync(true);
	ofSetFrameRate(30);
	//ofEnableSmoothing(); //currently only works for lines
	
	//load our type
	arial.loadFont("Arial.ttf",12);
	arialBold.loadFont("Arial Bold.ttf",8);
	arialLarge.loadFont("Arial Bold.ttf",30);
	
	//---init
	initStage = 0;
	stageNum = 0;
	stageTime = 3;
	stageTimer = ofGetElapsedTimef();
	stageTimeMulti = 3;
	
	
	
	//NOTE WE WON'T RECEIVE TOUCH EVENTS INSIDE OUR APP WHEN THERE IS A VIEW ON TOP OF THE OF VIEW
	w = 1024; //1024; //4096;//1024; //512; // 
	h = 256; //64; //256;//64; //256; //
	
	
	// preallocate space for 5000 vertices.
	myShape.reserve(500);
	
	
	appVersion = "cardinal directions v 5.1";
	
	saveSettings = false;
	//
	//-----------------gui--------------------
	//
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; //need for save and load values via cocoa
	
	
	language = [defaults floatForKey:@"language"];
	if (language <= 0 || language > 5) language = 1;
	oldLanguage = language;
	
	northDegree = [defaults floatForKey:@"northDegree"]; //0; //10; //8;
	if(northDegree < 0 || northDegree > 360) northDegree = 0;
	oldNorthDegree = northDegree;
	
	defaultDegree = [defaults floatForKey:@"defaultDegree"]; //0; //10; //8;
	if(defaultDegree < 0 || defaultDegree > 360) defaultDegree = 0;
	oldDefaultDegree = defaultDegree;
	
	languageNames[0] = "english";
	languageNames[1] = "espanol";
	languageNames[2] = "francais";
	languageNames[3] = "deutsch";
	switchLanguage(language);
	
	velocity = 100; //[defaults floatForKey:@"velocity"];
	oldVelocity = velocity;
	activeTime = 10; 
	module = 1; 
	
	
	setNorthPos = false;
	lastNorthDiff = 1000;
	setDefaultPos = false;
	lastDefaultDiff = 1000;
	
	//
	//-----------------UDP connection--------------------
	//
	//create the socket and bind to port 11999
	udpConnection.Create();
	udpConnection.Bind(1234);
	udpConnection.Connect("10.0.1.222",1234); //11999); // for sending
	
	udpConnection.SetNonBlocking(true);
	
	motorTask = 0;
	oldMotorTask = -1;
	
	myIP = ""; //ipod's ip is set manually in networks settings to 10.0.1.119 we compare to see if we are connected, too hard to get hotspot name
	//------------power
	powered = 1;
	//enable battery monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	
	//prevent device from sleeping
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	
	//
	//-----------Motor-Monitor physicals-------------------------------
	//
	
	stepsPerRev = 2400; // * 2; //had to comment the *2 out because when setting the north and default pos motor positioned itself always twice too far
	//myMotorControls = new motorControls(1);
	
	//rotation
	motorDegree = 0;
	motorStopped = false;
	
	for(int i=0; i<10;i++){
		accelCollect[i] = 0.0166; //for 100 as velocity
	}
	
	
	org_averageGlBandSpeed = 0.0166 * 1;
	averageGlBandSpeed = 0; //0.0166 * 1; //.5;
	angleGlBandDiff = 0;
	goToDir = -1;
	catchUp = 1;
	secondStop = true;
	firstMotorDegree = -1;
	lastMotorStopTimer = ofGetElapsedTimeMillis();
	
	//
	//-----------Sensors-------------------------------
	//
	
	personPresent = false;
	personTimer = 0;
	lastSensor = 0; 
	lastlastSensor = 0;
	nextSensor = 0;
	for(int i=0; i<8; i++){
		lastSensorReadings[i] = 1;
	}
	sensorBlinder = 100; //45 + 45/2; //45; //maybe should probably a multipler of 45 i.e. 360/8 
	sensorFOV = 0; // 0 = look both ways, 1 = look , 2 = look 
	
	//
	//-----------GL Band-------------------------------
	//
	//power of 2 - 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192
	// enable depth testing
	
	// select normal blend mode
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	ofDisableArbTex();
	blendColor = 255;
	
	w = 1024; //1024; //4096;//1024; //512; // 
	h = 256; //64; //256;//64; //256; //
	
	GLBandDegree = 0;
	//--Band--
	switchLanguage(language);
	
	//make pos for cyclinder sections
	float angle_gl = 360.0 / tubeRes;
	for (int i = 0; i < tubeRes; i++) {
		tubeX[i] = cos(ofDegToRad(i * angle_gl));
		tubeZ[i] = sin(ofDegToRad(i * angle_gl));;
	}
	
	blendOutTime = 10;
	
	
	motorStartTimer = ofGetElapsedTimeMillis();
	
	//default movement
	defaultTime = 11; //secs
	defaultTimer = ofGetElapsedTimef();
	defaulting = 3; 
	a1 = a2 = ofGetElapsedTimeMillis();
	
	//Our Gui setup
	
	myGuiViewController	= [[MyGuiView alloc] initWithNibName:@"MyGuiView" bundle:nil];
	[ofxiPhoneGetUIWindow() addSubview:myGuiViewController.view];
	
	myShape.enableTexCoord(true);
	//panelSwitch4isOn = false;
	
	tempSpeed = 200;
	
	initTimerOffset = 0;
}

void testApp::exit() {
	shortSend_cmd(0,0);
	
	std::exit(1);
}


//--------------------------------------------------------------
void testApp::update(){
	
	//--------------initDone
	if(initDone == false){
		
		initTimer = ofGetElapsedTimef() - initTimerOffset;
		
		if(ofGetElapsedTimef() > stageTime && initStage == 0){
			cout<<"regular init START"<<endl;
			
			stageTime = stageTime + 2;
			
			string s1 = getIPAddress();
			
			if(s1.compare("10.0.1.119") == 0){
				shortSend_cmd(0,0); //stop
				initStage++;
				myIP = "10.0.1.119";
			}else{
				cout<<"no network with correct IP found"<<endl;
				initTimerOffset = initTimerOffset + 2;
			}
		}
		
		if(ofGetElapsedTimef() > stageTime && initStage == 1){
			stageTime = stageTime + 10;
			shortSend_cmd(2,0); //home
			initStage++;
		}
		if(ofGetElapsedTimef() > stageTime && initStage == 2){
			initStage++;
			initDone = true;
			GLBandDegree = 0;
			motorDegree = 0;
			blendColor = 0;
			motorStopped = true;
			motorStopTimer = ofGetElapsedTimeMillis();
			doRotate = false;
			cout<<"regular init DONE"<<endl;
		}
		
	}else{
		
		if(oldLanguage != language){
			oldLanguage = language;
			switchLanguage(language);
		}
		
		//-------------------------motor + glband position stuff-------------------------
		if( firstMotorDegree == -1 && motorDegree != 0){
			firstMotorDegree = 0;
			GLBandDegree = motorDegree;
		}
		
		if(showGui == false || showAdmin == true){
			angleMotorDiff = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(newGoToAngle*PI/180)-sin(motorDegree*PI/180)*cos(newGoToAngle*PI/180)),
											(sin(motorDegree*PI/180)*sin(newGoToAngle*PI/180)+cos(motorDegree*PI/180)*cos(newGoToAngle*PI/180)));
			
			
			if(ofGetElapsedTimef() - personTimer > activeTime && personPresent == true){ // && doRotate == false){
				//stops the continues rotation after x sec and allows this to only happen ones
				
				cout<<"-----------------------------person timer OUT"<<endl;
				
				personPresent = false;
				
				shortSend_cmd(0,0); //stop
				
				
				//averageGlBandSpeed = 0;
				motorStopTimer = ofGetElapsedTimeMillis();
				//blendColor = 255; //set color to 255 just in case, so that now it can get faded out properly from 255 to 0
		
				secondStop = false;
				secondStopTimer =  ofGetElapsedTimeMillis();
				
				defaultTimer = ofGetElapsedTimef();
			}
			
			
			//if(defaulting == false){
			if(personPresent == true && doRotate == false && motorStopped == false){
				//if motor not yet passed its activetime limit,if allowed to rotate, if motor has not stopped yet
				averageGlBandSpeed = org_averageGlBandSpeed; // * goToDir * -1;	
				motorStartTimer = ofGetElapsedTimeMillis();
			}
			
			if(personPresent == false && doRotate == false && motorStopped == false && ofGetElapsedTimeMillis() - secondStopTimer > 200 && defaulting == 0){ //oldMotorDegree != newMotorDegree ){
				//cout<<"oldMotorDegree "<<oldMotorDegree<<", motorDegree "<<motorDegree<<endl;
				//if passed activeTime limit, if allowed to rotate, if motor not yet stopped, if secondStopTimer passed
				secondStopTimer = ofGetElapsedTimeMillis();
				motorStopTimer = ofGetElapsedTimeMillis();
				cout<<ofGetElapsedTimeMillis()<<" stop "<<endl;
				shortSend_cmd(0,0); //stop
			}
			
			if(personPresent == false && doRotate == false && motorStopped == true && averageGlBandSpeed != 0){
				averageGlBandSpeed = 0;
				blendColor = 255; //set color to 255 just in case, so that now it can get faded out properly from 255 to 0
				motorStopTimer = ofGetElapsedTimeMillis();
				cout<<"motor finaly stopped"<<endl;
			}
			
			if(personPresent == false && (ofGetElapsedTimeMillis() - motorStopTimer) > 10000 && defaulting == 0){
				//if no person is present, motor has stopped for than 10 sec, then start going home
				defaulting = 1;
				cout<<"default make it move, so it goes to default pos"<<endl;
				if(motorStopped == true) shortSend_cmd(1,0);
				
			}
			
			if(defaulting == 1){
				if(motorStopped == true){
					cout<<"default make it move more to default"<<defaultDegree<<" from "<<motorDegree<<endl;
					shortSend_cmd(1,0);
				}else{
					averageGlBandSpeed = org_averageGlBandSpeed;	
				}
				
				float tempDiff = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(defaultDegree*PI/180)-sin(motorDegree*PI/180)*cos(defaultDegree*PI/180)),
												(sin(motorDegree*PI/180)*sin(defaultDegree*PI/180)+cos(motorDegree*PI/180)*cos(defaultDegree*PI/180)));
				
				//cout<<"default tempDiff "<<tempDiff<<endl;
				
				if(motorStopped == false && ABS(tempDiff) < 2.5){
					cout<<"default stopping"<<endl;
					defaulting = 3;
					shortSend_cmd(0,0); //stop
				}
				
			}
			
			
			if(blendColor <= 0) GLBandDegree = motorDegree; // * -1;
			
			
			if(doRotate == true){
				defaultTime = 100000000;
				//secondStop = true;
				doRotate = false;
				//motorStopped = false;
				motorStartedAt = oldMotorDegree;
				cout<<"doRotate == true"<<endl;
				if(motorStopped == true) shortSend_cmd(1,0); //rotate left
				
				defaulting = 0;
			}
			
			
			
		}else {//end if(showGui == 0 || showAdmin == true)
			
			
			if(setNorthPos == true){
				
				
				float tempDiff = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(northDegree*PI/180)-sin(motorDegree*PI/180)*cos(northDegree*PI/180)),
												(sin(motorDegree*PI/180)*sin(northDegree*PI/180)+cos(motorDegree*PI/180)*cos(northDegree*PI/180)));
				tempDiff = ABS(tempDiff);
				
				cout<<"motorDegree "<<motorDegree<<", northDegree "<<northDegree<<" diff "<<tempDiff<<" lastDiff"<<lastNorthDiff<<endl;
				if(tempDiff < 2 || ( tempDiff< 12 && lastNorthDiff < tempDiff)){
					shortSend_cmd(0, 0);	
					setNorthPos = false;
					lastNorthDiff = 1000;
				}else{
					lastNorthDiff = tempDiff;
				}
				
				
			}
			if(setDefaultPos == true){
				
				
				float tempDiff = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(defaultDegree*PI/180)-sin(motorDegree*PI/180)*cos(defaultDegree*PI/180)),
												(sin(motorDegree*PI/180)*sin(defaultDegree*PI/180)+cos(motorDegree*PI/180)*cos(defaultDegree*PI/180)));
				tempDiff = ABS(tempDiff);
				
				cout<<"motorDegree "<<motorDegree<<", defaultDegree "<<defaultDegree<<" diff "<<tempDiff<<" lastDiff"<<lastDefaultDiff<<endl;
				if(tempDiff < 2 || ( tempDiff< 12 && lastDefaultDiff < tempDiff)){
					shortSend_cmd(0, 0);	
					setDefaultPos = false;
					lastDefaultDiff = 1000;
				}else{
					lastDefaultDiff = tempDiff;
				}
				
				
			}
			
		}//if showGui == true
		
		
		readUDP();	
		
	}//end initdone
	
	//battery
	powered = 1;
	if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
		powered = 0;
		
		if(ofGetElapsedTimef() - powerTimer >= 60){ //time in sec after which app exits on power loss
			[UIApplication sharedApplication].idleTimerDisabled = NO;
			exit();
		}
	} else{
		powerTimer = ofGetElapsedTimef();
	}
	
	if(saveSettings == true){
		saveSettings= false;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; //need for save and load values via cocoa
		[defaults setFloat:language forKey:@"language"]; // for floats
		[defaults setFloat:northDegree forKey:@"northDegree"]; //for floats
		[defaults setFloat:defaultDegree forKey:@"defaultDegree"]; //for floats
		
	}
}

//--------------------------------------------------------------
void testApp::draw(){
	
	char drawStr[255];
	//	ofBackground(150, 150, 150);
	ofBackground(0, 0, 0);
	
	if(initDone == true && (showGui == false || showAdmin == true) ){
		//cout<<"initDone == true && (panelSwitch == 0 || panelSwitch == 4)"<<endl;
		
		//	ofBackground(0, 0, 0);
		
		//measure the the offset between motor and glband and adjust glbands speed depending on size of offset
		float tcc = GLBandDegree;
		errorOffsetAngle = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(tcc*PI/180)-sin(motorDegree*PI/180)*cos(tcc*PI/180)),
										  (sin(motorDegree*PI/180)*sin(tcc*PI/180)+cos(motorDegree*PI/180)*cos(tcc*PI/180)));
		//		float errorOffsetAngleDir = ABS(errorOffsetAngle)/errorOffsetAngle;
		
		//if(ABS(errorOffsetAngle) > 7 && personPresent == true) {
		if(errorOffsetAngle > 0) {
			//catchUp = org_averageGlBandSpeed / ofMap(ABS(errorOffsetAngle),0,360, 10, 1) *errorOffsetAngleDir;
			catchUp = ofMap(errorOffsetAngle,0,360, 1, 5);
			//if glBand lags behind dir is 1 and diff is positive, so it moves it closer to motor in ccw direction
			//if glBand is ahead of motor dir is -1 and diff is negative, so it moves it closer to motor in cw direction
		}else{
			//catchUp = 0; //*errorOffsetAngleDir;
			catchUp = 1;
			//catchUp = ofMap(errorOffsetAngle,0,360, 0, 1);
		}
		
		
		float timeDif = ofGetElapsedTimeMillis() - rotationTimer;
		//
		//		if(motorStopped == true) GLBandDegree = motorDegree;
		//		else 
		GLBandDegree = GLBandDegree - (averageGlBandSpeed*catchUp)*timeDif;
		//GLBandDegree = GLBandDegree - (averageGlBandSpeed)*timeDif;
		//GLBandDegree = motorDegree;
		GLBandDegree = fmod(GLBandDegree,360); //float modulo
		rotationTimer = ofGetElapsedTimeMillis();
	} //end if initDone == true
	
	
	
	if(initDone == true){
		cylinderDraw(true);
		directionsDraw();
	}else{
		ofSetColor(150, 150, 150);
		
	//	ofDrawBitmapString(appVersion, ofGetWidth()/2 - stringWidth(appVersion)/2, 30);
		arial.drawString(appVersion, ofGetWidth()/2 - arial.stringWidth(appVersion)/2, 60);
		
		sprintf(drawStr, "startup routine");
		float sww = arialLarge.stringWidth(drawStr);
		arialLarge.drawString(drawStr, ofGetWidth()/2-sww/2, 150);
		
		sprintf(drawStr, "%i", 15 - int(initTimer)); //int(stageTime));
		sww = arialLarge.stringWidth(drawStr);
		arialLarge.drawString(drawStr, ofGetWidth()/2-sww/2, 200);
		
		if(myIP == ""){
			sprintf(drawStr, "waiting for network");
			sww = arial.stringWidth(drawStr);
			arial.drawString(drawStr, ofGetWidth()/2-sww/2, 250);
		}
	}
	//	}
	
	//
	//-------------special admin settings-------------
	//
	if(showAdmin == true){
		//	ofBackground(0, 0, 0);
		directionsDraw();
		
		glDisable(GL_DEPTH_TEST);
		
		
		ofSetColor(155, 155, 155);
		sprintf(drawStr, "power plugged =  %i", powered);
		arial.drawString(drawStr, 5, 50);
		
		//	memcpy(commandAsString, myMotorControls->commandAsString, sizeof(commandAsString));
		
		sprintf(drawStr, "send = %s",send_message.c_str());
		arial.drawString(drawStr, 5, 60);
		sprintf(drawStr, "encoder pos = %i",encoder_value);
		arial.drawString(drawStr, 5, 70);
		sprintf(drawStr, "sensors = %i %i %i %i %i %i %i %i",(int)rxSensorMessage[0],(int)rxSensorMessage[1],(int)rxSensorMessage[2],(int)rxSensorMessage[3],(int)rxSensorMessage[4],(int)rxSensorMessage[5],(int)rxSensorMessage[6],(int)rxSensorMessage[7]);
		arial.drawString(drawStr, 5, 80);
		
		
		sprintf(drawStr, "personPresent %i", personPresent);
		arial.drawString(drawStr, 5, 90);
		sprintf(drawStr, "motorStopped %i", motorStopped);
		arial.drawString(drawStr, 5, 110);
		sprintf(drawStr, "defaulting %i   to defaultDegree %i", defaulting, int(defaultDegree));
		arial.drawString(drawStr, 5, 130);
		sprintf(drawStr, "north %i ", int(northDegree));
		arial.drawString(drawStr, 5, 140);
		
		
		int cx = 250;
		int cy = 100;
		int diam = 50;
		float angle_gl = 360.0  / 8;
		int rectW = 2;
		
		//circle + GLBand
		ofPushMatrix();
		ofTranslate(cx+160, cy, 0);
		ofNoFill();
		ofSetColor(255, 255, 255);
		sprintf(drawStr, "%f", GLBandDegree);
		arial.drawString(drawStr, 0, -diam/2);
		sprintf(drawStr, "%f", angleGlBandDiff);
		arial.drawString(drawStr, 0, -diam/2+12);
		ofCircle(0, 0, diam);
		
		ofRotate(GLBandDegree);
		//ofRotate(ofMap(motorDegree,0,360,360,0));
		ofSetColor(255, 255, 255);
		rectW = 2;
		ofRect(0-rectW/2, -diam-20, rectW, 40);
		ofPopMatrix();
		
		
		//circle + monitor
		ofPushMatrix();
		ofTranslate(cx, cy, 0);
		ofNoFill();
		ofSetColor(255, 255, 255);
		sprintf(drawStr, "%f", motorDegree);
		arial.drawString(drawStr, 0, -diam/2);
		sprintf(drawStr, "%f", angleMotorDiff);
		arial.drawString(drawStr, 0, -diam/2+10);
		
		ofCircle(0, 0, diam);
		
		
		//this shows the blinder field equal in both directions
		if(sensorFOV == 0){
			float tx = cos(ofDegToRad(motorDegree - 90 - sensorBlinder)); //or nextSensor ?
			float tz = sin(ofDegToRad(motorDegree - 90 - sensorBlinder));
			ofLine(0, 0, tx*diam, tz*diam);
			
			tx = cos(ofDegToRad(motorDegree - 90 + sensorBlinder)); //or nextSensor ?
			tz = sin(ofDegToRad(motorDegree - 90 + sensorBlinder));
			ofLine(0, 0, tx*diam, tz*diam);
		}
		
		//this shows the blinder field for ccw sensors triggered = rol
		if(sensorFOV == -1){
			float tx = cos(ofDegToRad(motorDegree - 90 - sensorBlinder)); //or nextSensor ?
			float tz = sin(ofDegToRad(motorDegree - 90 - sensorBlinder));
			ofLine(0, 0, tx*diam, tz*diam);
			
			tx = cos(ofDegToRad(motorDegree - 90));// + sensorBlinder)); //or nextSensor ?
			tz = sin(ofDegToRad(motorDegree - 90)); // + sensorBlinder));
			ofLine(0, 0, tx*diam, tz*diam);
		}
		
		/*
		 //this shows the blinder field for cw sensors triggered = ror
		 
		 if(sensorFOV == 1){
		 float tx = cos(ofDegToRad(motorDegree - 90)); // - sensorBlinder)); //or nextSensor ?
		 float tz = sin(ofDegToRad(motorDegree - 90)); // - sensorBlinder));
		 ofLine(0, 0, tx*diam, tz*diam);
		 
		 tx = cos(ofDegToRad(motorDegree - 90 + sensorBlinder)); //or nextSensor ?
		 tz = sin(ofDegToRad(motorDegree - 90 + sensorBlinder));
		 ofLine(0, 0, tx*diam, tz*diam);
		 }
		 */
		
		//
		ofRotate(motorDegree);
		//ofRotate(ofMap(motorDegree,0,360,360,0));
		ofSetColor(255, 255, 255);
		rectW = 2;
		ofRect(0-rectW/2, -diam-20, rectW, 40);
		ofPopMatrix();
		
		
		//sensor readings
		ofPushMatrix();
		ofTranslate(cx, cy, 0);
		for (int i = 0; i < 8; i++) {
			float tx = cos(ofDegToRad(i * angle_gl - 90));
			float tz = sin(ofDegToRad(i * angle_gl - 90));
			
			//circle base
			ofSetColor(100, 0, 0);
			ofFill();
			ofCircle(tx*diam, tz*diam, 5);
			
			if(rxSensorMessage[i] == false) ofSetColor(250, 250, 250);
			else ofSetColor(40, 40, 40);
			//circle ring when triggered
			ofNoFill();
			ofCircle(tx*diam, tz*diam, 5);
			
			ofSetColor(155, 155, 155);
			sprintf(drawStr, "%i", i);
			arial.drawString(drawStr, tx*diam, tz*diam);
			
			if(nextSensor != -1 && i == nextSensor){
				ofSetColor(255, 255, 255);
				ofFill();
				ofCircle(tx*diam, tz*diam, 5);				
				//ofLine(tx*diam - 10,tz*diam - 10,tx*diam + 10,tz*diam + 10);
				//				ofLine(tx*diam + 10,tz*diam - 10,tx*diam - 10,tz*diam + 10);
			}
		}
		ofPopMatrix();
		
		
	}//end if showGui == 0
	
	
}

void testApp::switchLanguage(int lang){
	string imgSource[4] = {"cardinalA_eng.jpg","cardinalB_eng.jpg","cardinalC_eng.jpg","cardinalD_eng.jpg"};

	if(lang == 2){
		imgSource[0] = "cardinalA_spa.jpg";
		imgSource[1] = "cardinalB_spa.jpg";
		imgSource[2] = "cardinalC_spa.jpg";
		imgSource[3] = "cardinalD_spa.jpg";
	}
	
	if(lang == 3){
		imgSource[0] = "cardinalA_fre.jpg";
		imgSource[1] = "cardinalB_fre.jpg";
		imgSource[2] = "cardinalC_fre.jpg";
		imgSource[3] = "cardinalD_fre.jpg";
	}
	if(lang == 4){
		imgSource[0] = "cardinalA_ger.jpg";
		imgSource[1] = "cardinalB_ger.jpg";
		imgSource[2] = "cardinalC_ger.jpg";
		imgSource[3] = "cardinalD_ger.jpg";
	}
	
	
	for(int i=0; i<4;i++){
		myTextureImg[i].loadImage(imgSource[i]);  
		myTextureImg[i].setImageType(OF_IMAGE_GRAYSCALE);
		myTexture[i].allocate(w,h,GL_LUMINANCE);	
		myTexture[i].loadData(myTextureImg[i].getPixels(), w,h, GL_LUMINANCE);
	}	
}

void testApp::directionsDraw(){
	
	glDisable(GL_DEPTH_TEST);
	//	string directionNames[8] = {"S","SW","W","NW","N","NE","E","SE"};
	//	string directionNames[8] = {"0","1 ","2","3 ","4","5 ","6","7 "};
	
	string directionNames[8] = {"N","NE","E","SE","S","SW","W","NW"}; //default 1 = english
	float directionAngle[8]  = {0,  45, 90, 135,180, 225,270, 315};
	if(language == 2){ //spanish
		directionNames[0] ="N";
		directionNames[1] ="NE";
		directionNames[2] ="E";
		directionNames[3] ="SE";
		directionNames[4] ="S";
		directionNames[5] ="SO";
		directionNames[6] ="O";
		directionNames[7] ="NO";
	}
	if(language == 3){ //french
		directionNames[0] ="N";
		directionNames[1] ="NE";
		directionNames[2] ="E";
		directionNames[3] ="SE";
		directionNames[4] ="S";
		directionNames[5] ="SO";
		directionNames[6] ="O";
		directionNames[7] ="NO";
	}
	if(language == 4){ //german
		directionNames[0] ="N";
		directionNames[1] ="NO";
		directionNames[2] ="O";
		directionNames[3] ="SO";
		directionNames[4] ="S";
		directionNames[5] ="SW";
		directionNames[6] ="W";
		directionNames[7] ="NW";
	}
	
	int directionNamesPos[8] = {4,5,6,7,0,1,2,3};
	int directionsColor = 20;
	
	
	for(int i=0; i<8;i++){
		
		//for blend down, just like glband
		if(blendColor <= 0 ){
			directionsColor=directionsColor-20;
			if(directionsColor < 0) directionsColor = 0;
			
		}else{
			//highlight the sensors that are triggered
			if((int)rxSensorMessage[i] == 0){
				directionsColor = 150;
			}else{
				directionsColor = 100;
			}
			
			//if monitor faces one of the 8 sensors
			//	float directionAngle = 360.0 / 8.0 * i;
			float closeToDirection = (180/PI)*atan2((cos((motorDegree-northDegree)*PI/180)*sin(directionAngle[i]*PI/180)-sin((motorDegree-northDegree)*PI/180)*cos(directionAngle[i]*PI/180)),
													(sin((motorDegree-northDegree)*PI/180)*sin(directionAngle[i]*PI/180)+cos((motorDegree-northDegree)*PI/180)*cos(directionAngle[i]*PI/180)));
			
			
			if(ABS(closeToDirection) < 22.5) directionsColor = 255;
			
			
		}
		
		ofSetColor(directionsColor, directionsColor, directionsColor);
	//	arialBold.drawString(directionNames[i],80 + directionNamesPos[i]*40,20);
		arialBold.drawString(directionNames[i], int(ofGetWidth()/2 + (directionNamesPos[i]-4)*40) + 20,50);	
	}
}


void testApp::cylinderDraw(bool moving){
	
	glEnable(GL_DEPTH_TEST);
	
	//if(personPresent == false && blendColor > 0 && ((ofGetElapsedTimef() - motorStopTimer) > blendOutTime)) blendColor=blendColor-20; //if motored just stopped
	if(defaulting == 3) blendColor=blendColor-20; //if motored just stopped
	
	//if(personPresent == true && blendColor < 255) blendColor = 255; //if motor started a few ms ago
	//if(personPresent == true && blendColor < 255 && ((ofGetElapsedTimeMillis() - motorStartTimer) > 500)) blendColor=blendColor+10; //if motor started a few ms ago
	//if(personPresent == true && blendColor < 255 && ((ofGetElapsedTimeMillis() - motorStartTimer) > 500)) blendColor=255; //if motor started a few ms ago
	if(motorStopped == false && personPresent == true && blendColor < 255 && ((ofGetElapsedTimeMillis() - motorStartTimer) > 500)) blendColor=255; //if motor started a few ms ago
	
	if(blendColor < 0) blendColor = 0;
	if(blendColor > 255) blendColor = 255;
	
	ofSetColor(blendColor,blendColor,blendColor);
	
	int cWidth = 569;
	int cHeight = 200 * -1; // is actually * 2 but goes from -cHeight to +cHeight
	cHeight = cHeight/2;
	int cDepth = 569;
	float x = 0;
	float z =0;
	float u = 0;
	int startTube = 0;
	
	
	//ofSetColor(0xFFFFFF); //this is just for debug reasons white
	
	glPushMatrix();
	
	//
	//int mX = 120 ; //mouseX; 
	//	int mY = 240; //mouseY;
	//int mX = -360 + ofMap(mouseX, 0, 320, -160, 160) ; //mouseX; 
	int mX = -410; //-490; //size / diameter
	//cout<<"mx "<<mX<<endl;
	
	int mY = ofGetHeight()/2; //
	glTranslatef(ofGetWidth() / 2, ofGetHeight() / 2 + 15, mX); //pos on screen //+40-20
	glRotatef(ofMap(mY, 0, ofGetHeight(), 0,359.0f)*1.0f,1.0f,0.0f,0.0f);	// X;
	
	//if(moving == true) glRotatef((-GLBandDegree-defaultDegree+95)*1.0f,0.0f,1.0f,0.0f);	// Rota en el eje Y
//	else glRotatef((105)*1.0f,0.0f,1.0f,0.0f);	//90 had . right in middle of screen
	
	if(moving == true) glRotatef((-GLBandDegree+defaultDegree+95)*1.0f,0.0f,1.0f,0.0f);	// Rota en el eje Y
	else glRotatef((105)*1.0f,0.0f,1.0f,0.0f);	//90 had . right in middle of screen

	
	for(int s=0; s<4;s++){
		myShape.begin(GL_TRIANGLE_STRIP); //GL_QUAD_STRIP
		myTexture[s].bind();
		
		startTube = tubeRes/4 * s;
		float ww = w / (tubeRes/4);
		for (int i = startTube; i <= tubeRes/4*(s+1); i++) {
			if(i<tubeRes){
				x = tubeX[i] * cWidth;
				z = tubeZ[i] * cDepth;
				u = ww *  (i-startTube); //segmentWidth * (i-startTube); //
			} else {
				x = tubeX[0] * cWidth;
				z = tubeZ[0] * cDepth;
				u = w;
			}
			float uu = ofMap(u, 0, w, 0, 1);
			myShape.setTexCoord(uu, 0);  
			myShape.addVertex(x, -cHeight,  z);	// Bottom Left Of The Texture and Quad
			myShape.setTexCoord(uu, 1);
			myShape.addVertex(x, cHeight,  z);	// Bottom Right Of The Texture and Quad
		}
		myShape.end();
		myTexture[s].unbind();
	}
	glPopMatrix();
	
	
}

void testApp::readUDP(){
	
	char udpMessage[100000];
	udpConnection.Receive(udpMessage,100000);
	string tm = udpMessage;
	
	
	if(tm != "") {
		//cout<<"tm "<<tm<<" length "<<tm.length()<<endl;	
		
		message=udpMessage;
		//cout<<"receive message = "<<udpMessage<<endl;
		
		vector < string > parts = ofSplitString(message,":");
		
		//cout<<"receive message = "<<parts[0]<<" , "<<parts[1]<<" , "<<parts[2]<<" , "<<parts[3]<<endl;
		encoder_value = ofToInt(parts[3]);
		
		int sv = ofToInt(parts[2]);
		
		unsigned char cc = sv;
		//cout<<"cc "<<int(cc)<<endl;
		
		rxSensorMessage[0] = (cc >> 0) & 1; //sensor 0 on pin 4
		rxSensorMessage[1] = (cc >> 7) & 1; //sensor 1 on pin 5
		rxSensorMessage[2] = (cc >> 6) & 1; //sensor 2 on pin 6
		rxSensorMessage[3] = (cc >> 5) & 1; //sensor 3 on pin 7
		rxSensorMessage[4] = (cc >> 4) & 1; //sensor 4 on pin 8
		rxSensorMessage[5] = (cc >> 3) & 1; //sensor 5 on pin 9
		rxSensorMessage[6] = (cc >> 2) & 1; //sensor 6 on pin 10
		rxSensorMessage[7] = (cc >> 1) & 1; //sensor 7 on pin 11
		
		
		//cout<<"#0 "<<int(rxSensorMessage[0])<<"  #1 "<<int(rxSensorMessage[1])<<"  #2 "<<int(rxSensorMessage[2])<<"  #3 "<<int(rxSensorMessage[3])<<"  #4 "<<int(rxSensorMessage[4])<<"  #5 "<<int(rxSensorMessage[5])<<"  #6 "<<int(rxSensorMessage[6])<<"  #7 "<<int(rxSensorMessage[7])<<endl;
		//received encoder position + sensor value
		
		if( parts[0] == "55"){
			
			processRx_sensorReadings();
			processRx_forPosition_cmd();
			//	cout<<"received encoder position + sensor value"<<endl;
			
		}
		
		
	}
	
	
	
	
}

string testApp::getIPAddress()
{ 
	//http://www.iphonedevsdk.com/forum/iphone-sdk-development/51650-programmatically-get-wifi-gateway-dns-info.html
   // NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0; // retrieve the current interfaces - returns 0 on success  
    
	string myIPaddress = "";
	string myNetworkName = "";
    success = getifaddrs(&interfaces); 
    if (success == 0) 
    { 
        // Loop through linked list of interfaces  
        temp_addr = interfaces; 
        while(temp_addr != NULL) 
        { 
            if(temp_addr->ifa_addr->sa_family == AF_INET) 
            { 
                // Check if interface is en0 which is the wifi connection on the iPhone  
				string s1 = temp_addr->ifa_name;
				if(s1.compare("en0") == 0)  
                { 
					myIPaddress = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
				//	myNetworkName = strdup(temp_addr->ifa_name);
				} 
				
            } 
			temp_addr = temp_addr->ifa_next; 
        } 
    } 
    
    // Free memory  
    freeifaddrs(interfaces);
	cout<<"myIPaddress "<<myIPaddress<<endl;
    return myIPaddress; 
}

void testApp::shortSend_cmd(int tempID, int tempValue){
	
	//	0 stop
	//	1 move
	//	2 home
	//	3 set speed
	
	//string send_message = "";
	if(tempID == 0) send_message = "s1234";	 //stop
	if(tempID == 1) send_message = "m1234";  //move
	if(tempID == 2) send_message = "h1234";	 //home	
	if(tempID == 3) send_message = "f"+ofToString(tempValue);  //new frequency = speed
	if(tempID == 4) send_message = "z"+ofToString(tempValue);  //new frequency = speed
	
	int sent = udpConnection.Send(send_message.c_str(),send_message.length());
	cout<<"\nsend_message = "<<send_message<<" "<<sent<<endl;
	
	if(tempID == 0) motorStopped = true;
	if(tempID == 1 || tempID == 2) motorStopped = false;
}


void testApp::panelSwitch2(){
	setNorthPos = true;
	shortSend_cmd(4, 2000);
	panelSwitchPosChange = true;
}

void testApp::panelSwitch3(){
	//panelswitch 3
	//b	
	
	setDefaultPos = true;
	
	if(panelSwitchPosChange == true) {
		//defaultDegree = northDegree;
		panelSwitchPosChange = false;
		cout<<"panelSwitch3 set default once"<<endl;
	}
	//int tempV = ofMap(defaultDegree, 0, 360, stepsPerRev, 0);
	//myMotorControls->cmd_setTargetSteps(tempV);	
	//cout<<"panelSwitch3 "<<defaultDegree<<" "<<tempV<<endl;
	//send_cmd();
	shortSend_cmd(4, 2000);
	GLBandDegree = defaultDegree;
	//GLBandDegree = 0;
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
	
	//motorTask++;
	//if(motorTask > 1) motorTask = 0;
	//send_cmd();
	
//	tempSpeed = tempSpeed + 10;
//	shortSend_cmd(3, tempSpeed);
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	
	//IF THE VIEW IS HIDDEN LETS BRING IT BACK!
	if( myGuiViewController.view.hidden ){
		myGuiViewController.view.hidden = NO;
		
		showGui = true;
		
		shortSend_cmd(2,0); //home
		GLBandDegree = 0;
		averageGlBandSpeed = 0;
		motorDegree = 0;
		
		/*
		northDegree = 0;
		defaultDegree = 0;
		[myGuiViewController setNorthStatusString:@" Status: North is 0 degrees"];
		[myGuiViewController setDefaultPosStatusString:@" Status: Default Position is 0 degrees"];
		*/
		
		panelSwitchPosChange = false;
	}
}


void testApp::processRx_sensorReadings(){
	//with encoder
	
	
	//if(ofGetElapsedTimeMillis() - sensorTimer > 1000){
	//sensorTimer = ofGetElapsedTimeMillis();
	
	bool atLeastOneOn = false;
	
	if(lastSensor != nextSensor) lastSensor = nextSensor;
	//lastSensor = nextSensor;
	
	float lastSensorAngle = (360.0 / 8.0) * lastSensor; //360.0 - ((360.0 / 8.0) * lastSensor);
	//float angleDistToLastSensor = 1000;
	//nextSensor = -1;
	int tempAngleToMotorDir = 0;
	//		float tempSensorAngle = 0;
	//		float temp_newGoToAngle = 0;
	
	for(int i=0; i<8; i++){
		//if sensor is ON and wasn't ON already
		if(rxSensorMessage[i] == 0 && lastSensorReadings[i] != rxSensorMessage[i] && lastSensor != i){
			//if(cmd[i+1] == 0 && lastSensor != i){	
			float tempSensorAngle =  (360.0 / 8.0) * i; //360.0 - ((360.0 / 8.0) * i);
			//	float tempAngleDistToLastSensor = (180/PI)*atan2((cos(lastSensorAngle*PI/180)*sin(tempSensorAngle*PI/180)-sin(lastSensorAngle*PI/180)*cos(tempSensorAngle*PI/180)),
			//													 (sin(lastSensorAngle*PI/180)*sin(tempSensorAngle*PI/180)+cos(lastSensorAngle*PI/180)*cos(tempSensorAngle*PI/180)));
			
			float tempAngleDistToMotor = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(tempSensorAngle*PI/180)-sin(motorDegree*PI/180)*cos(tempSensorAngle*PI/180)),
														(sin(motorDegree*PI/180)*sin(tempSensorAngle*PI/180)+cos(motorDegree*PI/180)*cos(tempSensorAngle*PI/180)));
			
			if(tempAngleDistToMotor != 0)  tempAngleToMotorDir = ABS(tempAngleDistToMotor)/tempAngleDistToMotor;
			
			//make sure to find newly triggered sensor that is closest to last sensor
			
			//	if( ABS(tempAngleDistToMotor) < angleDistToLastSensor){
			//				angleDistToLastSensor = ABS(tempAngleDistToMotor);
			//				nextSensor = i;
			//				temp_newGoToAngle = tempSensorAngle;
			//			}
			
			if(ABS(tempAngleDistToMotor) <= sensorBlinder){ //only allows sensor in a certain field of view to be used as trigger
				
				//if(tempAngleToMotorDir == -1 && ABS(tempAngleDistToMotor) <= sensorBlinder){ //only ccw sensor triggers are seen within the blinder field = rol
				//sensorFOV = -1;
				atLeastOneOn = true;
				nextSensor = i;
			}
			
			
			
		}
		
		lastSensorReadings[i] = rxSensorMessage[i];
	}//end for(int i=0; i<8; i++){
	
	if(atLeastOneOn == true){
		//	cout<<endl;
		//		cout<<"atLeastOneOn true with sensorFOV "<<sensorFOV<<endl;
		//		cout<<"lastSensor "<<lastSensor<<", nextSensor "<<nextSensor<<endl;
		//		cout<<endl;
		doRotate = true;
		personPresent = true;
		personTimer = ofGetElapsedTimef();
		//goToDir = -1; // // for ccw directions  // tempAngleToMotorDir for cw+ccw
		
	}
	
}

void testApp::processRx_forPosition_cmd(){
	//with encoder
	
	// 61440 steps = 4978.67 pixel
	
	//motorValue = encoder_value % 61440;
	//if(rx_value < 0) motorValue = 61440 + (rx_value % 61440);
	
	//motor pos in degrees
	newMotorDegree = ofMap(encoder_value, 0, stepsPerRev, 0, 360);
	//cout<<"newMotorDegree "<<newMotorDegree<<endl;
	
	//float tempDif = (180/PI)*atan2((cos(motorDegree*PI/180)*sin(newMotorDegree*PI/180)-sin(motorDegree*PI/180)*cos(newMotorDegree*PI/180)),
	//								   (sin(motorDegree*PI/180)*sin(newMotorDegree*PI/180)+cos(motorDegree*PI/180)*cos(newMotorDegree*PI/180)));
	
	if(motorDegree != newMotorDegree){
		//if(ABS(tempDif) > 0.15){
		
		oldMotorDegree = motorDegree;
		motorDegree = newMotorDegree; //ofMap(motorValue, 0, 61439, 0, 359);
		
		//motorStopped = false;
		/*
		 motorStoppCnt++;
		 if(motorStoppCnt > 1){ //needs x confermations to believe that motor is really moving
		 motorStopped = false;
		 motorStoppCnt = 1;	
		 }
		 */
	}else{
		//motorStopped = true;
		/*
		 motorStoppCnt--;
		 if(motorStoppCnt <=0 ){ //needs x convermations to believe that motor really stopped
		 motorStopped = true;	
		 motorStoppCnt = 0;
		 }
		 */
		//cout<<"motorStopped = true;	"<<endl;
	}
	
}
