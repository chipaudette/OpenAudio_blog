
#ifndef _SerialManager_h
#define _SerialManager_h

#include <Tympan_Library.h>

//add in the algorithm whose gains we wish to set via this SerialManager...change this if your gain algorithms class changes names!
//include "AudioEffectCompWDRC_F32.h"    //change this if you change the name of the algorithm's source code filename
//typedef AudioEffectCompWDRC_F32 GainAlgorithm_t; //change this if you change the algorithm's class name

//now, define the Serial Manager class
class SerialManager {
  public:
    SerialManager(TympanBase &_audioHardware,AudioMixer4_F32 &mixer)
      : audioHardware(_audioHardware), mixerIn(mixer)
        {  };
      
    void respondToByte(char c);
    void printHelp(void); 
  private:
    TympanBase &audioHardware;
    AudioMixer4_F32 &mixerIn;

};

void SerialManager::printHelp(void) {
  audioHardware.println();
  audioHardware.println("SerialManager Help: Available Commands:");
  audioHardware.println("   h: Print this help");
  audioHardware.println("   C: Toggle printing of CPU and Memory usage");
//  audioHardware.println("   l: Toggle printing of pre-gain per-channel signal levels (dBFS)");
  audioHardware.println("   j/J: (j) Join L+R channels, or (J) unjoin and just have left channel");
  audioHardware.println("   m/M: toggle (m) on-PCB mic vs (M) line-input");
  audioHardware.println("   r: begin recording protocol.");
  audioHardware.println();
}

//functions in the main sketch that I want to call from here
extern void togglePrintMemoryAndCPU(void);
//extern void togglePrintAveSignalLevels(bool);
extern void beginRecordingProcess(void);

//switch yard to determine the desired action
void SerialManager::respondToByte(char c) {
  switch (c) {
    case 'h': case '?':
      printHelp(); break;
    case 'C': case 'c':
      audioHardware.println("Command Received: toggle printing of memory and CPU usage.");
      togglePrintMemoryAndCPU(); break;
    case 'j':
      audioHardware.println("Command Received: joining as Left-Right (cut gain 6dB)");
      mixerIn.gain(0,0.5);      mixerIn.gain(1,-0.5);
      break;
    case 'J':      
      audioHardware.println("Command Received: L channel only (Return gain to normal).");
      mixerIn.gain(0,1.0);      mixerIn.gain(1,0.0);
      break;
//    case 'l':
//      audioHardware.println("Command Received: toggle printing of per-band ave signal levels.");
//      { bool as_dBSPL = false; togglePrintAveSignalLevels(as_dBSPL); }
//      break;
    case 'm':
      audioHardware.println("Command Received: switch to on-PCB mics (L only, normal gain).");
      mixerIn.gain(0,1.0);      mixerIn.gain(1,0.0);
      audioHardware.inputSelect(TYMPAN_INPUT_ON_BOARD_MIC);
      break;
    case 'M':
      audioHardware.println("Command Received: switch to line-input through holes (L-R, -6dB gain).");
      audioHardware.inputSelect(TYMPAN_INPUT_LINE_IN);
      mixerIn.gain(0,0.5);      mixerIn.gain(1,-0.5);
      break;
    case 'r':
      beginRecordingProcess();
      break;
  }
}


#endif
