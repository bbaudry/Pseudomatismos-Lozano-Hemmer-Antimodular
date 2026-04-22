#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxNetwork.h"

#include "ifaddrs.h"

# define tubeRes 64

class testApp : public ofxiPhoneApp {
	
public:
	
	float lengthRatio;
	int numPoints;
	bool bFill;
	
	
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	
	void readUDP();
	
	void processRx_forPosition_cmd();
	void processRx_sensorReadings();
	
	void shortSend_cmd(int tempID, int tempValue);
	
	void switchLanguage(int lang);
	void cylinderDraw(bool moving);
	void directionsDraw();
	
	void panelSwitch2();
	void panelSwitch3();
	
	string getIPAddress();
	
	
	//--init
	bool showGui, showAdmin;
	//int panelSwitch;
	int stageNum,stageTime,stageTimeMulti;
	int stageTimer;
	bool storeNewSettings;
	ofTrueTypeFont  arial, theFont, arialBold, arialLarge;
	
	string appVersion;
	int language,oldLanguage;
	string languageNames[4];
	float northDegree,oldNorthDegree;
	float defaultDegree,oldDefaultDegree;
	unsigned long defaultTimer;
	int defaulting;
	unsigned long defaultTime;
	
	bool setNorthPos, setDefaultPos;
	
	float lastNorthDiff;
	float lastDefaultDiff;
	
	unsigned long a1,a2;
	
	bool saveSettings;
	
	bool panelSwitch4isOn; //in older version this used to be panleSwitch == 4
	bool panelSwitchPosChange;// this helps to make changes when default pos changes
	
	int initTimer,initTimerOffset;
	string myIP;
	//
	//-----------Motor-Monitor physicals-------------------------------
	//
	
	
	long motorTimer;
	float motorDegree,oldMotorDegree;
	float newMotorDegree;
	float predictedMotorDegree;
	float degreesPerMs, oldDegreesPerMs;
	float motorRadian;
	int theLocX;
	float firstMotorDegree;
	
	//spinmaster command
	int module; //module# of motor board, check motor board for number
	int stepsPerRev;
	bool motorDirection;
	
	int rotateSpeed;
	
	unsigned char commandAsString[9];
	//unsigned char checksum;
	int motorValue;
	int pulseDivisor, oldPulseDivisor;
	int maxCurrent, oldMaxCurrent;
	int driverOffTime, oldDriverOffTime;
	int fastDecayTime, oldFastDecayTime;
	
	int getMotorPosition;
	int getTimer;
	float monitorPixPerMs;
	float stripX,pixStep;
	float monitorPixPos;
	float GLBandDegree;
	
	float velocity,oldVelocity;
	float accel, oldAccel, averageAccel;
	float averageGlBandSpeed, org_averageGlBandSpeed;
	float accelCollect[10];
	int speedTimer;
	float motorSpeed;
	float degreeStep;
	
	int motorStartTimer, motorStopTimer;
	float motorStartedAt;
	bool motorStopped;
	
	bool onNegativeSide;
	int circleSide;
	float newGoToAngle;
	float last_newGoToAngle;
	float catchUp;
	int ccnt;
	int randomTimer,ddir;
	float angleGlBandDiff;
	float angleMotorDiff;
	int goToDir;
	unsigned long goToDirTimer;
	
	int activeTime;
	bool secondStop;
	int secondStopTimer;
	int secondStopCnt;
	float suggPerMs;
	float errorOffsetAngle;
	
	int motorStoppCnt;
	
	unsigned long lastMotorStopTimer;
	
	
	//--GL Band
	
	int w,h;
	ofTexture myTexture[4];
	ofImage myTextureImg[4];
	ofImage myImg;
	ofImage myNegativeImg;
	
	float tubeX[tubeRes];
	float tubeZ[tubeRes];
	
	float rotationY;
	int rotationTimer;
	
	bool doRotate;
	int blendColor;
	unsigned long blendOutTime;
	int currentDir;
	float lastLoopMotorDegree;
	
	//--sensors
	int lastDir, lastlastDir;
	int lastDirI;
	
	unsigned long sensorTimer;
	int lastSensor, nextSensor, lastlastSensor;
	int lastSensorReadings[8];
	bool personPresent;
	int personTimer;
	
	int sensorBlinder;
	int sensorFOV;
	float lastSensorAngle;
	
	
	
	//-----UDP ------
	ofxUDPManager udpConnection;
	string message;
	string send_message;
	int encoder_value;
	bool rxSensorMessage[9];
	int motorTask, oldMotorTask;
	
	bool initDone;
	int initStage;
	
	//power
	bool powered;
	long powerTimer;
	
	long newSettingsTimer;
	
	
private:
	string		messageBuffer;
	unsigned char bytesReturned[9];	
	unsigned char bytesSend[10];	
	bool		continuesRead;
	bool		bWriteByte;
	bool sendORreceive;
	char toSerial;
	//	float fmod(float a,float b);
	//
	//int bufferBYTES = 11;
	//char bufferIN[NUM_BYTES];
	//int received;	};
	
	
};


