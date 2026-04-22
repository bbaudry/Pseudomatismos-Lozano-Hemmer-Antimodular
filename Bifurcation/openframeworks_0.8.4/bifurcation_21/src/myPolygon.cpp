/*
 *  myPolygon.cpp
 *  seismoscope_1
 *
 *  Created by birnam on 28/10/09.
 *  Copyright 2009 antimodular research inc.. All rights reserved.
 *
 */

#include "myPolygon.h"

myPolygon::myPolygon(ofPoint * iPoints, int iBlendSide)
{

//	myPolygon_Font.loadFont(ofToDataPath("Arial.ttf"),12, false, true);
	
	blendSide = iBlendSide;
	
	highlightColor.set(255,0,0,255); // 0xFF0000;
	normalColor.set(0,0,0,255); //0xFFFFFF;
	polygonColor.set(0,0,0,255); ///0xFFFFFF;
	
	for(int i=0; i<4;i++){
		myPoints[i] = iPoints[i];
		curveVertices[i].x = myPoints[i].x;
		curveVertices[i].y = myPoints[i].y;
	}
	
	nCurveVertexes = 4;
	for (int i = 0; i < nCurveVertexes; i++){
		curveVertices[i].bOver 			= false;
		curveVertices[i].bBeingDragged 	= false;
		curveVertices[i].radius = 15;
	}
	
	isActive = false;
	borderWidth = 15;
	

}

void myPolygon::update() 
{
}

bool myPolygon::over()
{
	//if(overRect(x, y, buttonWidth, buttonHeight)) {
//		isOver = true;
//		return true;
//	} else {
//		isOver = false;
//		return false;
//	}
	
	if(insidePolygon(mouseX, mouseY, curveVertices)) {
        cout<<"insidePolygon "<<endl;
		isOver = true;
		return true;
	} else {
		isOver = false;
		return false;
	}
}

bool myPolygon::insidePolygon(float x, float y, draggableVertex *p){
	
	int i, j, c = 0;
	int pLength = 4;

	for (i = 0, j = pLength-1; i < pLength; j = i++) {
		if ((((p[i].y <= y) && (y < p[j].y)) || ((p[j].y <= y) && (y < p[i].y))) && (x < (p[j].x - p[i].x) * (y - p[i].y) / (p[j].y - p[i].y) + p[i].x)){
			c = (c+1) % 2;
		}
	}
	cout<<"insidePolygon "<<c<<endl;
	return c==1;
}

bool myPolygon::overRect(int x, int y, int width, int height)
{
	if (mouseX >= x && mouseX <= x+width && 
		mouseY >= y && mouseY <= y+height) {
		return true;
	} else {
		return false;
	}
}


void myPolygon::release()
{
	//isActive = false;
//	myValue = 0;
}

void myPolygon::draw() 
{
	
	char Str[255];

	//new
	ofEnableAlphaBlending();
	ofFill();
	
	if(isActive) polygonColor = highlightColor;
	else polygonColor = normalColor;
	
	float y01_diff =  curveVertices[1].y - curveVertices[0].y; //height diff between top points
	float x01_width = curveVertices[1].x - curveVertices[0].x; //width of top
	float y32_diff =  curveVertices[2].y - curveVertices[3].y; //height diff between top points
	float x32_width = curveVertices[2].x - curveVertices[3].x; //width of top
	
	float x30_diff = curveVertices[3].x - curveVertices[0].x;
	float x30_height = curveVertices[3].y - curveVertices[0].y;
	
	float x21_diff = curveVertices[2].x - curveVertices[1].x;
	float x21_height = curveVertices[2].y - curveVertices[1].y;

	
	
	float top_diff = borderWidth * y01_diff / x01_width;
	float bottom_diff = borderWidth * y32_diff / x32_width;
	float left_diff = borderWidth * x30_diff / x30_height;
	float right_diff = borderWidth * x21_diff / x21_height;


	//top of quad has gradient
	if(blendSide == 0){
		//edge polygon
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x+left_diff-1, curveVertices[0].y+borderWidth);
		glVertex2f(curveVertices[1].x+right_diff+1, curveVertices[1].y+borderWidth);
		glVertex2f(curveVertices[2].x, curveVertices[2].y);
		glVertex2f(curveVertices[3].x, curveVertices[3].y);
		glEnd();
		
		//top polygon gradient
		glBegin(GL_POLYGON);
		if(bUseGradient) ofSetColor(0,0,0,0);
        else ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x-1, curveVertices[0].y);
		glVertex2f(curveVertices[1].x+1, curveVertices[1].y);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[1].x+right_diff+1, curveVertices[1].y + borderWidth);
		glVertex2f(curveVertices[0].x+left_diff-1, curveVertices[0].y + borderWidth);
		glEnd();
		
	}
	//right of quad has gradient
	if(blendSide == 1){
		
		//edge polygon
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x, curveVertices[0].y);
		glVertex2f(curveVertices[1].x-borderWidth, curveVertices[1].y - top_diff);
		glVertex2f(curveVertices[2].x-borderWidth, curveVertices[2].y - bottom_diff);
		glVertex2f(curveVertices[3].x, curveVertices[3].y);
		glEnd();
		
		//right polygon gradient
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[1].x-borderWidth, curveVertices[1].y - top_diff);
        if(bUseGradient) ofSetColor(0,0,0,0);
        else ofSetColor(polygonColor);
		glVertex2f(curveVertices[1].x, curveVertices[1].y);
		glVertex2f(curveVertices[2].x, curveVertices[2].y);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[2].x-borderWidth, curveVertices[2].y - bottom_diff);
		glEnd();
		
	}

	//bottom of quad has gradient
	if(blendSide == 2){
		//edge polygon
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x, curveVertices[0].y);
		glVertex2f(curveVertices[1].x, curveVertices[1].y);
		glVertex2f(curveVertices[2].x-right_diff+1, curveVertices[2].y-borderWidth);
		glVertex2f(curveVertices[3].x-left_diff-1, curveVertices[3].y-borderWidth);
		glEnd();
		
		//top polygon gradient
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[3].x-left_diff-1, curveVertices[3].y-borderWidth);
		glVertex2f(curveVertices[2].x-right_diff+1, curveVertices[2].y-borderWidth);
        if(bUseGradient) ofSetColor(0,0,0,0);
        else ofSetColor(polygonColor);
		glVertex2f(curveVertices[2].x+1, curveVertices[2].y);
		glVertex2f(curveVertices[3].x-1, curveVertices[3].y);
		glEnd();
		
	}
	//left of quad has gradient
	if(blendSide == 3){
		//edge polygon
		glBegin(GL_POLYGON);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x+borderWidth, curveVertices[0].y + top_diff);
		glVertex2f(curveVertices[1].x, curveVertices[1].y);
		glVertex2f(curveVertices[2].x, curveVertices[2].y);
		glVertex2f(curveVertices[3].x+borderWidth, curveVertices[3].y + bottom_diff);
		glEnd();
		
		//left polygon gradient
		glBegin(GL_POLYGON);
        if(bUseGradient) ofSetColor(0,0,0,0);
        else ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x, curveVertices[0].y);
		ofSetColor(polygonColor);
		glVertex2f(curveVertices[0].x+borderWidth, curveVertices[0].y + top_diff);
		glVertex2f(curveVertices[3].x+borderWidth, curveVertices[3].y + bottom_diff);
        if(bUseGradient) ofSetColor(0,0,0,0);
        else ofSetColor(polygonColor);
		glVertex2f(curveVertices[3].x, curveVertices[3].y);
		glEnd();
		
	}

	
	
	
	//draw handles
//	char Str[255];
	
	if(isActive){
		ofSetColor(0,0,255);
		for (int i = 0; i < nCurveVertexes; i++){
			if (curveVertices[i].bOver == true) ofFill();
			else ofNoFill();
			ofCircle(curveVertices[i].x, curveVertices[i].y,curveVertices[i].radius);
			
			//ofDrawBitmapString("(f) ofCurveVertex\nuses catmull rom\nto make curved shapes", 220,410);
			sprintf(Str, "%i", i);
			ofDrawBitmapString(Str,curveVertices[i].x, curveVertices[i].y);
			
		}
	}
	ofDisableAlphaBlending();
	
}


//	}


//------------- -------------------------------------------------
void myPolygon::mouseMoved(int x, int y ){
	//printf("mouseMoved");
	
	if(isActive){
		for (int i = 0; i < nCurveVertexes; i++){
			float diffx = x - curveVertices[i].x;
			float diffy = y - curveVertices[i].y;
			float dist = sqrt(diffx*diffx + diffy*diffy);
			if (dist < curveVertices[i].radius){
				curveVertices[i].bOver = true;
			} else {
				curveVertices[i].bOver = false;
			}	
		}
	}
	mouseX = x;
	mouseY = y;
}

//--------------------------------------------------------------
void myPolygon::mouseDragged(int x, int y, int button){
	
	if(isActive){
		for (int i = 0; i < nCurveVertexes; i++){
			if (curveVertices[i].bBeingDragged == true){
				if(x>0 && x<ofGetWidth()) curveVertices[i].x = x;
				if(y>0 && y<ofGetHeight()) curveVertices[i].y = y;
			}
		}
	}
}

//--------------------------------------------------------------
void myPolygon::mousePressed(int x, int y, int button){
	//printf("mousePressed");
	
	mouseX = x;
	mouseY = y;
	
	mouseIsPressed = true;
	
	if(isActive){
		for (int i = 0; i < nCurveVertexes; i++){
			float diffx = x - curveVertices[i].x;
			float diffy = y - curveVertices[i].y;
			float dist = sqrt(diffx*diffx + diffy*diffy);
			if (dist < curveVertices[i].radius){
				curveVertices[i].bBeingDragged = true;
			} else {
				curveVertices[i].bBeingDragged = false;
			}	
		}
		
	}
	
	if(over()){
		printf(" over ");
		if(ofGetElapsedTimeMillis()-prevClickTime<300){
			isActive =! isActive;
			printf(" \n double clicked \n");
		}
		prevClickTime = ofGetElapsedTimeMillis();
	}
}

//--------------------------------------------------------------
void myPolygon::mouseReleased(int x, int y, int button){
	
	mouseIsPressed = false;
	
	if(isActive){
		for (int i = 0; i < nCurveVertexes; i++){
			curveVertices[i].bBeingDragged = false;	
		}
	}
}

