//
//  ballBox.h
//  iosMIDIball
//
//  Created by Mac on 2/7/21.
//

#ifndef ballBox_h
#define ballBox_h

#include "ofMain.h"
#endif /* ballBox_h */

class ballBox : public ofBaseApp {
    
    public:
    void setup();
    void applyForce(ofVec2f force);
    void update();
    void draw();
    float x,y,m, r;
    
    
    float boxW, boxH, boxWmax, boxHmax;
    
    
    ofVec2f pos;
    
    
    ofVec2f vel;
    
    
    ofVec2f acc;
    
    ofVec2f f;
    
    
    ballBox();
    
    
    
    
    
    
    
};
