
#pragma once

#include "ofMain.h"
#include "ofxMidi.h"
#include "ofxPd.h"
#include "Slider.h"
#include "toggle.h"
#include "knob.h"
#include "xy.h"
#include "pad.hpp"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ballBox.h"

#include <deque>
// a namespace for the Pd types
using namespace pd;

// inherit pd receivers to receive message and midi events
class ofApp :  public ofxiOSApp, public PdReceiver, public PdMidiReceiver, public ofxMidiListener, public ofxMidiConnectionListener{

    public:

        // main
        void setup();
        void update();
        void draw();
        void exit();

        // do something
        void playTone(int pitch);
        
        // input callbacks
        void keyPressed(int key);
        
        // audio callbacks
        void audioReceived(float * input, int bufferSize, int nChannels);
        void audioRequested(float * output, int bufferSize, int nChannels);
        
        // pd message receiver callbacks
        void print(const std::string& message);
        
        void receiveBang(const std::string& dest);
        void receiveFloat(const std::string& dest, float value);
        void receiveSymbol(const std::string& dest, const std::string& symbol);
        void receiveList(const std::string& dest, const List& list);
        void receiveMessage(const std::string& dest, const std::string& msg, const List& list);
        
        // pd midi receiver callbacks
        void receiveNoteOn(const int channel, const int pitch, const int velocity);
        void receiveControlChange(const int channel, const int controller, const int value);
        void receiveProgramChange(const int channel, const int value);
        void receivePitchBend(const int channel, const int value);
        void receiveAftertouch(const int channel, const int value);
        void receivePolyAftertouch(const int channel, const int pitch, const int value);
      
        void receiveMidiByte(const int port, const int byte);
        
        void midiOutputAdded(string nam, bool isNetwork);
        void midiOutputRemoved(string name, bool isNetwork);
        void addMessage(string msg);
        void newMidiMessage(ofxMidiMessage& msg);
        
        ofxPd pd;
        vector<float> scopeArray;
        vector<Patch> instances;
        vector<float> array1, array2;
        
        int midiChan;
        float t, val, size;
        int c, c2, c3, c4;
   
        int channel;
        
        int note, noteB, chan,vel, p;
        bool yep, yep2;
        
       
        vector<ofxMidiOut*> outputs;
        deque<string> messages;
        int maxMessages;
        ofMutex messageMutex; // make sure we don't read from queue while writing

     
       
        
        vector<unsigned char> bytes;
        
       
        Slider sliderA, sliderB, sliderC, sliderD, sliderE, sliderF, sliderG, sliderH;
        toggle toggleA;
        knob knobA, knobB;
        xy xyA;
        ofVec2f grav;
        ofVec2f gravA;
        ofVec2f wind;
        ballBox bb;
       

        pad padA,padB,padC,padD,padE,padF,padG;
        
        
    
    
};



