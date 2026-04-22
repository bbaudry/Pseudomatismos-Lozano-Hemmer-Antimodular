
#include "ofMain.h"
#include "testApp.h"


int main(){
	ofSetupOpenGL(720,480, OF_FULLSCREEN);			// <-------- setup the GL context

	ofRunApp(new testApp);
}
