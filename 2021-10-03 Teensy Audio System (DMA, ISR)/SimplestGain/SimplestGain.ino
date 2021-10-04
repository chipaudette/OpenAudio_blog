#include <Tympan_Library.h>  //include the Tympan Library

// define audio objects and connections
Tympan                        myTympan;
AudioInputI2S_F32         	  i2s_in;
AudioEffectGain_F32           gain1;  
AudioOutputI2S_F32        	  i2s_out;
AudioConnection_F32           patchCord1(i2s_in, 0, gain1, 0); 
AudioConnection_F32           patchCord2(gain1, 0, i2s_out, 0); 

void setup() {
  AudioMemory_F32(10); 
  myTympan.enable();
  gain1.setGain_dB(6.0);
}

void loop() {
  //do nothing?
}
