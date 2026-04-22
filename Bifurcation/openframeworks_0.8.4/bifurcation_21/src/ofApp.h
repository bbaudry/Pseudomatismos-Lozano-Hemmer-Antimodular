#pragma once

#include "ofMain.h"

#include "ofxKinect.h"

#include "ofxGrabCam.h"

#include "ofxCv.h"

#include "ofxSimpleGuiToo.h"


#include "ofxOpenCv.h"
#include <legacy.hpp>
#include "ofxAssimpModelLoader.h"

#include "myPolygon.h"

#include "ofxCvKalman.h"

#include "ofxBlur.h"

#include "OrthoCamera.h"

using namespace ofxCv;
using namespace cv;

#define N_CAMERAS 4
#define AVG_AMT 60

class ofApp : public ofBaseApp{

	public:
    string version;
    
    void setup();
    void update(),update2();
    void draw(),draw2();
    void exit();
    
    void drawPointCloud();


    void keyPressed (int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    
    void getRecordedData();
    //ofPoint getZ(ofPoint pt);
    
    void drawModel();
    
    ofMatrix4x4 pointsToGlMatrix(GLfloat * glMat, ofVec3f pA, ofVec3f pB, ofVec3f pC);
    void kmeansClustering(ofVec3f * returnPoints, int arrayDim, vector <ofVec3f> pointArray, int clusterCount);
    void displayMatrixShift(ofPoint pA, ofPoint pB, ofPoint pC, ofPoint pD, int r, int g, int b);
    
    ofPoint updateKalman(int id, ofPoint tp);
    void clearKalman(int id);
    void updateKalmanSettings(int id, ofPoint tp);
    
    void getTemplateAdjustment(ofPoint c0,ofPoint c1,ofPoint c2,ofPoint mainC);
    bool loadTemplatePoints();
    void saveTemplatePoints();
    float computeSkeletonCost(cv::Mat img, vector <ofPoint> checkPoints, ofMatrix4x4 possibleMatrix);
    
    void getSerialDevice();
    void serialSending();
    
    
    void drawScene(int iCameraDraw);
    void saveFramePositions();
    //kinect
    void updateFrame();
    
    ofxKinect kinect;
    
    int nearThreshold, farThreshold;
    int old_nearThreshold, old_farThreshold;
    
    int minCropX,minCropY,maxCropX, maxCropY;
    
    int kinectWidth, kinectHeight;
    
    int nearThresholdRange, farThresholdRange;
    
    cv::Mat grayThreshNearMat;
    cv::Mat grayThreshFarMat;
    cv::Mat grayThresh;
    
    Mat sourceMat;
    cv::Mat binaryMat; // the near thresholded image
    cv::Mat colorMat;
    cv::Mat depthMat;
    cv::Mat weighted_depthMat;
    Mat rgbMat;
    
    cv::Mat skel;
    
    ofPoint sceneCenter;
    ofPoint position;
    
    //---------3d camera
    ofxGrabCam camEasyCam;
    ofCamera fixedCam;
    OrthoCamera				camFront;
    OrthoCamera				camTop;
    
    ofCamera* cameras[N_CAMERAS];
    int	iMainCamera;;
    
    ofMatrix4x4 defaultPosition;
    ofMatrix4x4 topPosition;
    void camLoadPos();
    void camSavePos();
    void camLoadTopPos();
    //void camSaveTopPos();
    
    bool bCamLoadPos,bCamSavePos;
    //bool bCamLoadTopPos,bCamSaveTopPos;
    
    bool bCamReset;
    
    bool bUseMouse, old_bUseMouse;
    float cam_tilt, cam_roll, cam_pan, cam_rotX, cam_rotY, cam_rotZ;
    float old_cam_tilt;
    ofPoint camPos;
    
    int camFarClip,old_camFarClip;
    
    bool bSetCamToAnchor;
    
    
    ofMesh cloudMesh;
    
    
    //opencv tracking
    
    void computeParticuleProbabilities(CvConDensation* condDens,cv::Mat img, cv::Mat info, ofMatrix4x4 ref_condensMatrix );
    
    //void computeParticuleProbabilities(CvConDensation* condDens,cv::Mat img, cv::Mat info, ofPoint refPt_A,ofPoint refPt_B,ofPoint refPt_C,ofPoint refPt_D );
    float computeLineCost(cv::Mat img, ofPoint pt1, ofPoint pt2);
    void initCondens();
    void initAgain();
    void setRefPointsAgain();
    
    
    float distanceFromLine(ofPoint p,ofPoint l1,ofPoint l2);
    //ofPoint calcAverage(ofPoint tempVector[100]); //vector <ofPoint> tempVector);
    
    //ofPoint calcAverage(ofPoint tempVector[100], int arraySize);
    bool checkBounds(ofPoint pt);
    
    int binaryBlur;
    int conBlur;
    bool flipHori, flipVerti;
    int erosion_size,dilation_size;
    
    ofxCv::ContourFinder contourFinder;
    ofxCv::ContourFinder contourFinderConvex;
    ofxCv::ContourFinder contourFinderGreyThresh;
    
    //float contourThreshold;
    
    ofPolyline minAreRect;
    ofPolyline convexHull;
    ofPoint convexPoints[3];
    ofPoint center, centroid;
    float averageZ;
    
    int convexLast2Labels[3];
    int pointA_centroidIndex,pointB_centroidIndex,pointC_centroidIndex;
    int pointA_centroidLabel,pointB_centroidLabel,pointC_centroidLabel;
    unsigned long lastLabelChangeTimer;
    
    bool convexLabelChange;
    
    ofPoint pointA,pointB,pointC,pointD;
    float collect_diameter;
    ofVec3f diamPointA,old_diamPointA;
    ofVec3f diamPointB,old_diamPointB;
    ofVec3f diamPointC,old_diamPointC;
    ofVec3f diamPointD,old_diamPointD;
    
    
    vector<ofPoint> probableCondensD;
    int probableCondensD_cnt;
    
    float aveProb;
    float aveProbVec[100];
    int aveProbVec_cnt;
    unsigned long initPhaseTimer;
    
    
    cv::Mat MatWithInfo;
    ofPoint filteredPointA2, filteredPointB2, filteredPointC2, filteredPointD2;
    bool bUseOutsideNewFrame;
    float min_dist;
    
    ofPoint filteredPointA, filteredPointB, filteredPointC, filteredPointD;
    ofPoint old_filteredPointA, old_filteredPointB, old_filteredPointC, old_filteredPointD;
    //ofPoint condensPointA, condensPointB, condensPointC, condensPointD;
    
    cv::Mat dstMat;
    //int condensDim;
    
    //	CvMat lowerBound;
    //	CvMat upperBound;
    //CvConDensation* conDens;
    float totalValue;
    int SamplesNum;
    
    float resetProbAverage;
    int resetProbAverageTime;
    //	unsigned long condensDistTimer;
    int diamaterToTemplateDist;
    //	float distRawA_condensA,distRawB_condensB,distRawC_condensC;
    //unsigned char rr,bb,gg;
    
    unsigned long diameterDistTimer;
    
    bool bShowGui;
    bool bShowTracking;
    bool bShowVideo;
    bool bShowPointcloud;
    bool bShowModel;
    
    int old_loaderFameNum;
    
    bool updateData;
    
    //model
    ofxAssimpModelLoader model;
    
    ofVboMesh modelMesh;
    
    float normScale;
    ofPoint modelScale;
    float modelScaleOffset;
    
    //int vCnt;
    int anchorIndex;
    
    int angleXOffset;
    int angleYOffset;
    int angleZOffset;
    float treeRoll, treeTilt;
    
    ofPoint offsetP;
    
    int modelAlpha, wireAlpha;
    //unsigned long doubleClickTimer;
    //int clickCnt;
    
    
    //int sepiaDepth,sepiaIntensity;
    
    bool bDimming;
    //int dimmingMin, dimmingMax;
    float luminanceOffset;
    cv::Scalar rgbMean;
    float generalLuminance,old_generalLuminance;
    float luminanceSmooth;
    
    float ecoModeTimer, normalModeTimer;
    bool ecoMode_inUse;
    bool bAllowEcoMode;
    
    //screen frame
    ofImage frameImage;
    
    myPolygon** thePolygons;
    int nPolygons;
    //ofPoint leftTop,rightTop,rightBottom,leftBottom;
    ofPoint cornerPoints[4];
    
    //	bool bChangeScreenFrame;
    int frameType;
    //int frameWidth;
    int borderWidth;
    bool bUseGradient, old_bUseGradient;
    
    //condensation
    //	bool bUseCondensation;
    //	bool condensationActive;
    //	unsigned long useCondensationTime, notUsedCondensationTime;
    //	int useCondTimer, notUseCondTimer;
    //
    //	float minDistToCondens;
    bool bDistSmall;
    float distA_oldA;
    unsigned long movesSlowTimer;
    
    float initStartTime;
    bool bStartupMode;
    bool bExit;
    bool bRestart;
    //	bool bFlipBranch;
    
    
    
    bool bUseRaw;
    float dist01, dist12, dist20;
    
    float smoothValue;
    float smoothXValue;
    float smoothYValue;
    
    int maxZdistJump;
    float smoothZvalue;
    cv::Mat convexPointMat;
    
    
    int zMin, zMax;
    
    //------------------kalman
    ofxCvKalman *kalmanPointSmoothed[16];
    
    void setupKalman();
    
    cv::KalmanFilter KF;
    //	Mat_<float> state;
    Mat processNoise;
    cv::Mat_<float> measurement;
    
    cv::KalmanFilter KF2;
    //	Mat_<float> state2;
    //	Mat processNoise2;
    cv::Mat_<float> measurement2;
    
    
    float kalmanAngle, old_kalmanAngle;
    ofPoint pKalmanA, pKalmanB,pKalmanC;
    float kalman_smoothedAngle;
    float initKalmanTimer;
    bool bInitKalmanDone;
    
    bool bNewKalmanSetting;
    float kalmanProcess, kalmanMeasurement;
    float kalmanProcess2, kalmanMeasurement2;
    bool bUseKalman; //,bUseKalman2;
    
    ofMatrix4x4 oldPt_mR;
    //  float kalman_smoothedAngle;
    
    float rawAngle,rawAngleDiff;
    float rawTilt,rawTiltDiff;
    float rawRoll,rawRollDiff;
    float tiltAmplify,rollAmplify;
    
    float smoothKalmanAngle;
    float smoothKalmanPoint;
    ofPoint pSmoothedA,pSmoothedB,pSmoothedC,pSmoothedD;
    
    ofTrueTypeFont	arial;
    
    unsigned long lastTap;
    int branchABlength;
    
    ofMatrix4x4 rotationMatrixFinalZ;
    ofMatrix4x4 translationMatrixFinal;
    ofMatrix4x4 combinedMatrixFinal;
    ofMatrix4x4 mT0Final;
    ofMatrix4x4 mT1Final;
    ofMatrix4x4 mTzeroFinal;
    
    //template
    //ofMatrix4x4 condensMatrix;
    ofMatrix4x4 template_mR;
    ofMatrix4x4 templAdjust_mC;
    vector <ofPoint> templPoints;
    vector <ofPoint> skelPoints;
    ofPoint templPointA,templPointB,templPointC,templPointD;
    float lengthAD,lengthBD,lengthCD;
    // float templAngleAB,templAngleAC;
    float angAB_offset,angAC_offset;
    
    bool bDebug;
    bool bShowSkeleton;
    bool bShowTemplate;
    bool bTakeTemplate;
    bool bGotTemplate;
    bool bTakeTemplateABCD;
    int templ_pressedCnt;
    bool bFindPos;
    int templateState;
    
    int blobX,blobY,blobWidth, blobHeight;
    
    int rangeMargin;
    
    //bool bUseHistogram;
    
    //	cv::Mat HistogramTemplateMat;
    //	cv::Mat HistogramTemplateMask;
    //	contentFinder finder;
    //	colorHistogram hc;
    //	cv::MatND hist;
    //	cv::Mat histResultMask;
    //	bool takeNewHistogramTemplate;
    //	bool gotHistogramTemplate;
    //
    //	float minHistTresh,maxHist;
    
    int initStage;
    
    //serial
    bool serialActive;
    int myBaud;
    string serialID;
    ofSerial	serial;
    unsigned long lastSendTime;
    bool bSerialConnected;
    int serialSendPause;
    vector <string> serialMessages;
    
    float xyMotionScaler;
    //  ofPoint pendulumAnchor;
    float tiltAccum[AVG_AMT];
    float rollAccum[AVG_AMT];
    int tiltAvgCnt;
    int rollAvgCnt;
    float tiltAvg;
    float rollAvg;
    
    ofPoint accumDdiff;
    
    bool bDebugTimer;
    unsigned long debugTimer,debugDrawTimer;
    
    //  ofxBlur blurStage;
    //    ofPoint myFramePoints_a[4];
    //    ofPoint myFramePoints_b[4];
    //    ofPoint myFramePoints_c[4];
    //    ofPoint myFramePoints_d[4];
    bool bEditFrame;
    bool bResetFrame;
    int frameCornerCnt;
		
};
