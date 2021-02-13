//
//  pad.cpp
//  smalldrum
//
//  Created by Mac on 10/16/20.
//

#include "pad.hpp"
pad::pad(){
    
}
void pad::setup(){
    
      c1 = 10;
    
    radiusM=200;
    radiusP=200;
    //com=true;
    value = false;
    xMax = xPos+120;
    bMax = base+120;
    
    

    
    
}
void pad::update(){

 
    
    
    
}

void pad::draw(){
  // ofDrawBitmapString("on", xPos-10, base-40);
   ofFill();
   c1--;
  // dist = ofDist(xPos, base, ofGetMouseX(), ofGetMouseY());
    
 
    //( = ! )//
    //   &  //
    // <--> //
    //  ?   //
   
    
    if(ofGetMousePressed()==true){
       
        
        if(ofGetMouseX()>xPos && ofGetMouseX()<xPos+xMax && ofGetMouseY()>base && ofGetMouseY()< base + bMax){
            if(c1<0){
            value=true;
            cout << "printing"<<endl;
            cout << value <<endl;
            c1 = 10;
           
            }}

    } else {value=false;}
      
   
    
    if (value == true){
           ofPushMatrix();
           ofSetColor(4, 228, 165);
           ofDrawRectRounded(xPos, base, xMax, bMax, 9);
        
           ofPopMatrix();
           
           
    }
       
       if (value == false){
           
           ofPushMatrix();
           ofSetColor(0);
           ofDrawRectRounded(xPos, base, xMax, bMax, 9);
         //  ofDrawBitmapString("off", xPos-10, base-20);
           ofPopMatrix();
             
    }
    
    
  
   
   
   


}


