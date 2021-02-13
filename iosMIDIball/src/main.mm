
#include "ofMain.h"
#include "ofxPd.h"
#include "ofApp.h"
#include "Slider.h"
#include "toggle.h"
#include "xy.h"
#include "ofxMidi.h"





int main( ){
    ofSetupOpenGL(1024,768,OF_WINDOW);            // <-------- setup the GL context

    // this kicks off the running of my app
    // can be OF_WINDOW or OF_FULLSCREEN
    // pass in width and height too:
    ofRunApp(new ofApp());

}




