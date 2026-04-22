//
//  MyGuiView.h
//  iPhone Empty Example
//
//  Created by theo on 26/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "testApp.h"

@interface MyGuiView : UIViewController {
	IBOutlet UILabel *displayVersionText;
	IBOutlet UILabel *displayLanguageText;
	IBOutlet UILabel *displayNorthText;
	IBOutlet UILabel *displayDefaultPosText;
	
	testApp *myApp;		// points to our instance of testApp
}

-(void)setVersionStatusString:(NSString *)trackStr;
-(void)setLanguageStatusString:(NSString *)trackStr;
-(void)setNorthStatusString:(NSString *)trackStr;
-(void)setDefaultPosStatusString:(NSString *)trackStr;

-(IBAction)LanguageMore:(id)sender;
-(IBAction)LanguageLess:(id)sender;

-(IBAction)NorthMore:(id)sender;
-(IBAction)NorthLess:(id)sender;

-(IBAction)DefaultPosMore:(id)sender;
-(IBAction)DefaultPosLess:(id)sender;

-(IBAction)hide:(id)sender;
-(IBAction)adminSwitch:(id)sender;
@end
