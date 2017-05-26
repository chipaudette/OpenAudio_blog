/*
  Demo of the audio sweep function.
  The user specifies the amplitude,
  start and end frequencies (which can sweep up or down)
  and the length of time of the sweep.
   
FMI:
The audio board uses the following pins.
 6 - MEMCS
 7 - MOSI
 9 - BCLK
10 - SDCS
11 - MCLK
12 - MISO
13 - RX
14 - SCLK
15 - VOL
18 - SDA
19 - SCL
22 - TX
23 - LRCLK

*/

#include <Audio.h>
#include <Tympan_Library.h>
#include "AudioEffectGain.h"

AudioSynthToneSweep toneSweep;
AudioEffectGain     gainEffect; 
AudioOutputI2S      audioOutput;        // audio shield: headphones & line-out

// The tone sweep goes to left and right channels
AudioConnection patchCord1(toneSweep, 0, gainEffect, 0);
AudioConnection patchCord2(gainEffect, 0, audioOutput, 0);
AudioConnection patchCord3(gainEffect, 0, audioOutput, 1);

AudioControlTLV320AIC3206 audioHardware;


float t_ampx;
int t_lox = 100;
int t_hix = 16000;

// Length of time for the sweep in seconds
float t_timex = 10;

// <<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
const float input_gain_dB = 20.0f; //gain on the microphone
float vol_knob_gain_dB = 0.0;      //will be overridden by volume knob
void setup(void)
{
  //Open serial link for debugging
  Serial.begin(115200); delay(500);
  Serial.println("ToneSweep_Tympan: starting setup()...");

  //allocate audio memory
  AudioMemory(10);

  //start the audio hardware
  audioHardware.enable();

  //Choose the desired input
  //audioHardware.inputSelect(TYMPAN_INPUT_ON_BOARD_MIC); // use the on board microphones
  audioHardware.inputSelect(TYMPAN_INPUT_JACK_AS_MIC); // use the microphone jack - defaults to mic bias 2.5V
  // audioHardware.inputSelect(TYMPAN_INPUT_JACK_AS_LINEIN); // use the microphone jack - defaults to mic bias OFF

  //Set the desired volume levels
  audioHardware.volume_dB(0);                   // headphone amplifier.  -63.6 to +24 dB in 0.5dB steps.
  audioHardware.setInputGain_dB(input_gain_dB); // set input volume, 0-47.5dB in 0.5dB setps

  //set overall gain
  gainEffect.setGain(2.0f);

  Serial.println("Setup complete.");

}

void loop(void)
{
  
  
  for (int Iloop=0; Iloop < 5; Iloop++) {
    delay(1000);

    
    switch (Iloop) {
      case 0:
        t_ampx = 0.05;
        break;
      case 1:
        t_ampx = 0.1;
        break;
      case 2:
        t_ampx = 0.25;
        break;
      case 3:
        t_ampx = 0.5;
        break;        
      case 4:
        t_ampx = 1.0;
    }
        
    if(!toneSweep.play(t_ampx,t_lox,t_hix,t_timex)) {
      Serial.println("AudioSynthToneSweep - begin failed");
      while(1);
    } else {
      Serial.print("AudioSynthToneSweep - playing amplitude ");
      Serial.println(t_ampx);
    }
    
    // wait for the sweep to end
    while(toneSweep.isPlaying());
    
  }
}



