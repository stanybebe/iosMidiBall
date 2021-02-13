//
//  ballBox.cpp
//  iosMIDIball
//
//  Created by Mac on 2/7/21.
//
#include "ballBox.h"
#include <stdio.h>

ballBox::ballBox(){
    
}
void ballBox::setup(){
    r = m * 8;
   
    pos.set(x,y);
    vel.set(0,0);
    acc.set(0,0);
    r= 20;
    
    boxHmax = boxH + 200;
    boxWmax = boxW + 200;
    
    
}

void ballBox::applyForce(ofVec2f force){
   
    auto f = force/m;
    acc = acc + f;

}

void ballBox::update(){
    
  
      vel = vel + acc;
      pos = pos + vel;
      acc = acc * 0;
    
    
    
}

void ballBox::draw(){
       
     
    
       ofPushMatrix();
       ofSetColor(0);
      
       ofDrawRectangle(boxW, boxH, boxWmax, boxHmax);
       ofPopMatrix();

     
       ofPushMatrix();
       ofSetColor(4, 228, 165);
       ofDrawCircle(pos.x,pos.y, r);
       ofPopMatrix();
    
    
       if (pos.x > boxWmax ) {
         pos.x = boxWmax;
         vel.x *= -1;
       } else if (pos.x < boxW ) {
         pos.x = boxW;
         vel.x *= -1;
        
       }
       if (pos.y > boxHmax ) {
         pos.y = boxHmax;
         vel.y *= -1;
         
       } else if (pos.y < boxH ) {
       vel.y *= -1;
       pos.y = boxH;
       }
     
    
    
 


}
