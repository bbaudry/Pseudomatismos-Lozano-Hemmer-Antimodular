/*
 * ofxCvKalman.h
 *
 *  Created on: 23-jun-2009
 *      Author: art
 */


#include "ofMain.h"
#include "ofxOpenCv.h"

class ofxCvKalman {
public:
	ofxCvKalman(float initial);
	virtual ~ofxCvKalman();

	float correct(float nextPoint);
	void changeProcessAndMeasurementNoise(float value1,float value2, float initial);
	
	CvKalman * kalman;
	CvMat* state;
	CvMat* process_noise;
	CvMat* measurement;
	CvRandState rng;

};
