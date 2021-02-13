//
//  pad.hpp
//  smalldrum
//
//  Created by Mac on 10/16/20.
//

#ifndef pad_hpp
#define pad_hpp

#include <stdio.h>
#include "ofMain.h"
class pad : public ofBaseApp {
    public:
    void setup();
    void update();
    void draw();
    bool com;
    int xPos;
    int base;
    int xMax;
    int bMax;
    bool value;
    int radiusM;
    int radiusP;
    double dist;
    int c1;
    
    pad();
    
    int shp;
    
    
   
    
  
    
};


#endif /* pad_hpp */
