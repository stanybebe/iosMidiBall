#include <stdio.h>



#include "xy.h"
xy::xy(){
    
}
void xy::setup(int xPosIn, int baseIn){
    
    c1 = 5;
    rot= 50;
    radiusM=8;
    radiusP=20;
    //com=true;
    
 
    xMax = xPos+520;
    bMax = base+520;
    
    pX = xPosIn + 60;
    pY = baseIn + 60;
    

    
    
}
void xy::update(){

 
    
    
    
}

void xy::draw(int xPosIn, int baseIn, int rangex, int rangey){
   
   xPos=xPosIn;
   base =baseIn;
    
    //( = ! )//
    //   &  //
    // <--> //
    //  ?   //
   
    
    if(ofGetMousePressed()==true){
       
        if(ofGetMouseX()>xPos && ofGetMouseX()<xPos+xMax && ofGetMouseY()>base && ofGetMouseY()< base + bMax){

            pX =ofGetMouseX();
            pY =ofGetMouseY();

            valueX = floor(ofMap(pX,xPos,xPos+xMax, 0, rangex));
            valueY = floor(ofMap(pY,base,base+bMax, 0, rangey));
            
         
            
            cout << "printing"<<endl;
            cout << valueX  << "xpos" <<endl;
   
           
            }
    }
    
   
    ofPushMatrix();
    ofFill();
    ofTranslate(xPos, base);
       ofSetColor(4, 228, 165);
    //ofRectMode(OF_RECTMODE_CORNER);
    ofDrawRectangle(0+(xMax/2), 0+(bMax/2), xMax , bMax );
    
    ofSetColor(0);
    
    ofDrawRectangle(0+(xMax/2), 0+(bMax/2),1,bMax);
    ofDrawRectangle(0+(xMax/2), 0+(bMax/2),xMax,1);
    
   
    
    cout << posX <<endl;
    cout << posY <<endl;
    ofPopMatrix();
    
    
    ofPushMatrix();
    ofNoFill();
    ofTranslate(xPos, base);
       for (int i =0; i<5; i++){
           
           ofDrawRectangle(0+(xMax/2), 0+(bMax/2), xMax-(i*(valueX*.2)) , bMax-(i*(valueY*.2)));
       }
    ofPopMatrix();
    ofFill();
    ofDrawRectangle(pX,pY, 30, 30);
    
    


    
  
    
    ofDrawBitmapString(valueX, xPos-10, base-5);
    ofDrawBitmapString(valueY, xPos+ 116, base+130);
      
}
