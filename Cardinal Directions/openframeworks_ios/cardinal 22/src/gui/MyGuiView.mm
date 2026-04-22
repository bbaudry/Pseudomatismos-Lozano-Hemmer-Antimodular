//
//  MyGuiView.m
//  iPhone Empty Example
//
//  Created by theo on 26/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyGuiView.h"
#include "ofxiPhoneExtras.h"


@implementation MyGuiView

// called automatically after the view is loaded, can be treated like the constructor or setup() of this class
-(void)viewDidLoad {
	myApp = (testApp*)ofGetAppPtr();

	self.view.hidden = YES;
	
	string statusStr = myApp->appVersion;
	[self setVersionStatusString:ofxStringToNSString(statusStr)];	
	
	statusStr = " Status: Language is " + myApp->languageNames[myApp->language-1];
	[self setLanguageStatusString:ofxStringToNSString(statusStr)];
	
	statusStr = " Status: North is " + ofToString(myApp->northDegree, 0) + " degrees";
	[self setNorthStatusString:ofxStringToNSString(statusStr)];		
	
	statusStr = " Status: Default Position is " + ofToString(myApp->defaultDegree,0) + " degrees";
	[self setDefaultPosStatusString:ofxStringToNSString(statusStr)];
}

//----------------------------------------------------------------
-(void)setVersionStatusString:(NSString *)trackStr{
	displayVersionText.text = trackStr;
}
-(void)setLanguageStatusString:(NSString *)trackStr{
	displayLanguageText.text = trackStr;
}
-(void)setNorthStatusString:(NSString *)trackStr{
	displayNorthText.text = trackStr;
}
-(void)setDefaultPosStatusString:(NSString *)trackStr{
	displayDefaultPosText.text = trackStr;
}

//-------------LANGUAGE---------------------------------------------------
-(IBAction)LanguageMore:(id)sender{
	myApp->language += 1;
	if( myApp->language > 4 ){
		myApp->language = 1;
	}
	
	string statusStr = " Status: Language is " + myApp->languageNames[myApp->language-1];
	[self setLanguageStatusString:ofxStringToNSString(statusStr)];		
}

/*
//----------------------------------------------------------------
-(IBAction)LanguageLess:(id)sender{
	myApp->language -= 1;
	if( myApp->language < 1 ){
		myApp->language = 1;
	}

	string statusStr = " Status: Language is " + myApp->languageNames[myApp->language-1];
	[self setLanguageStatusString:ofxStringToNSString(statusStr)];		
}
*/

//------------NORTH----------------------------------------------------
-(IBAction)NorthMore:(id)sender{
	myApp->northDegree -= 10;
	if( myApp->northDegree < 0 ){
		myApp->northDegree = 359;
	}
	
	string statusStr = " Status: North is " + ofToString(myApp->northDegree, 0) + " degrees";
	[self setNorthStatusString:ofxStringToNSString(statusStr)];		
	
	myApp->panelSwitch2();
}

/*
//----------------------------------------------------------------
-(IBAction)NorthLess:(id)sender{
	myApp->northDegree -= 10;
	if( myApp->northDegree < 0 ){
		myApp->northDegree = 359;
	}
	
	string statusStr = " Status: North is " + ofToString(myApp->northDegree,0);
	[self setNorthStatusString:ofxStringToNSString(statusStr)];	
	myApp->panelSwitch2();
}
*/

//-------------DEFAULTPOS---------------------------------------------------
-(IBAction)DefaultPosMore:(id)sender{
	myApp->defaultDegree -= 10;
	if( myApp->defaultDegree < 0 ){
		myApp->defaultDegree = 359;
	}
	
	string statusStr = " Status: Default Position is " + ofToString(myApp->defaultDegree,0) + " degrees";
	[self setDefaultPosStatusString:ofxStringToNSString(statusStr)];	
	
	myApp->panelSwitch3();
}

/*
//----------------------------------------------------------------
-(IBAction)DefaultPosLess:(id)sender{
	myApp->defaultDegree -= 10;
	if( myApp->defaultDegree < 0 ){
		myApp->defaultDegree = 359;
	}
	
	string statusStr = " Status: Default Position is " + ofToString(myApp->defaultDegree,0);
	[self setDefaultPosStatusString:ofxStringToNSString(statusStr)];
	myApp->panelSwitch3();
}
*/

//----------------------------------------------------------------
-(IBAction)hide:(id)sender{
	self.view.hidden = YES;
	myApp->saveSettings = true;
	myApp->showGui = false;
	//myApp->panelSwitch4isOn = false;
}
//----------------------------------------------------------------
-(IBAction)adminSwitch:(id)sender{
	
	UISwitch * toggle = sender;
	printf("switch value is - %i\n", [toggle isOn]);
	
	myApp->showAdmin = [toggle isOn];
	
	//string statusStr = " Status: fill is " + ofToString(myApp->bFill);
	//[self setStatusString:ofxStringToNSString(statusStr)];	
}

@end
