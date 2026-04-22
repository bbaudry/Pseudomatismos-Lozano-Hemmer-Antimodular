#include "ofApp.h"

//THIS VERSION
//can load dxf 3d models
//can alter the anchor point on the 3d model
//can better adjust the camera looking at the 3d model

//also draw Wireframe with alpha to make edges nicer
//might use double buffer to get smoother edges

using namespace cv;
using namespace ofxCv;


//--------------------------------------------------------------
void ofApp::setup() {
    
    version = "version 20.8.4";
    ofSetLogLevel(OF_LOG_VERBOSE);
    //ofSetFrameRate(30);
    ofSetVerticalSync(true);
    
    //----GUI
    
    bDebug = false;
    //old OF default is 96 - but this results in fonts looking larger than in other programs.
    ofTrueTypeFont::setGlobalDpi(72);
    
    arial.loadFont("Arial.ttf", 24, true, false);
    //arial.setLineHeight(18.0f);
    //	arial.setLetterSpacing(1.037);
    
    //ofShowCursor();
    ofSetFullscreen(true);
    //ofSetFullscreen(false);
    
#ifdef USE_RECORD
    cout<<"loader start"<<endl;
    loader = new ofxKinectDataReader("rk4.knct");
    loader->start();
    old_loaderFameNum = 0;
    cout<<"loader done"<<endl;
    
    kinectWidth = 640;
    kinectHeight = 480;
    
    colorMat = Mat(kinectHeight,kinectWidth,CV_8UC3);
    depthMat = Mat(kinectHeight,kinectWidth,CV_8UC1);
    depthMat = cv::Scalar(0);
#else
    // enable depth->rgb image calibration
    kinect.setRegistration(true);
    
    kinect.init();
    //kinect.init(true); // shows infrared instead of RGB video image
    //kinect.init(false, false); // disable video image (faster fps)
    kinect.open();
    
    //kinect.setDepthClipping(nearThreshold, farThreshold);
    kinect.setDepthClipping(400, 1800);
    
    cout<<"kinect.open()"<<endl;
    
    kinectWidth = kinect.width;
    kinectHeight = kinect.height;
    
    
    
#endif
    
    
    //gui.addTitle(version);
    
    //	gui.loadFromXML();
    gui.addTitle(version);
    gui.addSlider("tree tilt", angleYOffset, -180, 180);
    gui.addButton("calibrate new branch", bTakeTemplate);
    gui.addButton("restart", bRestart);
    gui.addButton("quit", bExit);
    
    
    gui.addPage("admin");
    gui.addButton("quit", bExit);
    gui.addButton("debug", bDebug);
    gui.addToggle("show gui", bShowGui);
    gui.addToggle("show video", bShowVideo);
    gui.addToggle("show tracking", bShowTracking);
    gui.addToggle("show pointCloud", bShowPointcloud);
    gui.addToggle("show model", bShowModel);
    //gui.addToggle("bChangeScreenFrame", bChangeScreenFrame);
    
    gui.addToggle("bAllowEcoMode", bAllowEcoMode);
    //gui.addToggle("bUseHistogram", bUseHistogram);
    
    gui.addToggle("allow dimming", bDimming);
    gui.addSlider("current dim", old_generalLuminance, 0, 255);
    gui.addSlider("dim offset", luminanceOffset, -255, 255); // 20
    gui.addSlider("dim Smooth", luminanceSmooth, 0, 1);
    
    gui.addToggle("mirror", flipHori);
    gui.addToggle("flip", flipVerti);
    gui.addSlider("near Threshold", nearThreshold, 400, 5000);
    gui.addSlider("far Threshold", farThreshold, 400, 5000);
    
    //we can not crop the actual opencv image since we use it's xy to get the z fro the kinect depth image, which we can't reaaly crop
    //i guess we could map xy back to uncropped xy and then check z in depth image
    gui.addSlider("minCropX", minCropX, 0, kinectWidth);
    gui.addSlider("minCropY", minCropY, 0, kinectHeight);
    gui.addSlider("maxCropX", maxCropX, 0, kinectWidth);
    gui.addSlider("maxCropY", maxCropY, 0, kinectHeight);
    
    //gui.addSlider("nearFar margin", rangeMargin, 0, 20);
    gui.addSlider("binaryBlur", binaryBlur, 0, 30); //blur mat so that condensation is more likely to give center of branch higher confidence
    gui.addSlider("binaryErode", erosion_size, 0, 30); //blur mat so that condensation is more likely to give center of branch higher confidence
    gui.addSlider("binaryDilate", dilation_size, 0, 30); //blur mat so that condensation is more likely to give center of branch higher confidence
    //gui.addSlider("conBlur", conBlur, 0, 30);
    
    //gui.addToggle("flipBranch", bFlipBranch);
    gui.addSlider("diameter", collect_diameter, 0, 100);
    gui.addToggle("use raw", bUseRaw);
    
    //	gui.addSlider("zMin", zMin,400,5000);
    //	gui.addSlider("zMax", zMax,400,5000);
    gui.addSlider("max Z jump", maxZdistJump,0,1000);
    gui.addSlider("smooth Zmotion", smoothZvalue,0,1);
    //gui.addSlider("smooth motion", smoothValue,0,1);
    gui.addSlider("smooth motionX", smoothXValue,0,1);
    gui.addSlider("smooth motionY", smoothYValue,0,1);
    gui.addToggle("bUseOutsideNewFrame", bUseOutsideNewFrame);
    gui.addSlider("min_dist",min_dist,0,5);
    gui.addTitle("3d model");
    
    gui.addButton("load camPos", bCamLoadPos);
    //	gui.addButton("load camTopPos", bCamLoadTopPos);
    gui.addButton("save camPos", bCamSavePos);
    //	gui.addButton("save camTopPos", bCamSaveTopPos);
    
    //	gui.addSlider("anchors", anchorIndex, 0, 19);
    gui.addSlider("modelScale", modelScaleOffset, 0.001, 3);
    //t	gui.addSlider("tree roll", angleXOffset, -180, 180);
    gui.addSlider("tree tilt", angleYOffset, -180, 180);
    // gui.addSlider("roll amp", rollAmplify, 0, 100);
    //  gui.addSlider("tilt amp", tiltAmplify, 0, 100);
    //gui.addSlider("angleZOffset", angleZOffset, -180, 180);
    
    
    
    
    //	gui.addTitle("condensation");
    //	gui.addToggle("bUseCondensation", bUseCondensation);
    //	gui.addToggle("condens active", condensationActive);
    //	//gui.addSlider("accumCondensPoints", accumCondensPoints, 0, 100); //10 //how many of the condesn relusts are accum to calc average
    //	gui.addSlider("cond SamplesNum", SamplesNum, 1, 1000); // 50
    //	gui.addSlider("resetProbAverage", resetProbAverage, 0, 1); //what is the cut confidence off before we need to reset the condensation
    //	gui.addSlider("resetProbAveTime", resetProbAverageTime, 0, 2000); //how long is the confidence to be below a certain confidence before we need to reset condensation
    //
    //	gui.addSlider("useCondTimer", useCondTimer, 0, 5000);
    //	gui.addSlider("notUseCondTimer", notUseCondTimer, 0, 5000);
    //	gui.addSlider("minDistToCondens", minDistToCondens, 0, 40);
    //	gui.addToggle("bDistSmall", bDistSmall);
    gui.addSlider("min diamTOtempl", diamaterToTemplateDist, 20, 300);
    //gui.addSlider("min ABlength", branchABlength, 10, 500);
    
    gui.addTitle("kalman");
    gui.addToggle("bUseKalman", bUseKalman);
    //gui.addToggle("bUseKalman2", bUseKalman2);
    //  gui.addSlider("smoothKalmanAngle", smoothKalmanAngle, 0, 1);
    //   gui.addSlider("smoothKalmanPoint", smoothKalmanPoint, 0, 1);
    //http://stackoverflow.com/questions/3745348/opencv-kalman-filter
    /*
     kalman->process_noise_cov is the 'process noise covariance matrix' and
     it is often referred in the Kalman literature as Q.
     The result will be smoother with lower values.
     q= 1e-5; 0.00001
     */
    gui.addSlider("process noise", kalmanProcess, 0,0.001); //1e-4, 1e-9); //0.0001); //good 0.00011
    
    /*
     kalman->measurement_noise_cov is the 'measurement noise covariance matrix' and
     it is often referred in the Kalman literature as R.
     The result will be smoother with higher values.
     r = 1e-1; 0.1
     */
    gui.addSlider("measurement noise", kalmanMeasurement, 0, 1); // good 0.28
    gui.addSlider("process noise2", kalmanProcess2, 0,0.001); //1e-4, 1e-9); //0.0001);
    gui.addSlider("measurement noise2", kalmanMeasurement2, 0, 1); // good 0.28
    
    
    gui.addButton("set kalman", bNewKalmanSetting);
    
    gui.addTitle("template");
    gui.addToggle("show template", bShowTemplate);
    gui.addButton("make template", bTakeTemplate);
    gui.addToggle("got template", bGotTemplate);
    //gui.addSlider("minHist", minHistTresh, 0, 0.2);
    //	gui.addSlider("maxHist", maxHist, 0, 255);
    
    gui.addPage("tree_position");
    gui.addTitle("anchor point");
    gui.addSlider("offX", offsetP.x, -4000, 4000);
    gui.addSlider("offY", offsetP.y, -4000, 4000);
    gui.addSlider("offZ", offsetP.z, -4000, 4000);
    
    gui.addTitle("cam_angle");
    gui.addSlider("iMainCamera", iMainCamera, 0, N_CAMERAS-1);
    gui.addToggle("bUseMouse", bUseMouse);
    gui.addButton("reset grabCam", bCamReset);
    
    gui.addSlider("cam_tilt", cam_tilt, -360, 360);
    gui.addSlider("cam_pan", cam_pan, -360, 360);
    gui.addSlider("cam_roll", cam_roll, -360, 360);
    
    gui.addSlider("camX", camPos.x, -4000, 4000);
    gui.addSlider("camY", camPos.y, -4000, 4000);
    gui.addSlider("camZ", camPos.z, -4000, 4000);
    
    gui.addSlider("camFarClip", camFarClip, 100, 10000);
    gui.addButton("bSetCamToAnchor", bSetCamToAnchor);
    
    gui.addSlider("modelAlpha", modelAlpha, 0, 255);
    gui.addSlider("wireAlpha", wireAlpha, 0, 255);
    //    gui.addSlider("pendulumAnchorX", pendulumAnchor.x, -640, 640);
    //    gui.addSlider("pendulumAnchorY", pendulumAnchor.y, -480, 480);
    //    gui.addSlider("pendulumAnchorZ", pendulumAnchor.z, -2000, 2000);
    gui.addSlider("xyMotionScaler", xyMotionScaler, 0, 20);
    //gui.addTitle("lineSmooth", lineSmooth);
    
    gui.addPage("frame points");
    gui.addTitle("frame");
    gui.addSlider("frame type", frameType, 0, 2);
    gui.addToggle("edit frame", bEditFrame);
    //  gui.addSlider2d("leftTop", cornerPoints[0], 0,1920, 0, 1200);
    gui.addSlider("leftTopX", cornerPoints[0].x, 0, 1920);
    gui.addSlider("leftTopY", cornerPoints[0].y, 0, 1200);
    
    //   gui.addSlider2d("rightTop", cornerPoints[1], 0,1920, 0, 1200);
    gui.addSlider("rightTopX", cornerPoints[1].x, 0, 1920);
    gui.addSlider("rightTopY", cornerPoints[1].y, 0, 1200);
    
    // gui.addSlider2d("rightBottom", cornerPoints[2], 0,1920, 0, 1200);
    gui.addSlider("rightBottomX", cornerPoints[2].x, 0, 1920);
    gui.addSlider("rightBottomY", cornerPoints[2].y, 0, 1200);
    
    //  gui.addSlider2d("leftBottom",cornerPoints[3], 0,1920, 0, 1200);
    gui.addSlider("leftBottomX", cornerPoints[3].x, 0, 1920);
    gui.addSlider("leftBottomY", cornerPoints[3].y, 0, 1200);
    
    // gui.addSlider("frameWidth",frameWidth,0,200);
    gui.addToggle("border gradient",bUseGradient);
    gui.addSlider("borderWidth",borderWidth,0,200);
    //    gui.addTitle("poly B");
    //    gui.addSlider2d("b0", myFramePoints_b[0], 0,1920, 0, 1080);
    //    gui.addSlider2d("b1", myFramePoints_b[1], 0,1920, 0, 1080);
    //    gui.addSlider2d("b2", myFramePoints_b[2], 0,1920, 0, 1080);
    //    gui.addSlider2d("b3", myFramePoints_b[3], 0,1920, 0, 1080);
    //    gui.addTitle("poly C");
    //    gui.addSlider2d("c0", myFramePoints_c[0], 0,1920, 0, 1080);
    //    gui.addSlider2d("c1", myFramePoints_c[1], 0,1920, 0, 1080);
    //    gui.addSlider2d("c2", myFramePoints_c[2], 0,1920, 0, 1080);
    //    gui.addSlider2d("c3", myFramePoints_c[3], 0,1920, 0, 1080);
    //    gui.addTitle("poly D");
    //    gui.addSlider2d("d0", myFramePoints_d[0], 0,1920, 0, 1080);
    //    gui.addSlider2d("d1", myFramePoints_d[1], 0,1920, 0, 1080);
    //    gui.addSlider2d("d2", myFramePoints_d[2], 0,1920, 0, 1080);
    //    gui.addSlider2d("d3", myFramePoints_d[3], 0,1920, 0, 1080);
    //
    gui.loadFromXML();
    //gui.setAutoSave(false);
    //gui.setDefaultKeys(true);
    //gui.show(); //
    //gui.hide();
    //showGui = true; //
    //bShowGui = true;
    //gui.bShowHeader = false;
    
    if(maxCropY == 0 || maxCropX == 0){
        //something went wrong and the gui values got set to zero
        maxCropX = kinectWidth - 20;
        maxCropY = kinectHeight - 20;
    }
    bRestart = false;
    bExit = false;
    //SamplesNum = 50;
    //probableCondensD.resize(SamplesNum);
    bEditFrame = false;
    //	diameter = 10;
    
    //	rawZdiff = 10;
    //	rawZSmooth = 0.4;
    //	accumRawPoints = 10;
    //	accumCondensPoints = 10;
    old_bUseGradient = !bUseGradient;
    //frameType = 2;
    //frameType = 1;
    bDebug = false;
    
    //serial
    serial.listDevices();
    getSerialDevice();
    myBaud = 9600; //57600; //115200;
    serialActive = serial.setup(serialID,myBaud);
    serialSendPause = 200;
    lastSendTime = ofGetElapsedTimeMillis();
    
    
    cloudMesh.setMode(OF_PRIMITIVE_POINTS);
    
    bShowPointcloud = false;
    
    
    sourceMat = Mat(kinectHeight,kinectWidth,CV_8UC3);
    binaryMat = Mat(kinectHeight,kinectWidth,CV_8UC1);
    rgbMat = Mat(kinectHeight,kinectWidth,CV_8UC3);
    //weighted_depthMat = Mat(kinectHeight,kinectWidth,CV_8UC1);
    //weighted_depthMat = Mat(kinectHeight,kinectWidth,CV_32FC1);
    grayThreshNearMat = Mat(kinectHeight,kinectWidth,CV_8UC1);
    grayThreshFarMat = Mat(kinectHeight,kinectWidth,CV_8UC1);
    grayThresh = Mat(kinectHeight,kinectWidth,CV_8UC1);
    
    
    //ofSetFrameRate(60);
    
    //contourFinder.setMinArea(10*10);
    //	contourFinder.setMaxArea(kinectWidth*kinectHeight/3);
    
    contourFinder.setMinAreaRadius(10);
    contourFinder.setMaxAreaRadius(150);
    
    //	contourFinderHistogram.setMinAreaRadius(10);
    //	contourFinderHistogram.setMaxAreaRadius(150);
    
    contourFinderConvex.setMinAreaRadius(2);
    contourFinderConvex.setMaxAreaRadius(40);
    
    contourFinderGreyThresh.setMinAreaRadius(10);
    contourFinderGreyThresh.setMaxAreaRadius(150);
    
    
    
    //contourThreshold = 0; //126; //default
    
    
    
    
    
    //tracking setup
    //frame = sourceMat; // cvCreateImage(cvSize(kinectWidth, kinectHeight), 8, 3);
    //frame = &IplImage(sourceMat);
    //	frameWithInfo = NULL;
    //	frameWithInfo = cvCreateImage(cvSize(kinectWidth, kinectHeight), 8,3);
    MatWithInfo = Mat(kinectHeight,kinectWidth,CV_8UC3);
    
    
    
    
    
    
    //	for(int i=0; i<SamplesNum; i++){
    //		probableCondensD[i] = ofPoint(0,0,0);
    //	}
    //	probableCondensD_cnt = 0;
    
    
    updateData = true;
    
    //initCondens();
    
    //3d model
    // we need GL_TEXTURE_2D for our models coords.
    ofDisableArbTex();
    
    if(model.loadModel("sassafras.stl",true)){
        //if(model.loadModel("sassafras5_15.dae",true)){
        //if(model.loadModel("sassafras.dxf",true)){
        //model.setAnimation(0);
        //model.setPosition(ofGetWidth()/2,ofGetHeight()/2, 0);
        //model.createLightsFromAiModel();
        model.disableTextures();
        model.disableMaterials();
        model.disableColors();
        
        //sceneCenter = model.getSceneCenter();
        modelMesh = model.getMesh(0);
        position = model.getPosition();
        normScale = model.getNormalizedScale();
        modelScale = model.getScale();
        
        
        //model.setRotation(0, 90, 1, 0, 0);
        //normScale 126.565, scale 1, 1, 1
        cout<<"normScale "<<normScale<<", scale "<<modelScale<<endl;
    }
    
    //	qtRotationAxisX,qtRotationAxisY,qtRotationAxisZ = 0;
    //	qtAngle = 0;
    //	qtTranslation = ofVec3f(0,0,0);
    //
    
    //---------frame----------
    //bChangeScreenFrame = true;
    
    //circle
    frameImage.loadImage("frame.png");
    
    //rect
    
    //borderWidth = 38;
    
    nPolygons = 4;
    thePolygons = new myPolygon*[nPolygons];
    
    bResetFrame = false;//true;
    if(bResetFrame){
        borderWidth = 38;
        //leftTop
        cornerPoints[0] = ofPoint(borderWidth,borderWidth);
        //rightTop
        cornerPoints[1] = ofPoint(ofGetWidth() -borderWidth,borderWidth);
        //rightBottom
        cornerPoints[2] = ofPoint(ofGetWidth()-borderWidth,ofGetHeight()-borderWidth);
        // leftBottom
        cornerPoints[3] = ofPoint(borderWidth,ofGetHeight()-borderWidth);
        
    }
    ofPoint p[4];
    thePolygons[0] = new myPolygon(p,2);
    thePolygons[1] = new myPolygon(p,3);
    thePolygons[2] = new myPolygon(p,0);
    thePolygons[3] = new myPolygon(p,1);
    
    
    updateFrame();
    
    
    //camera.bAllowGrab = false;//true; //
    
    initStartTime = 3;
    //maxAliveLabel = 0;
    
    ofResetElapsedTimeCounter();
    
    //doubleClickTimer = ofGetElapsedTimeMillis();
    //clickCnt = 0;
    
    bShowTemplate = false;
    bShowGui = false;
    bShowModel = false;
    bStartupMode = true; //true;
    bShowTracking = false; //true;
    bShowVideo = false;
    ofHideCursor();
    
    
    
    
    convexPointMat = Mat(kinectHeight,kinectWidth,CV_8UC3);
    
    //----------------kalman filter
    for (int i=0;i<16;i++) kalmanPointSmoothed[i] = NULL;
    
    
    //    kalmanProcess = 1e-5;
    //	kalmanMeasurement = 1e-1;
    
    setupKalman();
    
    
    convexLast2Labels[0] = -1;
    convexLast2Labels[1] = -1;
    convexLast2Labels[2] = -1;
    
    bool loadSuccess = loadTemplatePoints();
    bTakeTemplateABCD = false;
    bTakeTemplate = false;
    if(loadSuccess){
        templateState = 1;
        bGotTemplate = true;
        
        ofVec3f fromVec(1,0,0);
        ofVec3f toVec(templPointA-templPointD);
        
        template_mR.makeRotationMatrix(fromVec, toVec);
        template_mR = template_mR.getInverse(); //because we want to rotate the template to zero
        
    }else{
        templateState = -1;
        bGotTemplate = false;
    }
    
    diameterDistTimer= ofGetElapsedTimeMillis();
    movesSlowTimer = ofGetElapsedTimeMillis();
    //	condensDistTimer = ofGetElapsedTimeMillis();
    
    skel = Mat(binaryMat.size(), CV_8UC1);
    
    aveProbVec_cnt = 0;
    
    diamPointA = templPointA;
    diamPointB = templPointB;
    diamPointC = templPointC;
    diamPointD = templPointD;
    
    
    float angA = atan2(templPointA.x-templPointD.x, templPointA.y-templPointD.y);
    float angB = atan2(templPointB.x-templPointD.x, templPointB.y-templPointD.y);
    float angC = atan2(templPointC.x-templPointD.x, templPointC.y-templPointD.y);
    
    angA = ofRadToDeg(angA);
    angB = ofRadToDeg(angB);
    angC = ofRadToDeg(angC);
    
    angAB_offset = angA - angB;
    angAC_offset = angA - angC;
    
    lengthAD = templPointD.distance(templPointA);
    lengthBD = templPointD.distance(templPointB);
    lengthCD = templPointD.distance(templPointC);
    
    old_generalLuminance = 255;
    
    //gotHistogramTemplate  = false;
    //	takeNewHistogramTemplate = false;
    
    //---------3d camera
    iMainCamera = N_CAMERAS-1;
    camLoadPos();
    
    //fixed cam
    fixedCam.setFarClip(camFarClip);
    cameras[3] = &fixedCam;
    ofMatrix4x4 tempM = cameras[3]->getLocalTransformMatrix();
    
    
    // bUseMouse = false;
    //moveable cam
    camEasyCam.setMouseActions(bUseMouse);
    camEasyCam.setFarClip(20000);
    cameras[0] = &camEasyCam;
    cameras[0]->setTransformMatrix(tempM);
    
    // front
    camFront.scale = 2000;
    cameras[1] = &camFront;
    
    // top
    camTop.scale = 2000;
    camTop.tilt(-90);
    cameras[2] = &camTop;
    
    
    rawTilt = treeTilt = 0;
    rawRoll = treeRoll = 0;
    rawAngle = 0;
    
    initKalmanTimer = ofGetElapsedTimef() - 100;
    
    //	maxHist = 255.0;
    
    //kinectInitSuccess = false;
    
    ecoMode_inUse = false;
    initStage = 0;
    centroid = ofPoint(kinectWidth/2,kinectHeight/2);
    cout<<"done with setup() "<<endl;
    
    tiltAvgCnt = 0;
    rollAvgCnt = 0;
    
    //bDebugTimer = true;
    
    // blurStage.setup(ofGetWidth(), ofGetHeight(), 10, .2, 2, .2);
    
}



void ofApp::updateKalmanSettings(int id, ofPoint tp){
    
    
    int dimensions = 3;
    
    
    if(kalmanPointSmoothed[id*dimensions] != NULL) {
        kalmanPointSmoothed[id*dimensions]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.x);
        kalmanPointSmoothed[id*dimensions+1]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.y);
        kalmanPointSmoothed[id*dimensions+2]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.z);
        
    }
    
}

ofPoint ofApp::updateKalman(int id, ofPoint tp){
    
    
    int dimensions = 3;
    if (id>=16) return ofPoint(0,0);
    
    if(kalmanPointSmoothed[id*dimensions] == NULL) {
        kalmanPointSmoothed[id*dimensions] = new ofxCvKalman(tp.x);
        kalmanPointSmoothed[id*dimensions+1] = new ofxCvKalman(tp.y);
        kalmanPointSmoothed[id*dimensions+2] = new ofxCvKalman(tp.z);
        
        kalmanPointSmoothed[id*dimensions]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.x);
        kalmanPointSmoothed[id*dimensions+1]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.y);
        kalmanPointSmoothed[id*dimensions+2]->changeProcessAndMeasurementNoise(kalmanProcess2,kalmanMeasurement2,tp.z);
        
    } else {
        tp.set(kalmanPointSmoothed[id*dimensions]->correct(tp.x),
               kalmanPointSmoothed[id*dimensions+1]->correct(tp.y),
               kalmanPointSmoothed[id*dimensions+2]->correct(tp.z));
    }
    
    return tp;
    
}

void ofApp::clearKalman(int id) {
    
    int dimensions = 3;
    
    if (id>=16) return;
    if(kalmanPointSmoothed[id*dimensions]) {
        
        delete kalmanPointSmoothed[id*dimensions];
        kalmanPointSmoothed[id*dimensions] = NULL;
        
        delete kalmanPointSmoothed[id*dimensions+1];
        kalmanPointSmoothed[id*dimensions+1] = NULL;
        
        delete kalmanPointSmoothed[id*dimensions+2];
        kalmanPointSmoothed[id*dimensions+2] = NULL;
    }
}


void ofApp::setupKalman(){
    /*
     KF.init(2,1,0);
     
     KF.transitionMatrix = *(Mat_<float>(2, 2) << 1,1, 0,1);
     
     //???state = Mat_<float>(3, 1);
     KF.statePre.at<float>(0) = ofRandom(2.1); //curMouse.x;
     KF.statePre.at<float>(1) = ofRandom(2.1); //curMouse.y;
     //KF.statePre.at<float>(2) = 0;
     
     //???processNoise = Mat(2, 1, CV_32F);
     
     measurement = Mat_<float>::zeros(1,1);
     //measurement.setTo(Scalar(0));
     
     
     setIdentity(KF.measurementMatrix, Scalar::all(1));
     setIdentity(KF.processNoiseCov, Scalar::all(kalmanProcess));
     setIdentity(KF.measurementNoiseCov, Scalar::all(kalmanMeasurement));
     setIdentity(KF.errorCovPost, Scalar::all(1e-5));
     */
    
    
    
    KF2.init(4,2,0);
    
    KF2.transitionMatrix = *(Mat_<float>(4, 4) << 1, 0, 1, 0,
                             0, 1, 0, 1,
                             0, 0, 1, 0,
                             0, 0, 0, 1);
    
    //???state = Mat_<float>(3, 1);
    KF2.statePre.at<float>(0) = ofRandom(2.1); //curMouse.x;
    KF2.statePre.at<float>(1) = ofRandom(2.1); //curMouse.y;
    KF2.statePre.at<float>(2) = ofRandom(2.1);
    KF2.statePre.at<float>(3) = ofRandom(2.1);
    //KF.statePre.at<float>(2) = 0;
    
    //???processNoise = Mat(2, 1, CV_32F);
    
    measurement2 = Mat_<float>::zeros(2,1);
    //measurement.setTo(Scalar(0));
    
    
    setIdentity(KF2.measurementMatrix, Scalar::all(1));
    setIdentity(KF2.processNoiseCov, Scalar::all(kalmanProcess2));
    setIdentity(KF2.measurementNoiseCov, Scalar::all(kalmanMeasurement2));
    setIdentity(KF2.errorCovPost, Scalar::all(1e-5));
    
    
}


void ofApp::kmeansClustering(ofVec3f * returnPoints, int arrayDim, vector <ofVec3f> pointArray, int clusterCount){
    
    
    int sampleCount = pointArray.size();
    float pointsdata[sampleCount * arrayDim]; //[] = {1,1, 2,2, 6,6, 5,5, 10,10};
    
    //cout<<"initConvexPoints.size() "<<initConvexPoints.size()<<endl;
    int cnt = 0;
    for(int a=0; a<sampleCount; a++){
        pointsdata[cnt] = pointArray[a].x;
        cnt++;
        if(arrayDim > 1){
            pointsdata[cnt] = pointArray[a].y;
            cnt++;
        }
        if(arrayDim > 2){
            pointsdata[cnt] = pointArray[a].z;
            cnt++;
        }
    }
    
    cv::Mat points;
    points = cv::Mat(sampleCount,arrayDim, CV_32F,pointsdata);
    
    //int clusterCount = 3; //i want 3 averaged points back
    
    cv::Mat labels;
    cv::Mat centers;
    centers = cv::Mat(clusterCount, 1, points.type());
    
    // kmeans( const Mat& data, int K, CV_OUT Mat& bestLabels,TermCriteria criteria, int attempts, int flags, CV_OUT Mat* centers=0 );
    //    kmeans(points, clusterCount, labels, cv::TermCriteria(), 5,cv::KMEANS_PP_CENTERS, &centers);
    kmeans(points, clusterCount, labels, cv::TermCriteria(), 5, cv::KMEANS_PP_CENTERS,centers);
    
    if(arrayDim == 2){
        for(int i=0; i<clusterCount; i++){
            returnPoints[i] = ofPoint(centers.at<float>(0, i*2), centers.at<float>(0, i*2+1));
        }
        //returnPoints[0] = ofPoint(centers.at<float>(0, 0), centers.at<float>(0, 1));
        //		returnPoints[1] = ofPoint(centers.at<float>(0, 2), centers.at<float>(0, 3));
        //		returnPoints[2] = ofPoint(centers.at<float>(0, 4), centers.at<float>(0, 5));
    }
    if(arrayDim == 3){
        for(int i=0; i<clusterCount; i++){
            returnPoints[i] = ofPoint(centers.at<float>(0, i*3), centers.at<float>(0, i*3+1), centers.at<float>(0, i*3+2));
        }
        //returnPoints[0] = ofPoint(centers.at<float>(0, 0), centers.at<float>(0, 1), centers.at<float>(0, 2));
        //		returnPoints[1] = ofPoint(centers.at<float>(0, 3), centers.at<float>(0, 4), centers.at<float>(0, 5));
        //		returnPoints[2] = ofPoint(centers.at<float>(0, 6), centers.at<float>(0, 7), centers.at<float>(0, 8));
    }
    
}

void ofApp::update2() {
    
    ofBackground(100, 100, 100);
    
    kinect.update();
    
    // there is a new frame and we are connected
    if(kinect.isFrameNew()) {
        
        // load grayscale depth image from the kinect source
        //grayImage.setFromPixels(kinect.getDepthPixels(), kinect.width, kinect.height);
        rgbMat = Mat(kinectHeight, kinectWidth, CV_8UC3, kinect.getPixels(), 0);
        
    }
    
    
}

//--------------------------------------------------------------
void ofApp::update() {
    
    ofSetWindowTitle(ofToString(ofGetFrameRate()));
    
    if(old_bUseGradient != bUseGradient){
        old_bUseGradient = bUseGradient;
        
        for(int i=0; i<4;i++){
            thePolygons[i]->bUseGradient = bUseGradient;
        }
    }
    
    if(bEditFrame){
        updateFrame();
    }
    
    if(bDebugTimer){
        cout<<"A-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    if(bExit == true) exit(); //std::exit(1);
    if(bRestart == true ){
        //open apple script
        
        string command = "open " + ofToDataPath("restart.app");
        system(command.c_str());
        cout<<"\ncommand "<<command<<endl;
        
        
        exit(); //std::exit(1);
    }
    if(bShowTemplate == true) ofShowCursor();
    
    
    
    int sepiaR = 255;
    int sepiaG = 255;
    int sepiaB = 255;
    
    //if(bShowTracking){
    //		ofBackground(100);
    //	}
    //	else{
    //http://stackoverflow.com/questions/5132015/how-to-convert-image-to-sepia-in-java
    //int sepiaDepth = sepiaValue;
    
    
    if(bDimming){
        sepiaR = old_generalLuminance;
        sepiaG = old_generalLuminance;
        sepiaB = old_generalLuminance;
        
        if(bAllowEcoMode == true){
            if(old_generalLuminance > 160) ecoModeTimer = ofGetElapsedTimef();
            else normalModeTimer = ofGetElapsedTimef();
            
            if(ofGetElapsedTimef() - ecoModeTimer > 60*15 && ecoMode_inUse == false){ //60*15
                ecoModeTimer = ofGetElapsedTimef();
                string s = "123e";
                cout<<"enter eco mode "<<s<<endl;
                serialMessages.push_back(s);
                ecoMode_inUse = true;
            }
            
            if(ofGetElapsedTimef() - normalModeTimer > 60*1 && ecoMode_inUse == true){ //60*1
                normalModeTimer = ofGetElapsedTimef();
                string s = "123n";
                cout<<"enter normal mode "<<s<<endl;
                serialMessages.push_back(s);
                ecoMode_inUse = false;
            }
        }
        
    }
    
    if(bDebugTimer){
        cout<<"B-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    //ofBackground(sepiaR,sepiaG,sepiaB); // ofBackground(255);
    
    
    //bool newFrame;
    
    
    //cout<<"kinect.update()"<<endl;
    
    kinect.update();
    //	newFrame = kinect.isFrameNew();
    
    if(bDebugTimer){
        cout<<"C-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    // bShowVideo = true;
    // there is a new frame and we are connected
    if(kinect.isFrameNew()) {
        //	cout<<"newFrame"<<endl;
        
        
        if(bStartupMode == true){
            
            if(initStage == 0){
                
                cout<<"initStage == 0"<<endl;
                
                
                //check if kinect rgb image is black, which would mean kinect did not init correctly
                
                Mat temp_rgbMat = Mat(kinectHeight, kinectWidth, CV_8UC3, kinect.getPixels(), 0);
                cv::Scalar temp_mean = mean(temp_rgbMat);
                float temp_meanColor = ( temp_mean[0] + temp_mean[1] + temp_mean[2] ) / 3.0;
                cout<<"temp_meanColor "<<temp_meanColor<<endl;
                if(temp_meanColor == 0){
                    
                    cout<<"-------------------------------------------------- try to restart kinect due to black rgb image"<<endl;
                    /*
                     kinect.close();
                     
                     kinect.setRegistration(true);
                     
                     kinect.init();
                     //kinect.init(true); // shows infrared instead of RGB video image
                     //kinect.init(false, false); // disable video image (faster fps)
                     kinect.open();
                     
                     //kinect.setDepthClipping(nearThreshold, farThreshold);
                     kinect.setDepthClipping(400, 1800);
                     */
                    
                    cout<<"wait a bit longer befor proceeding due to black rgb image from kinect"<<endl;
                    //cout<<"done to restart kinect due to black rgb image"<<endl;
                    
                    
                }else{
                    initStage = 1;
                }
                
                
                //ofResetElapsedTimeCounter();
            }//end if initStage == 0
            
            if(initStage == 1){
                //show rgb video and count down 10 to 0
                if(ofGetElapsedTimef() > 1){ //10){ //
                    cout<<"initStage == 1 done"<<endl;
                    initStage = 2;
                    ofResetElapsedTimeCounter();
                }
            }
            
            if(initStage == 2){
                //show just white image
                if(ofGetElapsedTimef() > 1){ //5){ //
                    cout<<"initStage == 2 done "<<endl;
                    initStage = 3;
                }
            }
            if(initStage == 3){
                //show depth video and done message
                if(ofGetElapsedTimef() > 3){ //15){ //
                    cout<<"initStage == 3 done"<<endl;
                    initStage = 4;
                }
            }
            
            if(initStage == 4){
                cout<<"initStage == 4"<<endl;
                initStage = 5;
                bStartupMode = false;
                
                bShowTracking = false;
                bShowModel = true;
                bShowVideo = false;
                bShowTemplate = false;
                bShowPointcloud = false;
                
                bNewKalmanSetting = false;
                initKalmanTimer = ofGetElapsedTimef();
                bInitKalmanDone = false;
                
                ofHideCursor();
                cout<<"startup done "<<endl;
                
            }
        }
        
        /*
         if(bStartupMode == true && ofGetElapsedTimef() > 15){
         bStartupMode = false;
         bShowTracking = false;
         bShowModel = true;
         bShowVideo = false;
         bShowTemplate = false;
         bShowPointcloud = false;
         ofHideCursor();
         cout<<"startup done "<<endl;
         }
         */
        
        if(bDebugTimer){
            cout<<"D-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMicros();
        }
        //if(bDimming || bShowVideo || bStartupMode){
        Mat temp_rgbMat = Mat(kinectHeight, kinectWidth, CV_8UC3, kinect.getPixels());
        
        if(bDebugTimer){
            cout<<"DD-- "<<ofGetElapsedTimeMillis()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMillis();
        }
        
        int temp_mirror;
        if(flipHori == true && flipVerti == true) temp_mirror = -1;
        if(flipHori == true && flipVerti == false) temp_mirror = 0;
        if(flipHori == false && flipVerti == true) temp_mirror = 1;
        if(flipHori == false && flipVerti == false){
        }else{
            flip(temp_rgbMat,rgbMat,temp_mirror); //0 flip x-axis, 1 means flip y-axis, -1 flip x&y axis
        }
        
        if(bDebugTimer){
            cout<<"E-- "<<ofGetElapsedTimeMillis()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMillis();
        }
        //}
        //
        //http://www.songho.ca/dsp/luminance/luminance.html
        rgbMean = mean(rgbMat);
        //	cout<<"rgbMean[0] "<<rgbMean[0]<<" | "<<rgbMean[1]<<" | "<<rgbMean[2]<<endl;
        //			cout<<"*vrgbMean[0] "<<0.3086*rgbMean[0]<<" | "<<0.6094*rgbMean[1]<<" | "<<0.0820 *rgbMean[2]<<endl;
        
        
        
        generalLuminance = ( (1*rgbMean[0]) + (1*rgbMean[1]) + (1 *rgbMean[2]) ) / 3.0;
        //generalLuminance = ( (0.299*rgbMean[0]) + (0.587*rgbMean[1]) + (0.114 *rgbMean[2]) ) / 3.0;
        //generalLuminance = ( (0.3086*rgbMean[0]) + (0.6094*rgbMean[1]) + (0.0820 *rgbMean[2]) ) / 3.0; // / 320 * 240 * 3;
        //cout<<"generalLuminance "<<generalLuminance;
        
        //if(generalLuminance == 0){
        //
        //
        //			generalLuminance = 255;
        //			kinectInitSuccess = false;
        //		}
        //		else{
        //			kinectInitSuccess = true;
        //		}
        
        
        if(bDimming){
            generalLuminance = generalLuminance + luminanceOffset;
            //			generalLuminance = MAX(0,generalLuminance);
            //			generalLuminance = MIN(255,generalLuminance);
            generalLuminance = ofClamp(generalLuminance, 0, 255);
            old_generalLuminance += (generalLuminance-old_generalLuminance) * (1-luminanceSmooth);
        }
        else {
            generalLuminance = 255;
            old_generalLuminance = generalLuminance;
        }
        
        if(bDebugTimer){
            cout<<"F-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMicros();
        }
        
        
        //	if(kinectInitSuccess == true){
        
        if(initStage > 1){
            
            if(bDebugTimer){
                cout<<"G-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            Mat temp_sourceMat = Mat(kinectHeight, kinectWidth, CV_8UC1, kinect.getDepthPixels(), 0);
            
            
            int temp_mirror;
            if(flipHori == true && flipVerti == true) temp_mirror = -1;
            if(flipHori == true && flipVerti == false) temp_mirror = 0;
            if(flipHori == false && flipVerti == true) temp_mirror = 1;
            if(flipHori == false && flipVerti == false){
            }else{
                flip(temp_sourceMat,sourceMat,temp_mirror); //0 flip x-axis, 1 means flip y-axis, -1 flip x&y axis
            }
            
            if(bDebugTimer){
                cout<<"H-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            //depth clipping via cv threshold
            grayThresh = Scalar(0); //,0,0);
            
            
            if(ofGetElapsedTimeMillis() < 2000){
                cout<<"measure min/max depth values of the blob closest to the middles"<<endl;
                
                double minColor, maxColor;
                cv::Point minIn, maxIn;
                
                cv::Mat temp_binaryThreshMat;
                ofxCv::threshold(sourceMat,temp_binaryThreshMat,0);
                
                contourFinderGreyThresh.setThreshold(0);
                contourFinderGreyThresh.findContours(temp_binaryThreshMat);
                
                //int temp_label = 0;
                int temp_id = -1;
                float temp_smallesdtDist = 10000;
                for(int curB=0; curB<contourFinderGreyThresh.size(); curB++){
                    
                    ofPoint temp_centroid = toOf(contourFinderGreyThresh.getCentroid(curB));
                    int temp_x = toOf(contourFinderGreyThresh.getBoundingRect(curB)).x;
                    int temp_y = toOf(contourFinderGreyThresh.getBoundingRect(curB)).y;
                    int temp_xW = temp_x + toOf(contourFinderGreyThresh.getBoundingRect(curB)).width;
                    int temp_yH = temp_y + toOf(contourFinderGreyThresh.getBoundingRect(curB)).height;
                    
                    float temp_dist = temp_centroid.distance(ofPoint(kinectWidth/2,kinectHeight/2,0)); //ofPoint(kinectWidth/2.0,800/2.0)
                    
                    cout<<"temp_dist "<<temp_dist<<endl;
                    
                    //         cout<<"curB "<<curB<<" label "<<contourFinderGreyThresh.getLabel(curB)<<" , temp_centroid "<<temp_centroid<<"   dist = "<<temp_dist<<endl;
                    //        cout<<"contourFinderGreyThresh.getBoundingRect(curB) "<<contourFinderGreyThresh.getBoundingRect(curB).x<<" "<<contourFinderGreyThresh.getBoundingRect(curB).y<<" "<<contourFinderGreyThresh.getBoundingRect(curB).width<<" "<<contourFinderGreyThresh.getBoundingRect(curB).height<<endl;
                    
                    
                    //       cout<<"temp_x "<<temp_x<<" "<<temp_y<<" "<<temp_xW<<" "<<temp_yH<<endl;
                    //       cout<<"crop  "<<minCropX<<" "<<minCropY<<" "<<maxCropX<<" "<<maxCropY<<endl;
                    
                    cout<<"minCropX "<<minCropX<<", minCropY "<<minCropY <<", maxCropX "<<maxCropX<<" , maxCropY "<<maxCropY<<endl;
                    if(temp_x > minCropX && temp_y > minCropY && temp_xW < maxCropX && temp_yH < maxCropY){
                        if(temp_dist < temp_smallesdtDist){
                            temp_smallesdtDist = temp_dist;
                            //temp_label = contourFinderGreyThresh.getLabel(curB);
                            temp_id = curB;
                            
                        }
                    }
                }
                
                cout<<"temp_smallesdtDist "<<temp_smallesdtDist<<endl;
                //	cout<<"contourFinderGreyThresh.size() "<<contourFinderGreyThresh.size()<<endl;
                //       cout<<"temp_id "<<temp_id<<" "<<temp_smallesdtDist<<endl;
                cv::Mat temp_sourceMatROI;
                //     cout<<"--contourFinderGreyThresh.getBoundingRect(temp_id) "<<contourFinderGreyThresh.getBoundingRect(temp_id).x<<" "<<contourFinderGreyThresh.getBoundingRect(temp_id).y<<" "<<contourFinderGreyThresh.getBoundingRect(temp_id).width<<" "<<contourFinderGreyThresh.getBoundingRect(temp_id).height<<endl;
                
                sourceMat(contourFinderGreyThresh.getBoundingRect(temp_id)).copyTo(temp_sourceMatROI);
                
                cv::minMaxLoc(temp_sourceMatROI,&minColor,&maxColor,&minIn,&maxIn,temp_sourceMatROI);
                cout<<"minColor "<<minColor<<" "<<maxColor<<" "<<minIn<<" "<<maxIn<<endl;
                
                
                nearThresholdRange = maxColor + 1;
                farThresholdRange = minColor - 1;
                //				nearThresholdRange = MIN(255,nearThresholdRange);
                //				farThresholdRange = MAX(0,farThresholdRange);
                
                nearThresholdRange = ofClamp(nearThresholdRange, 0, 255);
                farThresholdRange = ofClamp(farThresholdRange, 0, 255);
                
                nearThreshold = ofMap(nearThresholdRange, 0, 255, 1800, 400, true);
                farThreshold = ofMap(farThresholdRange, 0, 255, 1800, 400, true);
                
                //	cout<<"minColor "<<minColor<<" "<<maxColor<<endl;
            }//end if(ofGetElapsedTimeMillis() < 2000)
            //			}else{
            //                cout<<"ofGetElapsedTimeMillis() > 2000"<<endl;
            //            }
            
            
            if(nearThreshold != old_nearThreshold || farThreshold != old_farThreshold){
                old_nearThreshold = nearThreshold;
                old_farThreshold = farThreshold;
                
                nearThresholdRange = ofMap(nearThreshold,1800,400,0,255);
                farThresholdRange = ofMap(farThreshold,1800,400,0,255);
            }
            
            grayThreshNearMat = Scalar(nearThresholdRange); //,nearThresholdRange,nearThresholdRange);
            grayThreshFarMat = Scalar(farThresholdRange); //,farThresholdRange,farThresholdRange);
            
            if(bDebugTimer){
                cout<<"I-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            //inRange(grayImageMat, grayThreshNearMat, grayThreshFarMat, grayThresh);
            inRange(sourceMat, grayThreshFarMat,grayThreshNearMat, grayThresh);
            
            
            
            ofxCv::threshold(grayThresh,binaryMat,0);
            
            Mat tempBinaryMat;
            cv::bitwise_not(binaryMat,tempBinaryMat);
            
            //only shows the rgb values within the threshold
            //rgbMat.setTo(cv::Scalar(0,0,0), tempBinaryMat);
            
            if(bDebugTimer){
                cout<<"J-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            blur(binaryMat,binaryMat,binaryBlur);
            
            if(bDebugTimer){
                cout<<"K-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            //contour finder done on binary image
            //since for contour-finding it is not important to have depth info
            //all pixels are equally important
            contourFinder.setThreshold(0);
            contourFinder.findContours(binaryMat);
            contourFinder.getTracker();
            
            //do binary blur after contour finder
            //binary blur helps to keep probablity more in center of branch
            //since it is more white in the send then on the blurry edges
            
            //blur(binaryMat,binaryMat,binaryBlur);
            
            int cSize = contourFinder.size();
            //cSize = MIN(cSize,15);
            cSize = ofClamp(cSize, 0, 15);
            
            if(bDebugTimer){
                cout<<"L-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
            
            
            if(cSize > 0){
                //cout<<"cSize > 0"<<endl;
                //only use the blob with the smallest label, which is also the oldest blob
                //or only use blob which centroid's distant is smallest to last centroid, or last filteredPointD
                
                //  cout<<" cSize "<<cSize<<endl;
                
                if(bDebugTimer){
                    cout<<"LL-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                    debugTimer = ofGetElapsedTimeMicros();
                }
                
                int maxAliveLabel = 100000;
                
                float smallest_centroidDist = 10000;
                int closestDist_label = 0;
                
                for(int curB=0; curB<cSize; curB++){
                    
                    int temp_x = toOf(contourFinder.getBoundingRect(curB)).x;
                    int temp_y = toOf(contourFinder.getBoundingRect(curB)).y;
                    int temp_xW = temp_x + toOf(contourFinder.getBoundingRect(curB)).width;
                    int temp_yH = temp_y + toOf(contourFinder.getBoundingRect(curB)).height;
                    
                    if(temp_x > minCropX && temp_y > minCropY && temp_xW < maxCropX && temp_yH < maxCropY){
                        
                        
                        int temp_label = contourFinder.getLabel(curB);
                        if(temp_label < maxAliveLabel ){
                            maxAliveLabel = temp_label;
                        }
                        
                        ofPoint temp_centroid = toOf(contourFinder.getCentroid(curB));
                        //float temp_centroidDist = temp_centroid.distance(centroid);
                        float temp_centroidDist = temp_centroid.distance(ofPoint(filteredPointD.x,filteredPointD.y));
                        if(temp_centroidDist < smallest_centroidDist){
                            smallest_centroidDist = temp_centroidDist;
                            closestDist_label = temp_label;
                        }
                        
                    }
                }
                
                if(bDebugTimer){
                    cout<<"M-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                    debugTimer = ofGetElapsedTimeMicros();
                }
                //cout<<"closestDist_label "<<closestDist_label<<" dist = "<<smallest_centroidDist<<endl;
                
                for(int curB=0; curB<cSize; curB++){
                    
                    if(bDebugTimer){
                        cout<<"M 0-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                        debugTimer = ofGetElapsedTimeMicros();
                    }
                    
                    int temp_x = toOf(contourFinder.getBoundingRect(curB)).x;
                    int temp_y = toOf(contourFinder.getBoundingRect(curB)).y;
                    int temp_xW = temp_x + toOf(contourFinder.getBoundingRect(curB)).width;
                    int temp_yH = temp_y + toOf(contourFinder.getBoundingRect(curB)).height;
                    
                    if(temp_x > minCropX && temp_y > minCropY && temp_xW < maxCropX && temp_yH < maxCropY){
                        
                        
                        
                        //loop through all available blobs and only use the oldest one
                        //if(maxAliveLabel == contourFinder.getLabel(curB)){
                        if(closestDist_label == contourFinder.getLabel(curB)){
                            
                            //                            cout<<"curB "<<curB<<" "<<closestDist_label<<endl;
                            //                            cout<<"temp_x "<<temp_x<<" "<<temp_y<<" "<<temp_xW<<" "<<temp_yH<<endl;
                            //                            cout<<"crop  "<<minCropX<<" "<<minCropY<<" "<<maxCropX<<" "<<maxCropY<<endl;
                            
                            
                            minAreRect = toOf(contourFinder.getMinAreaRect(curB));
                            //RotatedRect rr = contourFinder.getMinAreaRect(curB);
                            
                            convexHull = toOf(contourFinder.getConvexHull(curB));
                            
                            // blobAverage = mean(depthMat);
                            //cout <<"blobAverage "<<blobAverage[2])<<endl;
                            
                            
                            center = toOf(contourFinder.getCenter(curB));
                            centroid = toOf(contourFinder.getCentroid(curB));
                            
                            
                            //int sampleCount = convexHull.size();
                            
                            if(convexHull.size() >= 3){
                                
                                
                                blobX = contourFinder.getBoundingRect(curB).x;
                                blobY = contourFinder.getBoundingRect(curB).y;
                                blobWidth = contourFinder.getBoundingRect(curB).width;
                                blobHeight = contourFinder.getBoundingRect(curB).height;
                                
                                
                                if(bTakeTemplate == true){
                                    gui.hide();
                                    bShowVideo = true;
                                    bShowModel = false;
                                    bShowTracking = false;
                                    
                                    ofShowCursor();
                                    
                                    bShowTemplate = true;
                                    
                                    bTakeTemplate = false;
                                    bGotTemplate = false;
                                    
                                    templPoints.clear();
                                    skelPoints.clear();
                                    
                                    //http://felix.abecassis.me/2011/09/opencv-morphological-skeleton/
                                    skel = cv::Scalar(0);
                                    cv::Mat img;
                                    cv::Mat temp;
                                    cv::Mat eroded;
                                    
                                    binaryMat.copyTo(img);
                                    
                                    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS, cv::Size(3, 3));
                                    
                                    bool done;
                                    do
                                    {
                                        
                                        cv::erode(img, eroded, element);
                                        cv::dilate(eroded, temp, element); // temp = open(img)
                                        cv::subtract(img, temp, temp);
                                        cv::bitwise_or(skel, temp, skel);
                                        eroded.copyTo(img);
                                        
                                        done = (cv::norm(img) == 0);
                                        
                                        /*
                                         cv::morphologyEx(binaryMat, temp, cv::MORPH_OPEN, element);
                                         cv::bitwise_not(temp, temp);
                                         cv::bitwise_and(binaryMat, temp, temp);
                                         cv::bitwise_or(skel, temp, skel);
                                         cv::erode(binaryMat, binaryMat, element);
                                         
                                         double max;
                                         cv::minMaxLoc(binaryMat, 0, &max);
                                         done = (max == 0);
                                         */
                                    } while (!done);
                                    
                                    
                                    cout<<"skelPoints.size "<<skelPoints.size()<<endl;
                                    
                                    //   int skipCount = 0;
                                    
                                    for(int y=blobY; y<blobY+blobHeight; y++){
                                        for(int x=blobX; x<blobX+blobWidth; x++){
                                            int grey = binaryMat.at<uchar>(y,x);
                                            if(grey > 200){
                                                //g    skipCount++;
                                                //  if(skipCount == 100){
                                                templPoints.push_back(ofPoint(x,y));
                                                
                                                int greySkel = skel.at<uchar>(y,x);
                                                if(greySkel != 0) skelPoints.push_back(ofPoint(x,y));
                                                
                                                //  skipCount = 0;
                                                //  }
                                            }
                                        }
                                    }
                                    templPointD = toOf(contourFinder.getCentroid(curB));
                                    
                                    cout<<"templPoints.size() "<<templPoints.size()<<endl;
                                    cout<<"skelPoints.size "<<skelPoints.size()<<endl;
                                    
                                    //template_mR.makeIdentityMatrix();
                                    
                                    bTakeTemplateABCD = true;
                                    templ_pressedCnt = -1;
                                    templateState = 0;
                                }//end if(bTakeTemplate == true)
                                
                                if(bGotTemplate == true){
                                    
                                    //average the convexhull points with kmeans
                                    //make a new opencv track image with the resulting kmeans points
                                    //use contourfinder to get track labels for these points
                                    
                                    if(bDebugTimer){
                                        cout<<"M 1-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    vector <ofVec3f> cur2D_ConvexPoints;
                                    for(int i=0; i<convexHull.size(); i++){
                                        cur2D_ConvexPoints.push_back(convexHull[i]);
                                    }
                                    
                                    ofVec3f* Points_2D = new ofVec3f[3];
                                    kmeansClustering(Points_2D, 2, cur2D_ConvexPoints, 3);
                                    
                                    if(bDebugTimer){
                                        cout<<"M 2-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    convexPointMat = cv::Scalar(0,0,0);
                                    //circle(Mat& img, Point center, int radius,const Scalar& color, int thickness=1,int lineType=8, int shift=0);
                                    cv::circle(convexPointMat, cvPoint(Points_2D[0].x,Points_2D[0].y), 5, cvScalar(255, 255, 255), -1, 8, 0);
                                    cv::circle(convexPointMat, cvPoint(Points_2D[1].x,Points_2D[1].y), 5, cvScalar(255, 255, 255), -1, 8, 0);
                                    cv::circle(convexPointMat, cvPoint(Points_2D[2].x,Points_2D[2].y), 5, cvScalar(255, 255, 255), -1, 8, 0);
                                    
                                    // blur(convexPointMat,convexPointMat,conBlur);
                                    
                                    contourFinderConvex.findContours(convexPointMat);
                                    contourFinderConvex.getTracker();
                                    
                                    
                                    if(bDebugTimer){
                                        cout<<"M 3-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    if(contourFinderConvex.size() >=3 ){
                                        
                                        //--------------------  check to see if any of the 3 labels changed -------------------- -------------------- --------------------
                                        //if so use the A dist to B etc assumption to determine new labels for pointA B C
                                        //if labels did not change loop through current labels and find their centroid index
                                        //the opencv index of each track point changes even though the labels are consistent,
                                        //because opencv loops left to right and top to bottom and our object rotates
                                        convexLabelChange = false;
                                        
                                        if(bDebugTimer){
                                            cout<<"M 4-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        for(int i=0; i<contourFinderConvex.size(); i++){
                                            int temp_label = contourFinderConvex.getLabel(i);
                                            if(temp_label != convexLast2Labels[0] && temp_label != convexLast2Labels[1] && temp_label != convexLast2Labels[2]){
                                                convexLabelChange = true;
                                                cout<<"convex labels changed i = "<<i<<" ,size "<<contourFinderConvex.size()<<endl;
                                                cout<<"temp_label "<<temp_label<<" "<<convexLast2Labels[0]<<" "<<convexLast2Labels[1]<<" "<<convexLast2Labels[2]<<endl;
                                                cout<<"getLabel(0) "<<temp_label<<" "<<contourFinderConvex.getLabel(0)<<" "<<contourFinderConvex.getLabel(1)<<" "<<contourFinderConvex.getLabel(2)<<endl;
                                                
                                                lastLabelChangeTimer = ofGetElapsedTimeMillis();
                                                break;
                                            }
                                        }
                                        
                                        if(bDebugTimer){
                                            cout<<"M 5-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        convexLast2Labels[0] = contourFinderConvex.getLabel(0);
                                        convexLast2Labels[1] = contourFinderConvex.getLabel(1);
                                        convexLast2Labels[2] = contourFinderConvex.getLabel(2);
                                        
                                        if(convexLabelChange == false){
                                            for(int i=0; i<3; i++){
                                                int temp_label = contourFinderConvex.getLabel(i);
                                                if(pointA_centroidLabel == temp_label) pointA_centroidIndex = i;
                                                if(pointB_centroidLabel == temp_label) pointB_centroidIndex = i;
                                                if(pointC_centroidLabel == temp_label) pointC_centroidIndex = i;
                                            }
                                        }
                                        
                                        if(bDebugTimer){
                                            cout<<"M 6-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        // -------------------- order A B C-------------------- -------------------- -------------------- -------------------- --------------------
                                        
                                        /*
                                         cout<<"raw 3D Point ABCD "<<toOf(contourFinderConvex.getCentroid(0))<<","<<kinect.getDistanceAt(toOf(contourFinderConvex.getCentroid(0)));
                                         cout<<"  / "<<toOf(contourFinderConvex.getCentroid(1))<<","<<kinect.getDistanceAt(toOf(contourFinderConvex.getCentroid(1)));
                                         cout<<"  / "<<toOf(contourFinderConvex.getCentroid(2))<<","<<kinect.getDistanceAt(toOf(contourFinderConvex.getCentroid(2)));
                                         cout<<"  / "<<centroid<<","<<kinect.getDistanceAt(centroid)<<" : "<<endl;
                                         */
                                        
                                        //if(bShowTemplate){
                                        //calculates templAdjust matrix
                                        getTemplateAdjustment(toOf(contourFinderConvex.getCentroid(0)),toOf(contourFinderConvex.getCentroid(1)),toOf(contourFinderConvex.getCentroid(2)),centroid);
                                        //}
                                        
                                        if(bDebugTimer){
                                            cout<<"M 7-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        ofPoint tempA = ofPoint(diamPointA.x,diamPointA.y);
                                        ofPoint tempB = ofPoint(diamPointB.x,diamPointB.y);
                                        ofPoint tempC = ofPoint(diamPointC.x,diamPointC.y);
                                        //ofPoint tempD = ofPoint(diamPointD.x,diamPointD.y);
                                        
                                        float distAA = tempA.distance((templPointA-templPointD)*templAdjust_mC);
                                        float distBB = tempB.distance((templPointB-templPointD)*templAdjust_mC);
                                        float distCC = tempC.distance((templPointC-templPointD)*templAdjust_mC);
                                        
                                        
                                        //?some times the condensation lines are getting too lose to each other, and are almost parrallel
                                        //?since they look for white pixels which it does find even when not in the right alignment
                                        
                                        //but diameterPoints and condensantionPoints are seprate
                                        //cout<<"distAA "<<distAA<<" "<<distBB<<" "<<distCC<<endl;
                                        if(distAA < diamaterToTemplateDist && distBB < diamaterToTemplateDist && distCC < diamaterToTemplateDist) diameterDistTimer = ofGetElapsedTimeMillis();
                                        if(ofGetElapsedTimeMillis() - diameterDistTimer > 3000){
                                            cout<<"adjust ABC due to large distance between diamPoint and templPoint"<<endl;
                                            cout<<"distAA "<<distAA<<" "<<distBB<<" "<<distCC<<endl;
                                            //cout<<"ofGetElapsedTimeMillis() - diameterDistTimer > "<<endl;
                                            convexLabelChange = true;
                                        }
                                        
                                        if(bDebugTimer){
                                            cout<<"M 8-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        //convexLabelChange = false;
                                        if(convexLabelChange == true || ofGetElapsedTimeMillis()-lastLabelChangeTimer < 500){
                                            //assign the convexHull readings to pointA B C correctly
                                            
                                            //assume branch shape by match template position and rotation
                                            
                                            //	if(bShowTemplate == false) getTemplateAdjustment(toOf(contourFinderConvex.getCentroid(0)),toOf(contourFinderConvex.getCentroid(1)),toOf(contourFinderConvex.getCentroid(2)),centroid);
                                            
                                            
                                            float dist0A = toOf(contourFinderConvex.getCentroid(0)).distance((templPointA-templPointD)*templAdjust_mC);
                                            float dist1A = toOf(contourFinderConvex.getCentroid(1)).distance((templPointA-templPointD)*templAdjust_mC);
                                            float dist2A = toOf(contourFinderConvex.getCentroid(2)).distance((templPointA-templPointD)*templAdjust_mC);
                                            
                                            float dist0B = toOf(contourFinderConvex.getCentroid(0)).distance((templPointB-templPointD)*templAdjust_mC);
                                            float dist1B = toOf(contourFinderConvex.getCentroid(1)).distance((templPointB-templPointD)*templAdjust_mC);
                                            float dist2B = toOf(contourFinderConvex.getCentroid(2)).distance((templPointB-templPointD)*templAdjust_mC);
                                            
                                            float dist0C = toOf(contourFinderConvex.getCentroid(0)).distance((templPointC-templPointD)*templAdjust_mC);
                                            float dist1C = toOf(contourFinderConvex.getCentroid(1)).distance((templPointC-templPointD)*templAdjust_mC);
                                            float dist2C = toOf(contourFinderConvex.getCentroid(2)).distance((templPointC-templPointD)*templAdjust_mC);
                                            
                                            //cout<<"dist0A "<<dist0A<<" , "<<dist1A<<" , "<<dist2A<<endl;
                                            //								cout<<"dist0B "<<dist0B<<" , "<<dist1B<<" , "<<dist2B<<endl;
                                            //								cout<<"dist0C "<<dist0C<<" , "<<dist1C<<" , "<<dist2C<<endl;
                                            
                                            if(dist0A < dist1A && dist0A < dist2A) pointA_centroidIndex = 0;
                                            else if(dist1A < dist2A && dist1A < dist0A) pointA_centroidIndex = 1;
                                            else if(dist2A < dist0A && dist2A < dist1A) pointA_centroidIndex = 2;
                                            
                                            if(dist0B < dist1B && dist0B < dist2B) pointB_centroidIndex = 0;
                                            else if(dist1B < dist2B && dist1B < dist0B) pointB_centroidIndex = 1;
                                            else if(dist2B < dist0B && dist2B < dist1B) pointB_centroidIndex = 2;
                                            
                                            if(dist0C < dist1C && dist0C < dist2C) pointC_centroidIndex = 0;
                                            else if(dist1C < dist2C && dist1C < dist0C) pointC_centroidIndex = 1;
                                            else if(dist2C < dist0C && dist2C < dist1C) pointC_centroidIndex = 2;
                                            
                                            cout<<"pointA_centroidIndex "<<pointA_centroidIndex<<" , "<<pointB_centroidIndex<<" , "<<pointC_centroidIndex<<endl;
                                            
                                            pointA_centroidLabel = contourFinderConvex.getLabel(pointA_centroidIndex);
                                            pointB_centroidLabel = contourFinderConvex.getLabel(pointB_centroidIndex);
                                            pointC_centroidLabel = contourFinderConvex.getLabel(pointC_centroidIndex);
                                            
                                            
                                        }//end if(convexLabelChange == true)
                                        
                                        if(bDebugTimer){
                                            cout<<"M 9-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        pointA = toOf(contourFinderConvex.getCentroid(pointA_centroidIndex));
                                        pointB = toOf(contourFinderConvex.getCentroid(pointB_centroidIndex));
                                        pointC = toOf(contourFinderConvex.getCentroid(pointC_centroidIndex));
                                        
                                        
                                    }//end if(contourFinderConvex.size() >=3 )
                                    else{
                                        
                                        cout<<"contourFinderConvex.size() != 3, "<<contourFinderConvex.size()<<endl;
                                    }
                                    
                                    
                                    
                                    // -------------------- collect around diamter -------------------- -------------------- -------------------- -------------------- --------------------
                                    //collect all points (x,y,z) within a certain diameter around the raw 2D-point
                                    //to get the overall average Z
                                    //to get the middled xyz value for ABCD
                                    averageZ = 0;
                                    int nonZeroCnt = 0;
                                    int cntDiamA = 0;
                                    int cntDiamB = 0;
                                    int cntDiamC = 0;
                                    int cntDiamD = 0;
                                    
                                    
                                    old_diamPointA = diamPointA;
                                    old_diamPointB = diamPointB;
                                    old_diamPointC = diamPointC;
                                    old_diamPointD = diamPointD;
                                    
                                    
                                    if(bDebugTimer){
                                        cout<<"M 10-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    
                                    diamPointA = ofVec3f(0,0,0);
                                    diamPointB = ofVec3f(0,0,0);
                                    diamPointC = ofVec3f(0,0,0);
                                    diamPointD = ofVec3f(0,0,0);
                                    
                                    /*
                                     ofVec3f temp_diamPointA = ofVec3f(0,0,0);
                                     ofVec3f temp_diamPointB = ofVec3f(0,0,0);
                                     ofVec3f temp_diamPointC = ofVec3f(0,0,0);
                                     ofVec3f temp_diamPointD = ofVec3f(0,0,0);
                                     */
                                    
                                    
                                    for(int y=blobY; y<blobY+blobHeight; y++){
                                        for(int x=blobX; x<blobX+blobWidth; x++){
                                            float temp_z;
                                            
                                            //int n = x + y * 640;
                                            
                                            
                                            if(flipHori == true && flipVerti == true) temp_z = kinect.getDistanceAt(kinectWidth - x,kinectHeight - y);
                                            if(flipHori == true && flipVerti == false) temp_z = kinect.getDistanceAt(kinectWidth - x, y);
                                            if(flipHori == false && flipVerti == true) temp_z = kinect.getDistanceAt(x,kinectHeight - y);
                                            if(flipHori == false && flipVerti == false) temp_z = kinect.getDistanceAt(x,y);
                                            
                                            
                                            //temp_z = kinect.getDistanceAt(x, y);
                                            //temp_z = weighted_depthMat.at<uchar>(y,x);
                                            //cout<<"temp_z "<<temp_z<<endl;
                                            if(temp_z > nearThreshold && temp_z < farThreshold){
                                                averageZ += temp_z;
                                                nonZeroCnt++;
                                                
                                                if(collect_diameter > 0){
                                                    float distA = ofPoint(pointA.x,pointA.y).distance(ofPoint(x,y));
                                                    float distB = ofPoint(pointB.x,pointB.y).distance(ofPoint(x,y));
                                                    float distC = ofPoint(pointC.x,pointC.y).distance(ofPoint(x,y));
                                                    float distD = ofPoint(pointD.x,pointD.y).distance(ofPoint(x,y));
                                                    
                                                    //cout<<"raw 2D Point ABCD "<<distA<<" "<<distB<<" "<<distC<<" "<<distD<<" : "<<endl;
                                                    
                                                    if(distA < collect_diameter){
                                                        diamPointA += (ofVec3f(x,y,temp_z));
                                                        cntDiamA++;
                                                    }
                                                    if(distB < collect_diameter){
                                                        diamPointB += (ofVec3f(x,y,temp_z));
                                                        cntDiamB++;
                                                    }
                                                    if(distC < collect_diameter){
                                                        diamPointC += (ofVec3f(x,y,temp_z));
                                                        cntDiamC++;
                                                    }
                                                    if(distD < collect_diameter){
                                                        diamPointD += (ofVec3f(x,y,temp_z));
                                                        cntDiamD++;
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }//end for(int y=blobY; y<blobY+blobHeight; y++)
                                    
                                    
                                    
                                    
                                    
                                    if(bDebugTimer){
                                        cout<<"M 11-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    averageZ = averageZ / nonZeroCnt;
                                    pointD = ofPoint(centroid.x,centroid.y,averageZ);
                                    
                                    
                                    //if diameter is 0 use raw points
                                    if(collect_diameter > 0){
                                        //cout<<"cntDiamA "<<cntDiamA<<" | "<<cntDiamB<<" | "<<cntDiamC<<endl;
                                        
                                        ofPoint tempCp;
                                        if(cntDiamA > 0) diamPointA = diamPointA / cntDiamA;
                                        if(cntDiamB > 0) diamPointB = diamPointB / cntDiamB;
                                        if(cntDiamC > 0) tempCp = diamPointC / cntDiamC;
                                        if(tempCp.distance(ofPoint(0,0)) > 20) diamPointC = tempCp;
                                        //diamPointD = diamPointD / cntDiamD;
                                        
                                        diamPointD = pointD;
                                        
                                        
                                        
                                        //	cout<<"diamPointA "<<diamPointA<<" | "<<diamPointB<<" | "<<diamPointC<<" | "<<endl;
                                        
                                    }else{
                                        //filteredPointA = pointA;
                                        //								filteredPointB = pointB;
                                        //								filteredPointC = pointC;
                                        //								filteredPointD = pointD;
                                        
                                        diamPointA = pointA;
                                        diamPointB = pointB;
                                        diamPointC = pointC;
                                        diamPointD = pointD;
                                        
                                        //cout<<"pointA "<<pointA<<" | "<<pointB<<" | "<<pointC<<" | "<<endl;
                                    }
                                    
                                    if(bDebugTimer){
                                        cout<<"M 12-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                    
                                    ofRectangle cropRect(minCropX,minCropY,maxCropX-minCropX,maxCropY-minCropY);
                                    //sometimes a diameter point jumped to zero and that created a bad twist in the branch
                                    if(cropRect.inside(diamPointA.x, diamPointA.y) != true){
                                        diamPointA = old_diamPointA;
                                        cout<<"not inside(diamPointA"<<endl;
                                    }
                                    if(cropRect.inside(diamPointB.x, diamPointB.y) != true){
                                        diamPointB = old_diamPointB;
                                        cout<<"not inside(diamPointB"<<endl;
                                    }
                                    if(cropRect.inside(diamPointC.x, diamPointC.y) != true){
                                        diamPointC = old_diamPointC;
                                        cout<<"not inside(diamPointC"<<endl;
                                    }
                                    
                                    float a_dist = filteredPointA.distance(diamPointA);
                                    if(ABS(a_dist) > min_dist){
                                        filteredPointA = diamPointA;
                                    }
                                    float b_dist = filteredPointB.distance(diamPointB);
                                    if(ABS(b_dist) > min_dist){
                                        filteredPointB = diamPointB;
                                    }
                                    float c_dist = filteredPointC.distance(diamPointC);
                                    if(ABS(c_dist) > min_dist){
                                        filteredPointC = diamPointC;
                                    }
                                    float d_dist = filteredPointD.distance(diamPointD);
                                    if(ABS(d_dist) > min_dist){
                                        filteredPointD = diamPointD;
                                    }
                                    
                                    //                                    filteredPointA = diamPointA;
                                    //                                    filteredPointB = diamPointB;
                                    //                                    filteredPointC = diamPointC;
                                    //                                    filteredPointD = diamPointD;
                                    
                                    if(ofGetElapsedTimef() < initStartTime ){
                                        old_filteredPointA = filteredPointA;
                                        old_filteredPointB = filteredPointB;
                                        old_filteredPointC = filteredPointC;
                                        old_filteredPointD = filteredPointD;
                                    }
                                    
                                    //if new z value is too far away from last z value we will smooth the z value alot
                                    float distOldNew_A = ABS(old_filteredPointA.z - filteredPointA.z);
                                    float distOldNew_B = ABS(old_filteredPointB.z - filteredPointB.z);
                                    float distOldNew_C = ABS(old_filteredPointC.z - filteredPointC.z);
                                    float distOldNew_D = ABS(old_filteredPointD.z - filteredPointD.z);
                                    
                                    //cout<<"distOldNew_A "<<distOldNew_A<<endl;
                                    
                                    if(distOldNew_A > maxZdistJump) filteredPointA.z = old_filteredPointA.z + (filteredPointA.z - old_filteredPointA.z) * (1-smoothZvalue);
                                    if(distOldNew_B > maxZdistJump) filteredPointB.z = old_filteredPointB.z + (filteredPointB.z - old_filteredPointB.z) * (1-smoothZvalue);
                                    if(distOldNew_C > maxZdistJump) filteredPointC.z = old_filteredPointC.z + (filteredPointC.z - old_filteredPointC.z) * (1-smoothZvalue);
                                    if(distOldNew_D > maxZdistJump) filteredPointD.z = old_filteredPointD.z + (filteredPointD.z - old_filteredPointD.z) * (1-smoothZvalue);
                                    
                                    
                                    //	if(smoothValue > 0){
                                    //	cout<<"old_filteredPointA "<<old_filteredPointA<<" | "<<filteredPointA<<endl;
                                    /*
                                     old_filteredPointA = old_filteredPointA + (filteredPointA - old_filteredPointA) * (1-smoothValue);
                                     old_filteredPointB = old_filteredPointB + (filteredPointB - old_filteredPointB) * (1-smoothValue);
                                     old_filteredPointC = old_filteredPointC + (filteredPointC - old_filteredPointC) * (1-smoothValue);
                                     old_filteredPointD = old_filteredPointD + (filteredPointD - old_filteredPointD) * (1-smoothValue);
                                     */
                                    
                                    //here here
                                    
                                    if(bUseOutsideNewFrame == false){
                                        old_filteredPointA = old_filteredPointA + (filteredPointA - old_filteredPointA) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue);
                                        old_filteredPointB = old_filteredPointB + (filteredPointB - old_filteredPointB) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue);
                                        old_filteredPointC = old_filteredPointC + (filteredPointC - old_filteredPointC) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue);
                                        old_filteredPointD = old_filteredPointD + (filteredPointD - old_filteredPointD) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue);
                                        
                                        //cout<<"filteredPointA "<<filteredPointA<<endl;
                                        /*
                                         filteredPointA = old_filteredPointA;
                                         filteredPointB = old_filteredPointB;
                                         filteredPointC = old_filteredPointC;
                                         filteredPointD = old_filteredPointD;
                                         */
                                        
                                        filteredPointA = old_filteredPointA;
                                        filteredPointB = old_filteredPointB;
                                        filteredPointC = old_filteredPointC;
                                        filteredPointD = old_filteredPointD;
                                        
                                        //		}
                                        
                                        if(bDebugTimer){
                                            cout<<"M 13-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                            debugTimer = ofGetElapsedTimeMicros();
                                        }
                                        
                                        if(bUseKalman){
                                            if(ofGetElapsedTimef() > initStartTime){
                                                if(bNewKalmanSetting == true){
                                                    bNewKalmanSetting = false;
                                                    
                                                    clearKalman(0);
                                                    clearKalman(1);
                                                    clearKalman(2);
                                                    clearKalman(3);
                                                    
                                                    updateKalmanSettings(0, filteredPointA);
                                                    updateKalmanSettings(1, filteredPointB);
                                                    updateKalmanSettings(2, filteredPointC);
                                                    updateKalmanSettings(3, filteredPointD);
                                                    
                                                    cout<<"reset kalman filter"<<endl;
                                                }
                                                filteredPointA = updateKalman(0, filteredPointA);
                                                filteredPointB = updateKalman(1, filteredPointB);
                                                filteredPointC = updateKalman(2, filteredPointC);
                                                filteredPointD = updateKalman(3, filteredPointD);
                                                
                                            }
                                        }
                                        
                                        filteredPointA2 = filteredPointA;
                                        filteredPointB2 = filteredPointB;
                                        filteredPointC2 = filteredPointC;
                                        filteredPointD2 = filteredPointD;
                                    }
                                    
                                    
                                    if(bDebugTimer){
                                        cout<<"M 14-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                                        debugTimer = ofGetElapsedTimeMicros();
                                    }
                                    
                                }//end if(bGotTemplate)
                            }//end if(convexHull.size() >= 3){
                            
                        }//end if(maxAliveLabel == curB
                        
                    }//end if(inside crop)
                }//end for(int curB=0; curB<cSize; curB++)
                
                
                if(bDebugTimer){
                    cout<<"N-- "<<ofGetElapsedTimeMillis()-debugTimer<<endl;
                    debugTimer = ofGetElapsedTimeMillis();
                }
            }//end if cSize>0
            
            if(bDebugTimer){
                cout<<"O-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
                debugTimer = ofGetElapsedTimeMicros();
            }
            
        }//end if(bStartupMode == false)
        //	}//end if kinectInitSuccess == true;
        
        if(bDebugTimer){
            cout<<"P-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMicros();
        }
        
    }//end if newFrame
    
    if(bUseOutsideNewFrame){
        
        //    cout<<"filteredPointB - old_filteredPointB "<<(filteredPointB - old_filteredPointB)<<endl;
        old_filteredPointA = old_filteredPointA + ((filteredPointA - old_filteredPointA) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue));
        old_filteredPointB = old_filteredPointB + ((filteredPointB - old_filteredPointB) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue));
        old_filteredPointC = old_filteredPointC + ((filteredPointC - old_filteredPointC) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue));
        old_filteredPointD = old_filteredPointD + ((filteredPointD - old_filteredPointD) * ofPoint(1-smoothXValue,1-smoothYValue,1-smoothZvalue));
        
        //   cout<<"old_filteredPointB "<<old_filteredPointB<<endl;
        //cout<<"filteredPointA "<<filteredPointA<<endl;
        /*
         filteredPointA = old_filteredPointA;
         filteredPointB = old_filteredPointB;
         filteredPointC = old_filteredPointC;
         filteredPointD = old_filteredPointD;
         */
        
        filteredPointA2 = old_filteredPointA;
        filteredPointB2 = old_filteredPointB;
        filteredPointC2 = old_filteredPointC;
        filteredPointD2 = old_filteredPointD;
        
        //		}
        
        if(bDebugTimer){
            cout<<"M 13-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
            debugTimer = ofGetElapsedTimeMicros();
        }
        
        if(bUseKalman){
            if(ofGetElapsedTimef() > initStartTime){
                if(bNewKalmanSetting == true){
                    bNewKalmanSetting = false;
                    
                    clearKalman(0);
                    clearKalman(1);
                    clearKalman(2);
                    clearKalman(3);
                    
                    updateKalmanSettings(0, filteredPointA2);
                    updateKalmanSettings(1, filteredPointB2);
                    updateKalmanSettings(2, filteredPointC2);
                    updateKalmanSettings(3, filteredPointD2);
                    
                    cout<<"reset kalman filter"<<endl;
                }
                filteredPointA2 = updateKalman(0, filteredPointA2);
                filteredPointB2 = updateKalman(1, filteredPointB2);
                filteredPointC2 = updateKalman(2, filteredPointC2);
                filteredPointD2 = updateKalman(3, filteredPointD2);
                
            }
        }
    }
    
    
    if(bDebugTimer){
        cout<<"Q-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    if(ofGetElapsedTimeMillis() - lastSendTime > serialSendPause && serialMessages.size() > 0){
        lastSendTime = ofGetElapsedTimeMillis();
        serialSending();
    }
    
    
    if(bCamLoadPos){
        bCamLoadPos = false;
        camLoadPos();
    }
    //	if(bCamLoadTopPos){
    //		bCamLoadTopPos = false;
    //		camLoadTopPos();
    //	}
    
    if(bCamSavePos){
        bCamSavePos = false;
        camSavePos();
    }
    //	if(bCamSaveTopPos){
    //		bCamSaveTopPos = false;
    //		camSaveTopPos();
    //	}
    
    if(frameType == 1){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->borderWidth = borderWidth;
            thePolygons[i]->update();
        }
    }
    
    
    if(bUseMouse != old_bUseMouse){
        old_bUseMouse = bUseMouse;
        camEasyCam.setMouseActions(bUseMouse);
    }
    
    if(camFarClip != old_camFarClip){
        old_camFarClip = camFarClip;
        fixedCam.setFarClip(camFarClip);
    }
    if(bCamReset == true){
        bCamReset = false;
        camEasyCam.reset();
    }
    
    
    if(bSetCamToAnchor == true){
        bSetCamToAnchor = false;
        camPos = filteredPointD2; // + offsetP;
    }
    
    
    if(bDebugTimer){
        cout<<"Y-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    ofMatrix4x4 mT;
    mT.makeTranslationMatrix(camPos);
    
    ofMatrix4x4 tempM_x,tempM_y,tempM_z;
    tempM_x.makeRotationMatrix(cam_tilt, 1, 0, 0);
    tempM_y.makeRotationMatrix(cam_pan, 0, 1, 0);
    tempM_z.makeRotationMatrix(cam_roll, 0, 0, 1);
    
    fixedCam.setTransformMatrix(tempM_x*tempM_y*tempM_z*mT);
    
    
    if(bDebugTimer){
        cout<<"Z-- "<<ofGetElapsedTimeMicros()-debugTimer<<endl;
        debugTimer = ofGetElapsedTimeMicros();
    }
    
    if(bEditFrame == true) ofShowCursor();
    
}

//--------------------------------------------------------------
void ofApp::draw2() {
    
    ofSetColor(255, 255, 255);
    
    //	if(bDrawPointCloud) {
    //		easyCam.begin();
    //		drawPointCloud();
    //		easyCam.end();
    //	} else {
    //		// draw from the live kinect
    //		kinect.drawDepth(10, 10, 400, 300);
    //		kinect.draw(420, 10, 400, 300);
    //
    //		grayImage.draw(10, 320, 400, 300);
    //		contourFinder.draw(10, 320, 400, 300);
    //	}
    
    drawMat(rgbMat, 0, 0);
    
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofToString(ofGetFrameRate()), 50, 50);
}


//--------------------------------------------------------------
void ofApp::draw() {
    
    if(bDebugTimer){
        cout<<"0-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    ofSetColor(255, 255, 255);
    
    if(bStartupMode == true){
        
        
        
        /*
         drawMat(sourceMat, 0, 0, kinectWidth, kinectHeight);
         ofDrawBitmapString("depth video", 0,10);
         drawMat(rgbMat, kinectWidth+2, 0);
         ofDrawBitmapString("rgb video", 0,10);
         */
        
        string temp_msg;
        float temp_sWidth;
        
        if(initStage == 0){
            ofSetColor(255);
            drawMat(rgbMat, ofGetWidth()/2 - 160, ofGetHeight()/2 - 120, 320,240);
            ofDrawBitmapString("rgb video", ofGetWidth()/2 - 160 + 2, ofGetHeight()/2 - 120 + 10);
        }
        if(initStage == 1){
            ofSetColor(255);
            drawMat(rgbMat, ofGetWidth()/2 - 160, ofGetHeight()/2 - 120, 320,240);
            ofDrawBitmapString("rgb video", ofGetWidth()/2 - 160 + 2, ofGetHeight()/2 - 120 + 10);
            
            ofSetColor(0);
            temp_msg = "Please stand out of sight of the camera !";
            temp_sWidth = arial.stringWidth(temp_msg);
            
            arial.drawString(temp_msg, ofGetWidth()/2 - temp_sWidth/2,ofGetHeight()/2 + 120 + 40);
            
            temp_msg = "Calibration starts in: "+ ofToString(int(10 - ofGetElapsedTimef())) + " seconds.";
            temp_sWidth = arial.stringWidth(temp_msg);
            
            arial.drawString(temp_msg, ofGetWidth()/2 - temp_sWidth/2,ofGetHeight()/2 + 120 + 40 + 40);
        }
        
        if(initStage == 2){
            
            //float temp_timeValue = fmod(ofGetElapsedTimef(),2);
            //			temp_timeValue = ofMap(temp_timeValue, 0, 2, -1, 1, true);
            //			temp_timeValue = ABS(temp_timeValue);
            //			temp_timeValue = temp_timeValue * 255;
            //			ofSetColor(temp_timeValue);
            ofSetColor(125);
            
            temp_msg = "calibrating ...";
            temp_sWidth = arial.stringWidth(temp_msg);
            arial.drawString(temp_msg, ofGetWidth()/2 - temp_sWidth/2,ofGetHeight() - 15);
        }
        
        if(initStage == 3){
            ofSetColor(255);
            drawMat(sourceMat, ofGetWidth()/2 - 160, ofGetHeight()/2 - 120, 320,240);
            ofDrawBitmapString("depth video", ofGetWidth()/2 - 160 + 2, ofGetHeight()/2 - 120 + 10);
            
            ofSetColor(0);
            temp_msg = "Calibration is done now.";
            temp_sWidth = arial.stringWidth(temp_msg);
            
            arial.drawString(temp_msg, ofGetWidth()/2 - temp_sWidth/2,ofGetHeight()/2 + 120 + 40);
            
            ofPushMatrix();
            
            ofTranslate(ofGetWidth()/2 - 160, ofGetHeight()/2 - 120);
            
            ofScale(0.5, 0.5, 0);
            ofSetColor(255,255,0);
            ofNoFill();
            ofCircle(pointA,collect_diameter);
            ofCircle(pointB,collect_diameter);
            ofCircle(pointC,collect_diameter);
            ofCircle(pointD,collect_diameter);
            
            ofSetColor(255);
            arial.drawString("A", pointA.x+10,pointA.y+10);
            arial.drawString("B", pointB.x+10,pointB.y+10);
            arial.drawString("C", pointC.x+10,pointC.y+10);
            ofPopMatrix();
        }
        
        
    }
    
    if(bDebugTimer){
        cout<<"1-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    if(bShowVideo){
        
        //	kinect.drawDepth(0, 0, kinectWidth, kinectHeight);
        //		ofDrawBitmapString("kinect.drawDepth", 0,10);
        //		kinect.draw(kinectWidth+2, 0, 320, 240);
        
        drawMat(sourceMat, 0, 0, kinectWidth, kinectHeight);
        ofDrawBitmapString("depth video", 0,10);
        drawMat(rgbMat, kinectWidth+2, 0, 320, 240);
        ofDrawBitmapString("rgb video",  kinectWidth+2,10);
        
        //drawMat(skel,0,kinectHeight+2,320,240);
        //		ofDrawBitmapString("skel", 0,kinectHeight+2+10);
        
        
        drawMat(binaryMat,0,kinectHeight+2,320,240);
        ofDrawBitmapString("binaryMat", 0,kinectHeight+2+10);
        
        drawMat(MatWithInfo, kinectWidth+2,240+2,320,240);
        ofDrawBitmapString("cv info", kinectWidth+2,240+2+10);
        
        drawMat(convexPointMat, 320, kinectHeight+2, 320,240);
        ofDrawBitmapString("convex points", 320,kinectHeight+2+10);
        
        drawMat(grayThresh, 320*2,kinectHeight+2,320,240);
        ofDrawBitmapString("grayThresh", 320*2,kinectHeight+2+10);
        
        //drawMat(grayThreshNearMat, kinectWidth+320, 0, 320, 240);
        //		drawMat(grayThreshFarMat, kinectWidth+320, 240, 320, 240);
        
        
        
        //crop lines
        ofLine(minCropX, minCropY, maxCropX, minCropY);
        ofLine(maxCropX, minCropY, maxCropX, maxCropY);
        ofLine(minCropX, maxCropY, maxCropX, maxCropY);
        ofLine(minCropX, minCropY, minCropX, maxCropY);
        
        
        //		Mat temp2_rgbMat = Mat(kinectHeight, kinectWidth, CV_8UC3, kinect.getPixels(), 0);
        //		drawMat(temp2_rgbMat, ofGetWidth()-320, ofGetHeight()-240,320,240);
        
        //drawMat(HistogramTemplateMat, kinectWidth+320+100,100+240*2);
        //		drawMat(HistogramTemplateMask, kinectWidth+320+100,300+240*2);
        
    }
    
    if(bDebugTimer){
        cout<<"2-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    if(bShowTemplate){
        
        
        ofPoint tempA,tempB,tempC, tempD;
        
        if(bGotTemplate){
            ofSetColor(255,0,0);
            for(int i=0; i<templPoints.size(); i++){
                ofCircle(templPoints[i]*templAdjust_mC, 1);
            }
            
            ofSetColor(0,0,255);
            for(int i=0; i<skelPoints.size(); i++){
                ofCircle(skelPoints[i]*templAdjust_mC, 1);
            }
            
            tempA = (templPointA-templPointD)*templAdjust_mC;
            tempB = (templPointB-templPointD)*templAdjust_mC;
            tempC = (templPointC-templPointD)*templAdjust_mC;
            tempD = (templPointD-templPointD)*templAdjust_mC;
            
        }else{
            ofSetColor(255,0,0);
            for(int i=0; i<templPoints.size(); i++){
                ofCircle(templPoints[i], 1);
            }
            
            ofSetColor(0,0,255);
            for(int i=0; i<skelPoints.size(); i++){
                ofCircle(skelPoints[i], 1);
            }
            
            tempA = templPointA;
            tempB = templPointB;
            tempC = templPointC;
            tempD = templPointD;
            
        }
        
        
        
        
        
        ofSetColor(255, 255, 0);
        ofDrawBitmapString("A", tempA);
        ofDrawBitmapString("B", tempB);
        ofDrawBitmapString("C", tempC);
        ofDrawBitmapString("D", tempD);
        
        
        ofLine(tempA.x-10, tempA.y, tempA.x+10, tempA.y);
        ofLine(tempA.x, tempA.y-10, tempA.x, tempA.y+10);
        ofLine(tempB.x-10, tempB.y, tempB.x+10, tempB.y);
        ofLine(tempB.x, tempB.y-10, tempB.x, tempB.y+10);
        ofLine(tempC.x-10, tempC.y, tempC.x+10, tempC.y);
        ofLine(tempC.x, tempC.y-10, tempC.x, tempC.y+10);
        
    }
    
    
    if(bDebugTimer){
        cout<<"3-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    
    if(bShowTracking){
        ofSetColor(255);
        contourFinder.draw();
        
        
        //
        for(int i = 0; i < contourFinderConvex.size(); i++) {
            
            ofVec2f centroid = toOf(contourFinderConvex.getCentroid(i));
            int myLabel = contourFinderConvex.getLabel(i);
            
            ofSetColor(255,255,255);
            ofDrawBitmapString(ofToString(myLabel), centroid.x,centroid.y+25);
            
        }
        
        //draw all regular blob labels in green
        for(int i = 0; i < contourFinder.size(); i++) {
            
            ofVec2f centroid = toOf(contourFinder.getCentroid(i));
            int myLabel = contourFinder.getLabel(i);
            
            ofSetColor(0,255,0);
            ofDrawBitmapString(ofToString(myLabel), centroid.x,centroid.y+65);
            
        }
        
        
        //		ofSetColor(255,255,0);
        //		for(int i = 0; i<SamplesNum; i++){
        //			ofCircle((probableCondensD[i]*ofPoint(1,1,0)),2);
        //		}
        //
        //		ofSetColor(0,0,255);
        //		for(int i=0; i<skelPoints.size(); i++){
        //			//if(i < 3) cout<<"skelPoints[i]*condensMatrix "<<i<<" "<<skelPoints[i]*condensMatrix<<endl;
        //			ofCircle(skelPoints[i]*condensMatrix, 1);
        //		}
        
        ofSetLineWidth(2);
        
        
        //ofRect(blobX, blobY, blobWidth, blobHeight);
        
        ofPushMatrix();
        ofScale(1, 1, 0);
        
        
        //ofSetColor(255, 255, 255);
        //		ofLine(condensPointA,condensPointB);
        //		ofLine(condensPointC,condensPointD);
        
        
        
        
        ofSetColor(255, 0, 255);
        ofLine(filteredPointA2,filteredPointB2);
        ofSetColor(0, 0, 255);
        ofLine(filteredPointC2,filteredPointD2);
        
        
        
        ofSetColor(255,255,0);
        ofCircle(diamPointA,2);
        ofCircle(diamPointB,2);
        ofCircle(diamPointC,2);
        ofCircle(diamPointD,2);
        
        
        ofNoFill();
        ofCircle(pointA,collect_diameter);
        ofCircle(pointB,collect_diameter);
        ofCircle(pointC,collect_diameter);
        ofCircle(pointD,collect_diameter);
        ofFill();
        
        ofLine(pointA,diamPointA);
        ofLine(pointB,diamPointB);
        ofLine(pointC,diamPointC);
        ofLine(pointD,diamPointD);
        
        ofPopMatrix();
        
        
        
        ofSetColor(100);
        convexHull.draw();
        ofSetColor(0, 0, 255);
        //minAreRect.draw();
        
        
        //ofLine(centroid.x-40, centroid.y, centroid.x+40, centroid.y);
        //		ofLine(centroid.x, centroid.y-40, centroid.x, centroid.y+40);
        //ofCircle(centroid, 3);
        ofSetColor(255, 255, 0);
        //ofCircle(center, 3);
        ofCircle(centroid.x,centroid.y,averageZ,3);
        //ofCircle(blobAverage[0],blobAverage[1],blobAverage[2], 3);
        
        ofSetColor(0, 255, 155);
        ofCircle(convexPoints[0],6);
        ofCircle(convexPoints[1],6);
        ofCircle(convexPoints[2],6);
        
        
        //contourFinder.draw();
        //contourFinder.draw(640,0);
        ofSetColor(255);
        arial.drawString("A", pointA.x+10,pointA.y+10);
        arial.drawString("B", pointB.x+10,pointB.y+10);
        arial.drawString("C", pointC.x+10,pointC.y+10);
        arial.drawString("D", pointD.x+10,pointD.y+10);
        
        
        //        ofPushMatrix();
        //        ofTranslate(pendulumAnchor.x, pendulumAnchor.y);
        //        ofLine(-20,0,20,0);
        //        ofLine(0,-20,0,20);
        //        ofPopMatrix();
        
        
        
        if(bStartupMode == false){
            ofSetColor(255);
            drawHighlightString(ofToString((int) ofGetFrameRate()) + " fps", 10, 220);
            drawHighlightString("blobs " + ofToString(contourFinder.size()) + ", corners " + ofToString(contourFinderConvex.size()), 10, 240);
            drawHighlightString("aveProb " +  ofToString(aveProb) + " / 1", 10, 260);
            drawHighlightString("movement " +  ofToString(distA_oldA), 10, 280);
            drawHighlightString("luminance " +ofToString(old_generalLuminance) + " -> " + ofToString(generalLuminance), 10, 320);
            //            drawHighlightString("pKalmanA " +ofToString(pKalmanA) + " -> " + ofToString(pKalmanB), 10, 120);
            
            //int t_distAB = int(filteredPointA.distance(filteredPointB));
            //drawHighlightString("branchABlength A->B " +ofToString(t_distAB)+ " / "+ ofToString(branchABlength), 10, 120);
            //drawHighlightString("dist Condens->Raw " +ofToString((int)distRawA_condensA)+" "+ofToString((int)distRawB_condensB)+" "+ofToString((int)distRawC_condensC), 10, 140);
            
            //drawHighlightString("averageZ " + ofToString(averageZ), 10, 100);
        }
        
    }//end bshowtracking
    
    if(bDebugTimer){
        cout<<"4-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    //camera.begin();
    cameras[iMainCamera]->begin();
    drawScene(iMainCamera);
    
    //camera.end();
    cameras[iMainCamera]->end();
    
    if(bDebugTimer){
        cout<<"5-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    if(frameType==1){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->draw();
        }
    }
    
    
    if(frameType == 2){
        ofEnableAlphaBlending();
        ofSetColor(255);
        frameImage.draw(0, 0,ofGetWidth(),ofGetHeight());
        ofDisableAlphaBlending();
    }
    
    if(bDebugTimer){
        cout<<"6-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    if(bShowGui == true){
        ofSetColor(255);
        drawHighlightString(ofToString((int) ofGetFrameRate()) + " fps", ofGetHeight()-20, 20);
    }
    if(bShowGui){
        gui.draw();
    }else{
        gui.hide();
    }
    
    if(bDebugTimer){
        cout<<"7-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    ofSetColor(255);
    if(iMainCamera == 0) ofDrawBitmapString("grab and drag camera view",20,20);
    if(iMainCamera == 1) ofDrawBitmapString("front camera view",20,20);
    if(iMainCamera == 2) ofDrawBitmapString("top camera view",20,20);
    
    if(bDebugTimer){
        cout<<"8-- "<<ofGetElapsedTimeMillis()-debugDrawTimer<<endl;
        debugDrawTimer = ofGetElapsedTimeMillis();
    }
    
    //if(iMainCamera == 3) ofDrawBitmapString("object's POV",20,20);
    if(bEditFrame){
        
        if(frameCornerCnt == 0){
            ofSetColor(255);
            ofDrawBitmapString("leftTop", mouseX-1,mouseY-1);
            ofSetColor(0);
            ofDrawBitmapString("leftTop", mouseX,mouseY);
        }
        if(frameCornerCnt == 1){
            ofSetColor(255);
            ofDrawBitmapString("rightTop", mouseX-1,mouseY-1);
            ofSetColor(0);
            ofDrawBitmapString("rightTop", mouseX,mouseY);
        }
        if(frameCornerCnt == 2){
            ofSetColor(255);
            ofDrawBitmapString("rightBottom", mouseX-1,mouseY-1);
            ofSetColor(0);
            ofDrawBitmapString("rightBottom", mouseX,mouseY);
        }
        if(frameCornerCnt == 3){
            ofSetColor(255);
            ofDrawBitmapString("leftBottom", mouseX-1,mouseY-1);
            ofSetColor(0);
            ofDrawBitmapString("leftBottom", mouseX,mouseY);
        }
    }
}

void ofApp::drawScene(int iCameraDraw){
    
    
    if(bDebug){
        ofSetLineWidth(4);
        
        ofSetColor(255,0,0);
        ofLine(0,0,0,50,0,0);
        ofLine(0,0,0,-50,0,0);
        
        ofSetColor(0,255,0);
        ofLine(0,0,0,0,50,0);
        ofLine(0,0,0,0,-50,0);
        
        ofSetColor(0,0,255);
        ofLine(0,0,0,0,0,50);
        ofLine(0,0,0,0,0,-50);
        ofSetLineWidth(1);
    }
    
    // ofDisableAlphaBlending();
    //if(bShowModel)
    
    
    
    
    
    
    
    if(bShowPointcloud){
        drawPointCloud();
    }
    
    
    
    //let's not draw the camera
    //if we're looking through it
    //  if(bShowCameraFrustrum){
    if (iCameraDraw != N_CAMERAS-1)
    {
        
        //ofSetColor(255, 0, 0);
        //ofLine(camInObject.getPosition(), camInObject.getLookAtDir()*50 );
        //ofLine(camInObject.getPosition(), lookAtPoint*100 );
        ofPushStyle();
        
        //in 'camera space' this frustum
        //is defined by a box with bounds
        //-1->1 in each axis
        //
        //to convert from camera to world
        //space, we multiply by the inverse
        //matrix of the camera
        //
        //by applying this transformation
        //our box in camera space is
        //transformed into a frustum in
        //world space.
        
        ofMatrix4x4 inverseCameraMatrix;
        //ofMatrix4x4 correctCameraMatrix = camEasyCam.getModelViewProjectionMatrix( (iMainCamera == 0 ? viewMain : viewGrid[0]) );
        
        //the camera's matricies are dependant on
        //the aspect ratio of the viewport
        //so we must send the viewport if it's not
        //the same as fullscreen
        //
        //watch the aspect ratio of preview camera
        //inverseCameraMatrix.makeInvertOf(camEasyCam.getModelViewProjectionMatrix());
        ofRectangle viewOnObject;
        viewOnObject.x=0;
        viewOnObject.y = 0;
        viewOnObject.width = 400;//640; //
        viewOnObject.height = 300; //480; //
        
        
        inverseCameraMatrix.makeInvertOf(fixedCam.getModelViewProjectionMatrix(viewOnObject));
        
        // By default, we can say
        //	'we are drawing in world space'
        //
        // The camera matrix performs
        //	world->camera
        //
        // The inverse camera matrix performs
        //	camera->world
        //
        // Our box is in camera space, if we
        //	want to draw that into world space
        //	we have to apply the camera->world
        //	transformation.
        //
        ofPushMatrix();
        //glMultMatrixf(correctCameraMatrix.getPtr()); //
        glMultMatrixf(inverseCameraMatrix.getPtr());
        
        ofSetColor(0, 100, 255);
        ofSetLineWidth(2);
        //////////////////////
        // DRAW WIREFRAME BOX
        //
        // xy plane at z=-1 in camera sapce
        // (small rectangle at camera position)
        //
        glBegin(GL_LINE_LOOP);
        glVertex3f(-1, -1, -1);
        glVertex3f(-1, 1, -1);
        glVertex3f(1, 1, -1);
        glVertex3f(1, -1, -1);
        glEnd();
        
        
        // xy plane at z=1 in camera space
        // (generally invisible because so far away)
        //
        glBegin(GL_LINE_LOOP);
        glVertex3f(-1, -1, 1);
        glVertex3f(-1, 1, 1);
        glVertex3f(1, 1, 1);
        glVertex3f(1, -1, 1);
        glEnd();
        
        // connecting lines between above 2 planes
        // (these are the long lines)
        //
        glBegin(GL_LINES);
        glVertex3f(-1, 1, -1);
        glVertex3f(-1, 1, 1);
        
        glVertex3f(1, 1, -1);
        glVertex3f(1, 1, 1);
        
        glVertex3f(-1, -1, -1);
        glVertex3f(-1, -1, 1);
        
        glVertex3f(1, -1, -1);
        glVertex3f(1, -1, 1);
        glEnd();
        //
        //////////////////////
        ofSetLineWidth(1);
        ofPopStyle();
        ofPopMatrix();
    }
    //}
    
    
    //   blurStage.begin();
    //  	ofSetColor(255);
    drawModel(); //drawModel(comb);
    //  	blurStage.end();
    
    //	blurStage.draw();
}

void ofApp::drawModel(){
    
    
    
    //cout<<"model xyz "<<x<<", "<<y<<", "<<z<<endl;
    ofSetColor(255,255,255);
    
    //glMatrixMode(GL_MODELVIEW);
    //	glPushAttrib(GL_ALL_ATTRIB_BITS);
    //    glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
    //    glEnable(GL_NORMALIZE);
    
    ofPushMatrix();
    
    
    //if(bUseRaw) ofTranslate(kalmanPointD);
    //	else ofTranslate(diamPointD);
    
    if(bUseRaw){
        ofTranslate(diamPointD.x,diamPointD.y);
    }
    else {
        /*
         //  ofTranslate(pendulumAnchor);
         
         //ofPoint temp_p = ofPoint((filteredPointD.x-pendulumAnchor.x)*xyMotionScaler ,(filteredPointD.y-pendulumAnchor.y)*xyMotionScaler);
         //ofTranslate(ofPoint(0,0));
         
         ofPoint temp_diff = ofPoint(filteredPointD.x,filteredPointD.y)-ofPoint(old_filteredPointD.x,old_filteredPointD.y);
         accumDdiff += temp_diff;
         ofPoint tempP = (ofPoint(diamPointD.x,diamPointD.y)-ofPoint(pendulumAnchor.x,pendulumAnchor.y));
         //   cout<<"tempP"<<tempP<<endl;
         
         ofTranslate(tempP);
         ofTranslate(accumDdiff*xyMotionScaler);
         */
        
        ofTranslate(filteredPointD2.x,filteredPointD2.y);
    }
    
    
    //GLfloat* glMat  = new GLfloat[16];
    
    
    if(bDebug){
        int tempDia = 400;
        ofSetColor(0, 0, 255);
        //        for(int i=0; i<360;i++){
        //            ofLine(0,0,cos(ofDegToRad(i))*tempDia,sin(ofDegToRad(i))*tempDia);
        //        }
        
        ofNoFill();
        ofCircle(0, 0, tempDia);
        
    }
    
    GLfloat* glMat  = new GLfloat[16];
    
    ofPoint ttPoint = ofPoint(1,0,1);
    /*
     filteredPointA *= ofPoint(1,0,1);
     filteredPointB *= ofPoint(1,0,1);
     filteredPointC *= ofPoint(1,0,1);
     */
    /*
     filteredPointA *= ttPoint;
     filteredPointB *= ttPoint;
     filteredPointC *= ttPoint;
     
     diamPointA *= ttPoint;
     diamPointB *= ttPoint;
     diamPointC *= ttPoint;
     */
    
    if(bUseRaw) pointsToGlMatrix(glMat,diamPointA,diamPointB,diamPointC);
    else pointsToGlMatrix(glMat,filteredPointA2,filteredPointB2,filteredPointC2);
    
    // ofRotate(kalmanAngle,0,0,1);
    
    glMultMatrixf(glMat);
    
    
    //ofMatrix4x4 MR = ry* MR; //rx*ry * MR;
    
    if(bDebug){
        ofSetLineWidth(4);
        
        ofSetColor(255,0,0);
        ofLine(0,0,0,300,0,0);
        ofLine(0,0,0,-300,0,0);
        
        ofSetColor(0,255,0);
        ofLine(0,0,0,0,300,0);
        ofLine(0,0,0,0,-300,0);
        
        ofSetColor(0,0,255);
        ofLine(0,0,0,0,0,300);
        ofLine(0,0,0,0,0,-300);
        ofSetLineWidth(1);
        
        
        int tempDia = 300;
        ofSetColor(255, 0, 0);
        for(int i=0; i<360;i++){
            ofLine(0,0,cos(ofDegToRad(i))*tempDia,sin(ofDegToRad(i))*tempDia);
        }
        
        ofNoFill();
        ofCircle(0, 0, tempDia);
    }
    //    ofRotate(angleYOffset+(treeTilt*tiltAmplify),1,0,0);
    //   ofRotate(angleXOffset,1,0,0);
    
    ofRotate(270, 0, 0, 1);// ???
    ofTranslate(offsetP.x,offsetP.y, offsetP.z);
    
    
    ofScale(normScale, normScale, normScale);
    ofScale(modelScale.x*modelScaleOffset,modelScale.y*modelScaleOffset,modelScale.z*modelScaleOffset);
    
    
    if(bShowModel){
        ofEnableSmoothing();
        ofEnableAlphaBlending() ;
        // modelMesh.disableColors();
        model.disableColors();
        
        if(modelAlpha != 0){
            
            ofSetColor(0,0,0,modelAlpha);
            //  modelMesh.drawFaces();
            model.drawFaces();
        }
        if(wireAlpha != 0){
            ofSetColor(0,0,0,wireAlpha);
            model.drawWireframe();
            //modelMesh.drawWireframe();
        }
        
        model.enableColors();
        //  modelMesh.enableColors();
        ofDisableAlphaBlending();
        ofDisableSmoothing();
        
        /*
         ofEnableSmoothing();
         ofEnableAlphaBlending() ;
         modelMesh.disableColors();
         ofSetColor(0,0,0,modelAlpha);
         modelMesh.drawFaces();
         
         
         ofSetColor(0,0,0,wireAlpha);
         modelMesh.drawWireframe();
         modelMesh.enableColors();
         
         ofDisableAlphaBlending();
         ofDisableSmoothing();
         */
    }
    
    
    // glDisable(GL_DEPTH_TEST);
    
    // model.drawFaces();
    
    
    //ofDisableAlphaBlending();
    //ofTranslate(-model.getPosition().x, -model.getPosition().y, 0);
    //ofTranslate(-model.getPosition().x+offsetP.x, -model.getPosition().y+offsetP.y, 0);
    
    ofPopMatrix();
    
    //ofDrawAxis(100);
    
    //	glDisable(GL_NORMALIZE);
    //	glPopClientAttrib();
    //	glPopAttrib();
    
}

ofMatrix4x4 ofApp::pointsToGlMatrix(GLfloat * glMat, ofVec3f pA, ofVec3f pB, ofVec3f pC){
    //http://forum.openframeworks.cc/index.php/topic,8986.0.html
    
    ofVec3f vC;
    ofVec3f B2;
    
    ofVec3f vBA = pB - pA;
    ofVec3f vCA = pC - pA;
    vBA.normalize();
    vCA.normalize();
    
    
    ofVec3f vD = vBA.crossed(vCA);
    vD.normalize();
    
    ofVec3f vCp = vD.crossed(vBA);
    vCp.normalize();
    
    ofMatrix4x4 MR = ofMatrix4x4(vBA.x,vBA.y,vBA.z, 0,
                                 vCp.x,vCp.y,vCp.z, 0,
                                 vD.x, vD.y, vD.z, 0,
                                 0, 0, 0, 1);
    
    //	ofMatrix4x4 rx;
    //	rx.makeRotationMatrix(angleXOffset,1,0,0);
    ofMatrix4x4 ry;
    ry.makeRotationMatrix(angleYOffset,0,1,0);
    //	ofMatrix4x4 rz;
    //	rz.makeRotationMatrix(angleZOffset,0,0,1);
    
    //MR = MR*rx*ry*rz;
    
    // MR = rx * ry * MR;
    MR = ry * MR;
    
    ofMatrix4x4 MRinv = MR.getInverse();
    
    
    glMat[0] = MRinv._mat[0][0];
    glMat[1] = MRinv._mat[1][0];
    glMat[2] = MRinv._mat[2][0];
    glMat[3] = MRinv._mat[3][0];
    
    glMat[4] = MRinv._mat[0][1];
    glMat[5] = MRinv._mat[1][1];
    glMat[6] = MRinv._mat[2][1];
    glMat[7] = MRinv._mat[3][1];
    
    glMat[8] = MRinv._mat[0][2];
    glMat[9] = MRinv._mat[1][2];
    glMat[10] = MRinv._mat[2][2];
    glMat[11] = MRinv._mat[3][2];
    
    glMat[12] = MRinv._mat[0][3];
    glMat[13] = MRinv._mat[1][3];
    glMat[14] = MRinv._mat[2][3];
    glMat[15] = MRinv._mat[3][3];
    
    return MRinv;
    
    // ofMatrix4x4				openGL
    //							 x   y   z    t
    //x [0]  [1]  [2]  [3]		[0] [4] [8]  [12]
    //y [4]  [5]  [6]  [7]		[1] [5] [9]  [13]
    //z [8]  [9]  [10] [11]		[2] [6] [10] [14]
    //t [12] [13] [14] [15]		[3] [7] [11] [15]
}


void ofApp::drawPointCloud() {
    int w = 640;
    int h = 480;
    
    cloudMesh.clear();
    int step = 2;
    for(int y = 0; y < h; y += step) {
        for(int x = 0; x < w; x += step) {
            
            float temp_z;
            ofColor temp_color;
            
#ifdef USE_RECORD
            //temp_z = depthMat.at<uchar>(x, y);
            int n = x + y*w;
            
            //	if(flipHori == true && flipVerti == true) n = (w-x) + (h-y)*w; //temp_z = kinect.getDistanceAt(kinectWidth - x,kinectHeight - y);
            //			if(flipHori == true && flipVerti == false) n = (w-x) + y*w; //temp_z = kinect.getDistanceAt(kinectWidth - x, y);
            //			if(flipHori == false && flipVerti == true) n = x + (h-y)*w;// temp_z = kinect.getDistanceAt(x,kinectHeight - y);
            //			if(flipHori == false && flipVerti == false) n = x + y*w;
            
            
            
            temp_z = distancePixels[n];
            temp_color.r = rgbPixels[3 * n]; //colorMat.at<cv::Vec3b>(x,y)[0];
            temp_color.g = rgbPixels[3 * n+1]; //colorMat.at<cv::Vec3b>(x,y)[1];
            temp_color.b = rgbPixels[3 * n+2]; //colorMat.at<cv::Vec3b>(x,y)[2];
#else
            
            if(flipHori == true && flipVerti == true) temp_z = kinect.getDistanceAt(kinectWidth - x,kinectHeight - y);
            if(flipHori == true && flipVerti == false) temp_z = kinect.getDistanceAt(kinectWidth - x, y);
            if(flipHori == false && flipVerti == true) temp_z = kinect.getDistanceAt(x,kinectHeight - y);
            if(flipHori == false && flipVerti == false) temp_z = kinect.getDistanceAt(x,y);
            
            /*
             if(flipHori == true && flipVerti == true) temp_color = kinect.getColorAt(kinectWidth - x,kinectHeight - y);
             if(flipHori == true && flipVerti == false) temp_color = kinect.getColorAt(kinectWidth - x, y);
             if(flipHori == false && flipVerti == true) temp_color = kinect.getColorAt(x,kinectHeight - y);
             if(flipHori == false && flipVerti == false) temp_color = kinect.getColorAt(x,y);
             */
            
            temp_color = kinect.getColorAt(x,y);
            
            if(flipHori == true && flipVerti == false) temp_color = kinect.getColorAt(kinectWidth -x,kinectHeight - y);
            if(flipHori == false && flipVerti == true) temp_color = kinect.getColorAt(kinectWidth -x,kinectHeight - y);
            
            //temp_z = kinect.getDistanceAt(x, y);
            //temp_color = kinect.getColorAt(x,y);
#endif
            if(temp_z > nearThreshold && temp_z < farThreshold) {
                cloudMesh.addColor(temp_color);
                //cloudMesh.addVertex(kinect.getWorldCoordinateAt(x, y));
                cloudMesh.addVertex(ofVec3f(x,y,temp_z));
            }
        }
    }
    
    glPointSize(3);
    //ofPushMatrix();
    
    // the projected points are 'upside down' and 'backwards'
    
    glEnable(GL_DEPTH_TEST);
    
    cloudMesh.drawVertices();
    
    ofSetColor(0, 0, 255);
    ofNoFill();
    
    ofLine(0,0,0,kinectWidth,0,0);
    ofLine(kinectWidth,0,0, kinectWidth,kinectHeight,0);
    ofLine(kinectWidth,kinectHeight,0, 0,kinectHeight,0);
    ofLine(0,kinectHeight,0, 0,0,0);
    
    
    ofLine(0,0,5000,kinectWidth,0,5000);
    ofLine(kinectWidth,0,5000, kinectWidth,kinectHeight,5000);
    ofLine(kinectWidth,kinectHeight,5000, 0,kinectHeight,5000);
    ofLine(0,kinectHeight,5000, 0,0,5000);
    
    
    ofLine(0,0,0,0,0,5000);
    ofLine(kinectWidth,0,0, kinectWidth,0,5000);
    ofLine(kinectWidth,kinectHeight,0, kinectWidth,kinectHeight,5000);
    ofLine(0,kinectHeight,0, 0,kinectHeight,5000);
    
    
    ofSetColor(255, 255, 0);
    ofSphere(filteredPointA, 5);
    ofSphere(filteredPointB, 5);
    ofSphere(filteredPointC, 5);
    ofSphere(filteredPointD, 5);
    
    
    
    ofSetLineWidth(3);
    
    ofSetColor(255, 0, 0);
    ofLine(filteredPointA,filteredPointB);
    ofSetColor(0, 0, 255);
    ofLine(filteredPointC,filteredPointD);
    
    
    
    //ofSetColor(255,255,255);
    //	ofPushMatrix();
    //	ofTranslate(diamPointA-ofPoint(0,0,15));
    //	ofDrawBitmapString("A", 0,0,0);
    //	ofPopMatrix();
    //
    //	ofPushMatrix();
    //	ofTranslate(diamPointB-ofPoint(0,0,15));
    //	ofDrawBitmapString("B", 0,0,0);
    //	ofPopMatrix();
    //
    //	ofPushMatrix();
    //	ofTranslate(diamPointC-ofPoint(0,0,15));
    //	ofDrawBitmapString("C", 0,0,0);
    //	ofPopMatrix();
    //
    //	ofPushMatrix();
    //	ofTranslate(diamPointD-ofPoint(0,0,15));
    //	ofDrawBitmapString("D", 0,0,0);
    //	ofPopMatrix();
    
    glDisable(GL_DEPTH_TEST);
}


//--------------------------------------------------------------
void ofApp::exit() {
    //kinect.setCameraTiltAngle(0); // zero the tilt on exit
    
    kinect.close();
    
    cout<<"exit app"<<endl;
    
    std::exit(1);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
    
    if(key == '/') bDebug = !bDebug;
    //if(key =='.') pendulumAnchor = diamPointD; //filteredPointD;
    if(key == 'a'){
        gui.nextPage();
    }
    
    
    if(key == 'g'){
        bShowGui = !bShowGui;
        if(bShowGui){
            ofShowCursor();
            gui.show();
        }
        else{
            saveFramePositions();
            ofHideCursor();
            gui.hide();
            
        }
    }
    
    if(key == 'v') bShowVideo = !bShowVideo;
    if(key == 'p') bShowPointcloud = !bShowPointcloud;
    if(key == 't') bShowTracking = !bShowTracking;
    if(key == 'm') bShowModel = !bShowModel;
    if( key == 'f') ofToggleFullscreen();
    
    if(key == 's'){
        fixedCam.setTransformMatrix(camTop.getLocalTransformMatrix());
    }
    /*
     if(key == 's'){
     cvReleaseConDensation(&conDens);
     cvConDensInitSampleSet(conDens, &lowerBound, &upperBound);
     }
     if( key == 'u') updateData = !updateData;
     */
    
    
    if(key == '0'){
        iMainCamera++;
        if(iMainCamera >=N_CAMERAS ) iMainCamera = 0;
    }
    
    
    //	ofVec3f p = fixedCam.getPosition();
    //	ofVec3f uy = fixedCam.getUpDir();
    //	ofVec3f ux = fixedCam.getSideDir();
    //	float ar = float(ofGetViewportWidth()) / float(ofGetViewportHeight());
    
    float cameraStep = 5;
    //pan camera
    //	if(key == '1') fixedCam.move(cameraStep * -ux * 1 * ar);
    //	if(key == '2') fixedCam.move(-cameraStep * -ux * 1 * ar);
    //	if(key == '3') fixedCam.move(-cameraStep * uy * 1);
    //	if(key == '4') fixedCam.move(cameraStep * uy * 1);
    //
    //	//dolly camera
    //	if(key == '5') fixedCam.move(2 * ofVec3f(0,0,1) * -cameraStep);
    //	if(key == '6') fixedCam.move(2 * ofVec3f(0,0,1) * cameraStep);
    
    //left /right
    if(key == '1') camPos.x += cameraStep;
    if(key == '2') camPos.x -= cameraStep;
    //up/down
    if(key == '3') camPos.z += cameraStep;
    if(key == '4') camPos.z -= cameraStep;
    //in/out
    if(key == '5') camPos.y -= cameraStep;
    if(key == '6') camPos.y += cameraStep;
    
    
    
    /*
     if(key == 'n'){
     clearKalman(0);
     clearKalman(1);
     clearKalman(2);
     clearKalman(3);
     
     //		updateKalmanSettings(0,diamPointA);
     //		updateKalmanSettings(1,diamPointB);
     //		updateKalmanSettings(2,diamPointC);
     //		updateKalmanSettings(3,diamPointD);
     }
     
     if(key == 'u')  setRefPointsAgain();
     if( key == 'l') convexLabelChange = true;
     */
    
    if(key == '8'){
        
        string s = "123e";
        cout<<"s "<<s<<endl;
        serialMessages.push_back(s);
    }
    if(key == '9'){
        
        string s = "123n";
        cout<<"s "<<s<<endl;
        serialMessages.push_back(s);
    }
    
    if(bEditFrame){
        if(key == 'l'){
            frameCornerCnt = 0;
            cornerPoints[0] = ofPoint(mouseX,mouseY);
        }
        if(key == ';'){
            frameCornerCnt = 1;
            cornerPoints[1] = ofPoint(mouseX,mouseY);
        }
        if(key == '.'){
            frameCornerCnt = 2;
            cornerPoints[2] = ofPoint(mouseX,mouseY);
        }
        if(key == ','){
            frameCornerCnt = 3;
            cornerPoints[3] = ofPoint(mouseX,mouseY);
        }
        
        if(key == OF_KEY_LEFT){
            cornerPoints[frameCornerCnt].x -= 1;
        }
        if(key == OF_KEY_RIGHT){
            cornerPoints[frameCornerCnt].x += 1;
        }
        if(key == OF_KEY_UP){
            cornerPoints[frameCornerCnt].y -= 1;
        }
        if(key == OF_KEY_DOWN){
            cornerPoints[frameCornerCnt].y += 1;
        }
    }
}

//------------- -------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
    if(bEditFrame){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->mouseMoved(x,y);
        }
    }
}


//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button)
{
    
    if(gui.isOn()){
        
#ifdef USE_RECORD
        
#else
        //kinect.setDepthClipping(nearThreshold, farThreshold);
#endif
    }
    
    if(bEditFrame){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->mouseDragged(x,y,button);
        }
    }
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button)
{
    if(bEditFrame){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->mousePressed(x,y,button);
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button)
{
    
    if(bEditFrame){
        for (int i = 0; i < nPolygons; i++){
            thePolygons[i]->mouseReleased(x,y,button);
        }
        
        
    }
    unsigned long curTap = ofGetElapsedTimeMillis();
    if(lastTap != 0 && curTap - lastTap < 250){
        
        bShowGui = !bShowGui;
        
        if(bShowGui){
            gui.show();
            ofShowCursor();
        }
        else{
            saveFramePositions();
            gui.hide();
            
            if(bDebug == false){
                bShowVideo = false;
                bShowTemplate = false;
                bShowTracking = false;
                bShowPointcloud = false;
                bShowModel = true;
            }
            ofHideCursor();
            
            
        }
        
        //mouseDoublePressed = true;
    }
    lastTap = curTap;
    
    
    
    if(button == 2) bNewKalmanSetting = true;
    
    
    if(bShowVideo || bShowTracking || bShowGui) ofShowCursor();
    //if(bUseCondensation == false) setRefPointsAgain();
    
    if(bTakeTemplateABCD == true && templateState == 0){
        
        if(templ_pressedCnt == 0){
            templPointA = ofPoint(x,y);
            cout<<"got templPointA"<<endl;
        } else if(templ_pressedCnt == 1){
            templPointB = ofPoint(x,y);
            cout<<"got templPointB"<<endl;
        } else if(templ_pressedCnt == 2){
            templPointC = ofPoint(x,y);
            cout<<"got templPointC"<<endl;
            
            for(int i=0; i<templPoints.size(); i++){
                templPoints[i] = templPoints[i] - templPointD;
            }
            for(int i=0; i<skelPoints.size(); i++){
                skelPoints[i] = skelPoints[i] - templPointD;
            }
            
            ofVec3f fromVec(1,0,0);
            ofVec3f toVec(templPointA-templPointD);
            
            template_mR.makeRotationMatrix(fromVec, toVec);
            template_mR = template_mR.getInverse();
            
            //bFindPos = true;
            
            templateState = 1;
            bTakeTemplateABCD = false;
            
            bGotTemplate = true;
            
            saveTemplatePoints();
        }
        
        templ_pressedCnt++;
    }
    
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h)
{}

void ofApp::camLoadPos(){
    //grabcamera setup
    //grabcam position
    //read in default 3d view
    
    ofFile inFile;
    inFile.open("savePose.mat", ofFile::ReadOnly, true);
    inFile.read((char*) defaultPosition.getPtr(), sizeof(float) * 16);
    inFile.close();
    fixedCam.setTransformMatrix(defaultPosition);
    
    cout<<"load camera position"<<endl;
    
}
//void ofApp::camLoadTopPos(){
//
//	ofFile inFile;
//	inFile.open("saveTopPose.mat", ofFile::ReadOnly, true);
//	inFile.read((char*) topPosition.getPtr(), sizeof(float) * 16);
//	inFile.close();
//	camEasyCam.setTransformMatrix(topPosition);
//
//	cout<<"load camera top position"<<endl;
//
//}

void ofApp::camSavePos(){
    //bCamSavePos = !bCamSavePos;
    defaultPosition = fixedCam.getGlobalTransformMatrix();
    
    ofFile outFile;
    outFile.open("savePose.mat", ofFile::WriteOnly, true);
    outFile.write((char*) defaultPosition.getPtr(), sizeof(float) * 16);
    outFile.close();
    
    cout<<"save camera position"<<endl;
    
}
//void ofApp::camSaveTopPos(){
//	//bCamSaveTopPos = !bCamSaveTopPos;
//	topPosition = camEasyCam.getGlobalTransformMatrix();
//
//	ofFile outFile;
//	outFile.open("saveTopPose.mat", ofFile::WriteOnly, true);
//	outFile.write((char*) topPosition.getPtr(), sizeof(float) * 16);
//	outFile.close();
//
//	cout<<"save top camera position"<<endl;
//
//}

void ofApp::getRecordedData(){
    
#ifdef USE_RECORD
    int temp_near = ofMap(nearThreshold, 0, 5000, 0, 255);
    int temp_far = ofMap(farThreshold, 0, 5000, 0, 255);
    int temp_rows = 480;
    int temp_cols = 640;
    
    averageZ = 0;
    int nonZeroCnt = 0;
    for(int y=0; y<temp_rows; y++){
        for(int x=0; x<temp_cols; x++){
            
            int n = x + y*temp_cols;
            
            colorMat.at<cv::Vec3b>(y,x)[0] = rgbPixels[3 * n];
            colorMat.at<cv::Vec3b>(y,x)[1] = rgbPixels[3 * n + 1];
            colorMat.at<cv::Vec3b>(y,x)[2] = rgbPixels[3 * n + 2];
            
            //	float pz = ofMap(distancePixels[n], 0, 1000, 0, 255);
            
            float pz = 0;
            float temp_z = distancePixels[n];
            if(temp_z > nearThreshold && temp_z < farThreshold){
                pz = ofMap(temp_z, 0, 5000, 255, 0);
                averageZ += temp_z;
                nonZeroCnt++;
            }
            
            depthMat.at<uchar>(y,x) = pz;
            
            
        }
    }
    
    averageZ = averageZ / nonZeroCnt;
    
    /*
     int temp_mirror;
     if(flipHori == true && flipVerti == true) temp_mirror = -1;
     if(flipHori == true && flipVerti == false) temp_mirror = 0;
     if(flipHori == false && flipVerti == true) temp_mirror = 1;
     if(flipHori == false && flipVerti == false){
     }else{
     flip(colorMat,colorMat,temp_mirror); //0 flip x-axis, 1 means flip y-axis, -1 flip x&y axis
     flip(depthMat,depthMat,temp_mirror);
     }
     */
    
#endif
    
}


//ofPoint ofApp::getZ(ofPoint pt){
//	int n = pt.x + pt.y * 640;
//
//#ifdef USE_RECORD
//	pt.z = distancePixels[n]; //get real world depth value in mm
//#else
//	pt.z = kinect.getDistanceAt(pt.x,pt.y);
//#endif
//	//depthMat.at<uchar>(y,x); //get gray depth value 0 - 255
//
//	return pt;
//}

//void ofApp::initCondens(){
//
//
//	cout<<"start init condensation"<<endl;
//
//	// Initialize condensation
//	condensDim = 3; //translate x, translate y, rotation
//	//SamplesNum = 50;
//	conDens = cvCreateConDensation(condensDim,condensDim,SamplesNum);
//
//	// Initialize the search boundaries
//	lowerBound = cvMat(condensDim, 1, CV_32F, NULL);
//	upperBound = cvMat(condensDim, 1, CV_32F, NULL);
//
//	cvmAlloc(&lowerBound);
//	cvmAlloc(&upperBound);
//
//	float temp_trans = 40.0; //40.0f; //10
//	float temp_ange = 40.0f; //50 //15
//
//
//
//	lowerBound.data.fl[0] = -temp_trans;//pD.x translation difference lower bound
//	lowerBound.data.fl[1] = -temp_trans;//pD.y translation difference lower bound
//	//lowerBound.data.fl[2] = -temp_trans;//pD.z translation difference lower bound
//	lowerBound.data.fl[2] = -temp_ange;//rotation/heading translation difference lower bound
//
//	upperBound.data.fl[0] = temp_trans;//pD.x translation difference lower bound
//	upperBound.data.fl[1] = temp_trans;//pD.y translation difference lower bound
//	//upperBound.data.fl[2] = temp_trans;//pD.z translation difference lower bound
//	upperBound.data.fl[2] = temp_ange;//rotation/heading translation difference lower bound
//
//
//	cvConDensInitSampleSet(conDens, &lowerBound, &upperBound);
//
//
//	cout<<"done init condensation"<<endl;
//
//	initPhaseTimer = ofGetElapsedTimeMillis();
//
//}

//void ofApp::setRefPointsAgain(){
//
//	cout<<ofGetTimestampString()<< "+++++++++++++++++++ ++++++++++++++++++++++++ ++++++++++++++++++++ ++++++++ set condensation ref points again"<<endl;
//
//	condensPointA = diamPointA;
//	condensPointB = diamPointB;
//	condensPointC = diamPointC;
//	condensPointD = ofPoint(centroid.x,centroid.y,averageZ);
//
//	condensMatrix = templAdjust_mC;
//
//
//}
//
//void ofApp::initAgain(){
//	cvReleaseConDensation(&conDens);
//
//	cout<<ofGetTimestampString()<<"------------------ ------------------ ------------------ ------------------ reset condensation"<<endl;
//	condensPointA = diamPointA;
//	condensPointB = diamPointB;
//	condensPointC = diamPointC;
//	condensPointD = ofPoint(centroid.x,centroid.y,averageZ);
//
//	condensMatrix = templAdjust_mC;
//
//    //	initCondens();
//
//
//}


//ofPoint ofApp::calcAverage(ofPoint tempVector[100], int arraySize){ //vector <ofPoint> tempVector){
//
//	ofPoint tempPoint = ofPoint(0,0,0);
//
//	if(arraySize > 0){
//		for(int a=0; a<arraySize; a++){
//			tempPoint = tempPoint + tempVector[a];
//		}
//		tempPoint = tempPoint/arraySize;
//	}
//
//	return tempPoint;
//}

bool ofApp::checkBounds(ofPoint pt){
    
    bool tempB = false;
    
    if(pt.x > 0 && pt.x < kinectWidth && pt.y > 0 && pt.y < kinectHeight) tempB = true;
    
    return tempB;
    
}
float ofApp::distanceFromLine(ofPoint p,ofPoint l1,ofPoint l2){
    float xDelta = l2.x - l1.x;
    float yDelta = l2.y - l1.y;
    
    //	final double u = ((p3.getX() - p1.getX()) * xDelta + (p3.getY() - p1.getY()) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
    float u = ((p.x - l1.x) * xDelta + (p.y - l1.y)*yDelta) / (xDelta * xDelta + yDelta * yDelta);
    
    ofPoint closestPointOnLine;
    if (u < 0) {
        closestPointOnLine = l1;
    } else if (u > 1) {
        closestPointOnLine = l2;
    } else {
        closestPointOnLine = ofPoint(l1.x + u * xDelta, l1.y + u * yDelta);
    }
    
    
    ofPoint d = p - closestPointOnLine;
    return sqrt(d.x * d.x + d.y * d.y); // distance
}


// Compute the cost along the line
float ofApp::computeLineCost(cv::Mat img, ofPoint pt1, ofPoint pt2) {
    //float ofApp::computeLineCost(IplImage* img,ofPoint pt1, ofPoint pt2) {
    
    float dLambda = 0.02; // 50 //100 points between the two vectors
    int nbPt = (int)(1.0/dLambda);
    
    float ptx, pty, ptz;
    
    bool pt1Inside = checkBounds(pt1);
    bool pt2Inside = checkBounds(pt2);
    
    totalValue = 0.0;
    
    //cout<<"pt1Inside "<<pt1Inside<<" "<<pt2Inside<<endl;
    //pt1Inside = pt2Inside = true;
    
    if(pt1Inside == true && pt2Inside == true){
        
        //cout<<"in pt1 pt2 "<<pt1<<" | "<<pt2<<endl;
        
        for ( int i=0 ; i<nbPt ; i++ ) {
            float value = 0.0;
            
            // (x',y') = (x1,y1) * lambda ((x2,y2) - (x1,y1))
            ptx = pt1.x + i*dLambda*(pt2.x-pt1.x);
            pty = pt1.y + i*dLambda*(pt2.y-pt1.y);
            
            
            
            // Here I simply round the values, the best
            // would be to interpolate the values sub-pixel
            int x = (int)round(ptx);
            int y = (int)round(pty);
            
            //unsigned char rr = depthMat.at<uchar>(y,x);
            unsigned char rr = binaryMat.at<uchar>(y,x);
            
            value = rr/255.0;
            
            if(value < 0 || value > 1){
                cout<<"bad value "<<endl;
                break;
            }
            totalValue += value;
        }
    }else{
        
        //cout<<"out pt1 pt2 "<<pt1<<" | "<<pt2<<endl;
    }
    
    // A probability between 0 and 1
    return (totalValue/nbPt);
    
}

float ofApp::computeSkeletonCost(cv::Mat img, vector <ofPoint> checkPoints, ofMatrix4x4 possibleMatrix){
    
    float totalProb = 0.0;
    float value = 0.0;
    int valCnt = 0;
    //cout<<"checkPoints.size() "<<checkPoints.size()<<endl;
    
    for(int i=0; i<checkPoints.size(); i++){
        
        ofPoint tempPt = checkPoints[i] * possibleMatrix;
        bool ptInside = checkBounds(tempPt);
        
        
        unsigned char rr;
        
        if(ptInside){
            rr = img.at<uchar>(tempPt.y,tempPt.x);
            
            value = rr/255.0;
            
            if(value < 0 || value > 1){
                cout<<"bad value "<<endl;
                break;
            }else{
                totalProb += value;
                valCnt++;
            }
        }else{
            cout<<"tempPt "<<tempPt<<endl;
            
        }
    }
    
    //cout<<"valCnt "<<valCnt<<" "<<totalProb<<endl;
    
    if(valCnt == 0) return(0);
    else return (totalProb/valCnt);
}


void ofApp::getTemplateAdjustment(ofPoint c0,ofPoint c1,ofPoint c2,ofPoint mainC){
    ofMatrix4x4 mR0;
    ofMatrix4x4 mR1;
    ofMatrix4x4 mR2;
    
    
    ofVec3f fromVec(1,0,0);
    ofVec3f toVec0(c0-mainC);
    ofVec3f toVec1(c1-mainC);
    ofVec3f toVec2(c2-mainC);
    
    mR0.makeRotationMatrix(fromVec, toVec0);
    mR1.makeRotationMatrix(fromVec, toVec1);
    mR2.makeRotationMatrix(fromVec, toVec2);
    
    
    ofMatrix4x4 mT;
    mT.makeTranslationMatrix(mainC);
    
    
    int totalGrey0 = 0;
    int totalGrey1 = 0;
    int totalGrey2 = 0;
    
    // cout<<"getTemplateAdjustment templPoints.size() "<<templPoints.size()<<endl;
    for(int i=0; i<templPoints.size(); i++){
        ofPoint temp_pt0 = templPoints[i] * template_mR * mR0 * mT;
        totalGrey0 += binaryMat.at<uchar>(temp_pt0.y,temp_pt0.x);
        
        ofPoint temp_pt1 = templPoints[i] * template_mR * mR1 * mT;
        totalGrey1 += binaryMat.at<uchar>(temp_pt1.y,temp_pt1.x);
        
        ofPoint temp_pt2 = templPoints[i] * template_mR * mR2 * mT;
        totalGrey2 += binaryMat.at<uchar>(temp_pt2.y,temp_pt2.x);
    }
    
    if(totalGrey0 > totalGrey1 && totalGrey0 > totalGrey2) templAdjust_mC = template_mR * mR0 * mT;
    if(totalGrey1 > totalGrey2 && totalGrey1 > totalGrey0) templAdjust_mC = template_mR * mR1 * mT;
    if(totalGrey2 > totalGrey0 && totalGrey2 > totalGrey1) templAdjust_mC = template_mR * mR2 * mT;
    
}

void ofApp::saveTemplatePoints(){
    
    cout<<"try to save template points "<<endl;
    
    ofstream textFile;
    textFile.open(ofToDataPath("template.txt").c_str()); //ios::in);
    //this also creates a text file if non exits
    
    string outString;
    outString = ofToString(templPointA.x)+ " " +ofToString(templPointA.y)+ "\n";
    outString += ofToString(templPointB.x)+ " " +ofToString(templPointB.y)+ "\n";
    outString += ofToString(templPointC.x)+ " " +ofToString(templPointC.y)+ "\n";
    outString += ofToString(templPointD.x)+ " " +ofToString(templPointD.y)+ "\n";
    
    cout<<"templPoints.size() "<<templPoints.size()<<endl;
    for(int i=0; i<templPoints.size(); i++){
        outString += ofToString(templPoints[i].x)+ " " +ofToString(templPoints[i].y)+ "\n";
    }
    
    textFile.write(outString.c_str(), outString.size());
    textFile.close();
    
    
    //ofstream textFile;
    textFile.open(ofToDataPath("skeleton.txt").c_str()); //ios::in);
    //this also creates a text file if non exits
    
    outString = "";
    for(int i=0; i<skelPoints.size(); i++){
        outString += ofToString(skelPoints[i].x)+ " " +ofToString(skelPoints[i].y)+ "\n";
    }
    
    textFile.write(outString.c_str(), outString.size());
    textFile.close();
    
    
    cout<<"done saving template points "<<endl;
    
}

bool ofApp::loadTemplatePoints(){
    
    cout<<"try to load template file"<<endl;
    ifstream textFile;
    
    textFile.open(ofToDataPath("template.txt").c_str()); //ios::in);
    int lineCount = 0;
    templPoints.clear();
    
    if(textFile == NULL){
        cout<<"no text to load from"<<endl;
        return false;
    }else{
        
        
        while(textFile != NULL){
            string line;
            getline(textFile,line);
            
            
            
            if(line.length() >0){
                
                
                vector<string> splitLine;
                
                splitLine = ofSplitString(line, " ", true);
                
                if(lineCount == 0){
                    templPointA.x = ofToFloat(splitLine[0]);
                    templPointA.y = ofToFloat(splitLine[1]);
                }
                if(lineCount == 1){
                    templPointB.x = ofToFloat(splitLine[0]);
                    templPointB.y = ofToFloat(splitLine[1]);
                }
                if(lineCount == 2){
                    templPointC.x = ofToFloat(splitLine[0]);
                    templPointC.y = ofToFloat(splitLine[1]);
                }
                if(lineCount == 3){
                    templPointD.x = ofToFloat(splitLine[0]);
                    templPointD.y = ofToFloat(splitLine[1]);
                }
                if(lineCount > 3){
                    for(int i=0; i<splitLine.size(); i++){
                        float tempX = ofToFloat(splitLine[0]);
                        float tempY = ofToFloat(splitLine[1]);
                        templPoints.push_back(ofPoint(tempX,tempY));
                    }
                }
                
                lineCount ++;
            }
        }
        
        
    }
    textFile.close();
    
    textFile.open(ofToDataPath("skeleton.txt").c_str()); //ios::in);
    lineCount = 0;
    skelPoints.clear();
    
    if(textFile == NULL){
        cout<<"no text to load from"<<endl;
        return false;
    }else{
        
        
        while(textFile != NULL){
            string line;
            getline(textFile,line);
            
            if(line.length() >0){
                
                vector<string> splitLine;
                
                splitLine = ofSplitString(line, " ", true);
                for(int i=0; i<splitLine.size(); i++){
                    float tempX = ofToFloat(splitLine[0]);
                    float tempY = ofToFloat(splitLine[1]);
                    skelPoints.push_back(ofPoint(tempX,tempY));
                }
                
                lineCount ++;
            }
        }
        
        
        
    }
    textFile.close();
    cout<<"done loading template file with "<<lineCount<<" lines "<<endl;
    return true;
    
    
}

void ofApp::serialSending(){
    
    if(serialMessages.size() > 0){
        
        unsigned char* sendCmd = (unsigned char*)  serialMessages[0].c_str();
        
        int tempLength = serialMessages[0].length();
        
        if(serialActive){
            
            //bSendSomething = true;
            //serialTxRxTimer = ofGetElapsedTimeMillis();
            
            //serial.writeBytes(sendCmd, sizeof(sendCmd));
            serial.writeBytes(sendCmd, tempLength);
            
            cout<<"*sendCmd "<<sendCmd<<", size "<<tempLength<<endl;
            //ofLog()<<"*sendCmd "<<sendCmd;
        }
        
        serialMessages.erase(serialMessages.begin());
    }
    
}

void ofApp::getSerialDevice(){
    
    vector<ofSerialDeviceInfo> serialDevices = serial.getDeviceList();
    
    string deviceLine;
    for(int i=0; i<serialDevices.size();i++){
        
        deviceLine = serialDevices[i].getDeviceName().c_str();
        
        //cout<<serialDevices[i].getDeviceName().c_str()<<endl;
        
        if(deviceLine.substr(0,12) == "tty.usbmodem"){
            serialID = "/dev/" +deviceLine;
            cout<<"arduino serial = "<<serialID<<endl;
        }
        
        //if(deviceLine.substr(0,13) == "tty.usbserial"){
        //			serialID = "/dev/" +deviceLine;
        //			cout<<"arduino serial = "<<serialID<<endl;
        //		}
    }
    
}

void ofApp::saveFramePositions(){
    
    cout<<"saveFramePOsitions"<<endl;
    cornerPoints[0] = ofPoint(thePolygons[0]->curveVertices[3].x,thePolygons[0]->curveVertices[3].y);
    cornerPoints[1] = ofPoint(thePolygons[0]->curveVertices[2].x,thePolygons[0]->curveVertices[2].y);
    cornerPoints[2] = ofPoint(thePolygons[1]->curveVertices[3].x,thePolygons[1]->curveVertices[3].y);
    cornerPoints[3] = ofPoint(thePolygons[2]->curveVertices[0].x,thePolygons[2]->curveVertices[0].y);
    
    gui.saveToXML();
}

void ofApp::updateFrame(){
    //top polygon
    thePolygons[0]->curveVertices[0].x = 0;
    thePolygons[0]->curveVertices[0].y = 0;
    thePolygons[0]->curveVertices[1].x = ofGetWidth();
    thePolygons[0]->curveVertices[1].y = 0;
    thePolygons[0]->curveVertices[2].x = cornerPoints[1].x;
    thePolygons[0]->curveVertices[2].y = cornerPoints[1].y;
    thePolygons[0]->curveVertices[3].x = cornerPoints[0].x;
    thePolygons[0]->curveVertices[3].y = cornerPoints[0].y;
    
    //right polygon
    thePolygons[1]->curveVertices[0].x = cornerPoints[1].x;
    thePolygons[1]->curveVertices[0].y = cornerPoints[1].y;
    thePolygons[1]->curveVertices[1].x = ofGetWidth();
    thePolygons[1]->curveVertices[1].y = 0;
    thePolygons[1]->curveVertices[2].x = ofGetWidth();
    thePolygons[1]->curveVertices[2].y = ofGetHeight();
    thePolygons[1]->curveVertices[3].x = cornerPoints[2].x;
    thePolygons[1]->curveVertices[3].y = cornerPoints[2].y;
    
    //bottom polygon
    thePolygons[2]->curveVertices[0].x = cornerPoints[3].x;
    thePolygons[2]->curveVertices[0].y = cornerPoints[3].y;
    thePolygons[2]->curveVertices[1].x = cornerPoints[2].x;
    thePolygons[2]->curveVertices[1].y = cornerPoints[2].y;
    thePolygons[2]->curveVertices[2].x = ofGetWidth();
    thePolygons[2]->curveVertices[2].y = ofGetHeight();
    thePolygons[2]->curveVertices[3].x = 0;
    thePolygons[2]->curveVertices[3].y = ofGetHeight();
    
    //left polygon
    thePolygons[3]->curveVertices[0].x = 0;
    thePolygons[3]->curveVertices[0].y = 0;
    thePolygons[3]->curveVertices[1].x = cornerPoints[0].x;
    thePolygons[3]->curveVertices[1].y = cornerPoints[0].y;
    thePolygons[3]->curveVertices[2].x = cornerPoints[3].x;
    thePolygons[3]->curveVertices[2].y = cornerPoints[3].y;
    thePolygons[3]->curveVertices[3].x = 0;
    thePolygons[3]->curveVertices[3].y = ofGetHeight();
}