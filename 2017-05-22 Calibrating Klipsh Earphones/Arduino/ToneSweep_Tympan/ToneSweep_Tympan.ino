/*
  ToneSweep_Tympan
  Based on ToneSweep in Audio library for Teensy

  Chip Audette, OpenAudio 2017
  
  The user specifies the start and end frequencies (which can sweep up or down)
  and the length of time of the sweep.  The program steps through different digital
  amplitudes so that you can see where distortion begins.

  See example usage: http://openaudio.blogspot.com/2017/05/calibrating-my-earphones-with-tympan.html

  MIT License, Use at your own risk.

*/

#include <Audio.h>
#include <Tympan_Library.h>

// Create the audio library objects that we'll use
AudioControlTLV320AIC3206 audioHardware;    //from the Tympan library
AudioSynthToneSweep toneSweep;               //from the Teensy Audio library
AudioOutputI2S      audioOutput;            //from the Teensy Audio library

// Create the audio connections from the tonesweep object to the audio output object
AudioConnection patchCord1(toneSweep, 0, audioOutput, 0);  //connect to left
AudioConnection patchCord2(toneSweep, 0, audioOutput, 1);  //connect to right

// Define the parameters of the tone sweep
float t_ampx;       //variable that will be used to set the amplitude of the sweep
int t_lox = 100;    //starting frequency for tone sweep, Hz
int t_hix = 16000;  //end frequency for the tone sweep, Hz
float t_timex = 10;  // Length of time for the sweep, seconds

// <<<<<<<<<<<<<<>>>>>>>>>>>>>>>>
//const float input_gain_dB = 20.0f; //gain on the microphone
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

  //Set the baseline volume levels
  audioHardware.volume_dB(0);                   // headphone amplifier.  -63.6 to +24 dB in 0.5dB steps.
  
  Serial.println("Setup complete.");
}

void loop(void)
{
  
  //loop over five different loudnesses
  for (int Iloop=0; Iloop < 6; Iloop++) {
    delay(1000);  //delay for a moment to provide seperation between the sweeps
    
    switch (Iloop) {
      case 0:
        t_ampx = 0.1;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-0.05
        break;
      case 1:
        t_ampx = 0.3;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-0.15
        break;
      case 2:
        t_ampx = 0.5;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-0.25
        break;
      case 3:
        t_ampx = 0.7;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-0.35
        break;        
      case 4:
        t_ampx = 1.0;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-0.5
        break;
      case 5:
        t_ampx = 2.0;  //For some reason, the AudioSynthToneSweep object cuts this in half, so really it's digital +/-1.0
        break;
    }
    Serial.print("Beginning tone sweep at digital amplitude of ");
    Serial.println(t_ampx);
        
    if(!toneSweep.play(t_ampx,t_lox,t_hix,t_timex)) {
      Serial.println("AudioSynthToneSweep - begin failed");
      while(1);
    }
    
    // wait for the sweep to end
    while(toneSweep.isPlaying());
    
  }
}



