
#include "ofApp.h"
#include "ofMath.h"
#include "ofxMidi.h"
#include "ofxPd.h"




void ofApp::setup() {
    
    
    ofxMidiOut output;
    bb.setup();
    padA.setup();
    maxMessages = 28;
    messages.push_back("nothing yet ...");
    ofxiOSAlerts.addListener(this);
    note = -1;
   
    output.listOutPorts();
    ofxMidi::enableNetworking();
        // create and open output ports
    for(int i = 0; i < output.getNumOutPorts(); ++i) {
        
        // new object
        outputs.push_back(new ofxMidiOut);
        
        // open input port via port number
        outputs[i]->openPort(i);
    }
    
    // set this class to receieve midi device (dis)connection events
    ofxMidi::setConnectionListener(this);
    c2 = xyA.valueX;
    c3 = xyA.valueY;


    channel=1;

    ofSetVerticalSync(true);
    xyA.valueX= 100;
    xyA.valueY= 100;
    

    c=0;
    

   
    //ofSetLogLevel("Pd", OF_LOG_VERBOSE); // see verbose info inside

    // double check where we are ...
    cout << ofFilePath::getCurrentWorkingDirectory() << endl;

    // the number of libpd ticks per buffer,
    // used to compute the audio buffer len: tpb * blocksize (always 64)
    #ifdef TARGET_LINUX_ARM
        // longer latency for Raspberry PI
        int ticksPerBuffer = 32; // 32 * 64 = buffer len of 2048
        int numInputs = 0; // no built in mic
    #else
        int ticksPerBuffer = 8; // 8 * 64 = buffer len of 512
        int numInputs = 1;
    #endif

    // setup OF sound stream
    ofSoundStreamSettings settings;
    settings.numInputChannels = 2;
    settings.numOutputChannels = 2;
    settings.sampleRate = 44100;
    settings.bufferSize = ofxPd::blockSize() * ticksPerBuffer;
    settings.setInListener(this);
    settings.setOutListener(this);
    ofSoundStreamSetup(settings);

    // setup Pd
    //
    // set 4th arg to true for queued message passing using an internal ringbuffer,
    // this is useful if you need to control where and when the message callbacks
    // happen (ie. within a GUI thread)
    //
    // note: you won't see any message prints until update() is called since
    // the queued messages are processed there, this is normal
    //
    if(!pd.init(2, numInputs, 44100, ticksPerBuffer, false)) {
        OF_EXIT_APP(1);
    }

    midiChan = 1; // midi channels are 1-16

    // subscribe to receive source names
    pd.subscribe("toOF");
    pd.subscribe("env");

    // add message receiver, required if you want to recieve messages
    pd.addReceiver(*this); // automatically receives from all subscribed sources
    pd.ignoreSource(*this, "env");        // don't receive from "env"
    //pd.ignoreSource(*this);             // ignore all sources
    //pd.receiveSource(*this, "toOF");      // receive only from "toOF"

    // add midi receiver, required if you want to recieve midi messages
    pd.addMidiReceiver(*this); // automatically receives from all channels
    //pd.ignoreMidiChannel(*this, 1);     // ignore midi channel 1
    //pd.ignoreMidiChannel(*this);        // ignore all channels
    //pd.receiveMidiChannel(*this, 1);    // receive only from channel 1

    // add the data/pd folder to the search path
    pd.addToSearchPath("pd/abs");

    // audio processing on
    pd.start();

    // -----------------------------------------------------
    cout << endl << "BEGIN Patch Test" << endl;

    // open patch
    Patch patch = pd.openPatch("pd/seq4.pd");
    cout << patch << endl;

    // close patch
    pd.closePatch(patch);
    cout << patch << endl;

    // open patch again
    patch = pd.openPatch(patch);
    cout << patch << endl;
    
    cout << "FINISH Patch Test" << endl;


    cout << endl << "BEGIN Message Test" << endl;

    // test basic atoms
    pd.sendBang("fromOF");
    pd.sendFloat("fromOF", 100);
    pd.sendSymbol("fromOF", "test string");

    // stream interface
    pd << Bang("fromOF")
       << Float("fromOF", 100)
       << Symbol("fromOF", "test string");

    // send a list
    pd.startMessage();
    pd.addFloat(1.23);
    pd.addSymbol("a symbol");
    pd.finishList("fromOF");

    // send a message to the $0 receiver ie $0-fromOF
    pd.startMessage();
    pd.addFloat(1.23);
    pd.addSymbol("a symbol");
    pd.finishList(patch.dollarZeroStr()+"-fromOF");

    // send a list using the List object
    List testList;
    testList.addFloat(1.23);
    testList.addSymbol("sent from a List object");
    pd.sendList("fromOF", testList);
    pd.sendMessage("fromOF", "msg", testList);

    // stream interface for list
    pd << StartMessage() << 1.23 << "sent from a streamed list" << FinishList("fromOF");

    cout << "FINISH Message Test" << endl;

    // -----------------------------------------------------
    cout << endl << "BEGIN MIDI Test" << endl;

    // send functions
    pd.sendNoteOn(midiChan, 60);
    pd.sendControlChange(midiChan, 0, 64);
    pd.sendProgramChange(midiChan, 100);    // note: pgm num range is 1 - 128
    pd.sendPitchBend(midiChan, 2000);   // note: ofxPd uses -8192 - 8192 while [bendin] returns 0 - 16383,
                                        // so sending a val of 2000 gives 10192 in pd
    pd.sendAftertouch(midiChan, 100);
    pd.sendPolyAftertouch(midiChan, 64, 100);
    pd.sendMidiByte(0, 239);    // note: pd adds +2 to the port number from [midiin], [sysexin], & [realtimein]
    pd.sendSysex(0, 239);       // so sending to port 0 gives port 2 in pd
    pd.sendSysRealTime(0, 239);

//    // stream
//    pd << NoteOn(midiChan, 60) << ControlChange(midiChan, 100, 64)
//       << ProgramChange(midiChan, 100) << PitchBend(midiChan, 2000)
//       << Aftertouch(midiChan, 100) << PolyAftertouch(midiChan, 64, 100)
//       << StartMidi(0) << 239 << Finish()
//       << StartSysex(0) << 239 << Finish()
//       << StartSysRealTime(0) << 239 << Finish();
//
//    cout << "FINISH MIDI Test" << endl;

    // -----------------------------------------------------
    cout << endl << "BEGIN Array Test" << endl;

    // array check length
    cout << "array1 len: " << pd.arraySize("array1") << endl;

    // read array
    std::vector<float> array1;
    pd.readArray("array1", array1);    // sets array to correct size
    cout << "array1 ";
    for(int i = 0; i < array1.size(); ++i)
        cout << array1[i] << " ";
    cout << endl;

    // write array
    for(int i = 0; i < array1.size(); ++i)
        array1[i] = i;
    pd.writeArray("array1", array1);

    // ready array
    pd.readArray("array1", array1);
    cout << "array1 ";
    for(int i = 0; i < array1.size(); ++i)
        cout << array1[i] << " ";
    cout << endl;

    // clear array
    pd.clearArray("array1", 10);

    // ready array
    pd.readArray("array1", array1);
    cout << "array1 ";
    for(int i = 0; i < array1.size(); ++i)
        cout << array1[i] << " ";
    cout << endl;

    cout << "FINISH Array Test" << endl;

    // -----------------------------------------------------
    cout << endl << "BEGIN PD Test" << endl;

    pd.sendSymbol("fromOF", "test");

    cout << "FINISH PD Test" << endl;

    // -----------------------------------------------------
    cout << endl << "BEGIN Instance Test" << endl;

// 
}

//--------------------------------------------------------------

void ofApp::update() {
    
    
      
    
    bb.update();

    if(pd.isQueued()) {
        // process any received messages, if you're using the queue and *do not*
        // call these, you won't receieve any messages or midi!
        pd.receiveMessages();
        pd.receiveMidi();
    }
   
    
}

//--------------------------------------------------------------

void ofApp::draw() {
   
    

    ofBackground(152, 150, 162);
    t = t+1;
    size=2;
    


    
   
    bb.boxW=320;
    bb.boxH=620;
  
    
    padA.draw();
    padA.xPos=600;
    padA.base=300;
  
    
    grav.set(0,.1);
    
    bb.applyForce(grav);
    bb.draw();
    
    if (padA.value == true){
        wind.set(.1,0);
        bb.applyForce(wind);
        
    }
    

    
    


    
    if ( yep == true){
           cout << "yep" << endl;
           c = c + 1;
           
           
           if (c>array1.size()){
               c=0;
           }
           for(int i = 0; i < outputs.size(); ++i) {
           //midiOut.sendNoteOn(2,array1[i],127);
               cout << "midi coming out" << endl;
               outputs[i]->sendNoteOn(2,note);
               yep=false;
               
       }
       }else {yep=false;}
}
    
//\
}

//--------------------------------------------------------------
void ofApp::exit() {

    // cleanup

   for(int i = 0; i < outputs.size(); ++i) {
       outputs[i]->closePort();
       delete outputs[i];
   }
    ofSoundStreamStop();
}
//------------------------------------------------------------

//--------------------------------------------------------------
void ofApp::playTone(int pitch) {
    pd << StartMessage() << "pitch" << pitch << FinishList("tone") << Bang("tone");
}

//--------------------------------------------------------------
void ofApp::keyPressed (int key) {
    
 

    switch(key) {
        
        // musical keyboard
        case 'a':
            p=12;
            break;
        case 'w':
            p=13;
            break;
        case 's':
            p=14;
            break;
        case 'e':
            p=15;
            break;
        case 'd':
            p=16;
            break;
        case 'f':
            p=17;
            break;
        case 't':
            p=18;
            break;
        case 'g':
            p=19;
            break;
        case 'y':
            p=20;
            break;
        case 'h':
            p=21;
            break;
        case 'u':
            p=22;
            break;
        case 'j':
            p=23;
            break;
        case 'k':
            p=24;
            break;

        case ' ':
            if(pd.isReceivingSource(*this, "env")) {
                pd.ignoreSource(*this, "env");
                cout << "ignoring env" << endl;
            }
            else {
                pd.receiveSource(*this, "env");
                cout << "receiving from env" << endl;
            }
            break;

        default:
            break;
    }
}

//--------------------------------------------------------------
void ofApp::audioReceived(float * input, int bufferSize, int nChannels) {
    pd.audioIn(input, bufferSize, nChannels);
}

//--------------------------------------------------------------
void ofApp::audioRequested(float * output, int bufferSize, int nChannels) {
    pd.audioOut(output, bufferSize, nChannels);
}

//--------------------------------------------------------------
void ofApp::print(const std::string& message) {
    cout << message << endl;
}

//--------------------------------------------------------------
void ofApp::receiveBang(const std::string& dest) {
    cout << "OF: bang " << dest << endl;
    

    
}

void ofApp::receiveFloat(const std::string& dest, float value) {
    cout << "OF: float " << dest << ": " << value << endl;

     
    
}

void ofApp::receiveSymbol(const std::string& dest, const std::string& symbol) {
    cout << "OF: symbol " << dest << ": " << symbol << endl;
}

void ofApp::receiveList(const std::string& dest, const List& list) {
    cout << "OF: list " << dest << ": ";

    // step through the list
    for(int i = 0; i < list.len(); ++i) {
        if(list.isFloat(i))
            cout << list.getFloat(i) << " ";
        else if(list.isSymbol(i))
            cout << list.getSymbol(i) << " ";
    }

    // you can also use the built in toString function or simply stream it out
    // cout << list.toString();
    // cout << list;

    // print an OSC-style type string
    cout << list.types() << endl;
}

void ofApp::receiveMessage(const std::string& dest, const std::string& msg, const List& list) {
    cout << "OF: message " << dest << ": " << msg << " " << list.toString() << list.types() << endl;
}

//--------------------------------------------------------------
void ofApp::receiveNoteOn(const int channel, const int pitch, const int velocity) {
    cout << "OF MIDI: note on: " << channel << " " << pitch << " " << velocity << endl;
    yep = true;

    chan=channel;
    note=pitch;
    vel=velocity;
    


    
}


void ofApp::receiveControlChange(const int channel, const int controller, const int value) {
    cout << "OF MIDI: control change: " << channel << " " << controller << " " << value << endl;
}

// note: pgm nums are 1-128 to match pd
void ofApp::receiveProgramChange(const int channel, const int value) {
    cout << "OF MIDI: program change: " << channel << " " << value << endl;
}

void ofApp::receivePitchBend(const int channel, const int value) {
    cout << "OF MIDI: pitch bend: " << channel << " " << value << endl;
}

void ofApp::receiveAftertouch(const int channel, const int value) {
    cout << "OF MIDI: aftertouch: " << channel << " " << value << endl;
}

void ofApp::receivePolyAftertouch(const int channel, const int pitch, const int value) {
    cout << "OF MIDI: poly aftertouch: " << channel << " " << pitch << " " << value << endl;
}

// note: pd adds +2 to the port num, so sending to port 3 in pd to [midiout],
//       shows up at port 1 in ofxPd
void ofApp::receiveMidiByte(const int port, const int byte) {
    cout << "OF MIDI: midi byte: " << port << " " << byte << endl;
}

void ofApp::addMessage(string msg) {
    messageMutex.lock();
    cout << msg << endl;
    messages.push_back(msg);
    while(messages.size() > maxMessages) {
        messages.pop_front();
    }
    messageMutex.unlock();
}


void ofApp::newMidiMessage(ofxMidiMessage& msg) {
    addMessage(msg.toString());
}


//--------------------------------------------------------------
void ofApp::midiOutputAdded(string name, bool isNetwork) {
    stringstream msg;
    msg << "ofxMidi: output added: " << name << " network: " << isNetwork << endl;
   
    
    // create and open new output port
    ofxMidiOut *newOutput = new ofxMidiOut;
    newOutput->openPort(name);
    outputs.push_back(newOutput);
}

//--------------------------------------------------------------
void ofApp::midiOutputRemoved(string name, bool isNetwork) {
    stringstream msg;
    msg << "ofxMidi: output removed: " << name << " network: " << isNetwork << endl;
  
    
    // close and remove output port
    vector<ofxMidiOut*>::iterator iter;
    for(iter = outputs.begin(); iter != outputs.end(); ++iter) {
        ofxMidiOut *output = (*iter);
        if(output->getName() == name) {
            output->closePort();
            delete output;
            outputs.erase(iter);
            break;
        }
    }
    
}



