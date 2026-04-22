/*
 *  myPolygon.h
 *  seismoscope_1
 *
 *  Created by birnam on 28/10/09.
 *  Copyright 2009 antimodular research inc.. All rights reserved.
 *
 */

#pragma once

#include <iostream>

#include "ofMain.h"

//class TouchableObject : public ofxMultiTouchListener

typedef struct {
	
	float 	x;
	float 	y;
	bool 	bBeingDragged;
	bool 	bOver;
	float 	radius;
	
}	draggableVertex;

class myPolygon {
	
public:
	

	//constructor
	myPolygon(ofPoint * iPoints, int iBlendSide);
	
	
	//methodes
	//void setup();
	void update();
	bool over();
	void press();
	void release();
	void draw();
	void mouseMoved(int x, int y );
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	
	bool isOver;
	bool mouseIsPressed;
	
	int mouseX, mouseY;
	bool myValue;
	
	
	int nCurveVertexes;
	draggableVertex curveVertices[4];
	draggableVertex bezierVertices[4];
	ofPoint myPoints[4];
	
	int prevClickTime;
//	int polygonColor, normalColor, highlightColor;
	ofColor polygonColor, normalColor, highlightColor; 
	bool isActive;
	float borderWidth;
	
	int blendSide;
	
    bool bUseGradient;
private:
	//void mouseDragged(int x, int y, int button);
	//	void mousePressed(int x, int y, int button);
	//	//void mouseReleased();
	//	void mouseReleased(int x, int y, int button );
	//	void touchDown(float x, float y, int touchId, ofxMultiTouchCustomData *data = NULL);
	//	void touchMoved(float x, float y, int touchId, ofxMultiTouchCustomData *data = NULL);
	//	void touchUp(float x, float y, int touchId, ofxMultiTouchCustomData *data = NULL);
	//ofTrueTypeFont	myPolygon_Font;
	
	bool overRect(int x, int y, int width, int height); 
	bool insidePolygon(float x, float y, draggableVertex * p);
//	int lock(int val, int minv, int maxv);
	

	int IntOutValue;
	float FloatOutValue;
	int pressTimer;
	bool isPressed;
};


