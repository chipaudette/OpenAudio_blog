/*
 * Teensy_VaryInputGain_USB
 * 
 * Records from line-in and sends audio data out USB.
 * Increments the input gain every X seconds.
 * If you short the inputs, this is good for assessing
 * the self-noise of the system.
 * 
 *  * Uses Teensy Audio Board:  https://www.pjrc.com/store/teensy3_audio.htmlw
 * 
 * License: MIT License, Use At Your Own Risk
 * 
 */

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// define audio classes and connections
AudioControlSGTL5000      sgtl5000_1;
AudioInputI2S             audioInput; 
AudioOutputI2S            audioOutput;
AudioOutputUSB            usb_out;  // Be sure to enable USB AUDIO!!! (Tools -> USB Type -> Serial + MIDI + Audio
AudioConnection           patchCord1(audioInput, 0, audioOutput, 0);
AudioConnection           patchCord2(audioInput, 1, audioOutput, 1);
AudioConnection           patchCord3(audioInput, 0, usb_out, 0);
AudioConnection           patchCord4(audioInput, 1, usb_out, 1);

// define the setup
void setup(void)
{
  //allocate the audio memory first
  AudioMemory(10);  //big number to accomodate the delay effect

  //begin the serial comms
  Serial.begin(115200);  delay(500);
  Serial.println("Teensy_VaryInputGain_USB: starting...");
  
  // Setup the Teensy Audio Board
  sgtl5000_1.enable(); // activate AIC
  const int myInput = AUDIO_INPUT_LINEIN;

   // Enable the audio shield, select input, and enable output
  sgtl5000_1.enable();                   //start the audio board
  sgtl5000_1.inputSelect(myInput);       //choose line-in or mic-in
  sgtl5000_1.volume(0.8);                //volume can be 0.0 to 1.0.  0.5 seems to be the usual default.
  sgtl5000_1.lineInLevel(0,0);         //level can be 0 to 15.  5 is the Teensy Audio Library's default
  sgtl5000_1.adcHighPassFilterDisable(); //reduces noise.  https://forum.pjrc.com/threads/27215-24-bit-audio-boards?p=78831&viewfull=1#post78831

  Serial.println("Done");
}

void loop(void)
{

  Serial.println("Running...input gain 0");
  sgtl5000_1.lineInLevel(0,0);         //level can be 0 to 15.  5 is the Teensy Audio Library's default
  delay(3000);
  
  Serial.println("Running...input gain 5");
  sgtl5000_1.lineInLevel(5,5);         //level can be 0 to 15.  5 is the Teensy Audio Library's default
  delay(3000);
  
  Serial.println("Running...input gain 10");
  sgtl5000_1.lineInLevel(10,10);         //level can be 0 to 15.  5 is the Teensy Audio Library's default
  delay(3000);

  Serial.println("Running...input gain 15");
  sgtl5000_1.lineInLevel(15,15);         //level can be 0 to 15.  5 is the Teensy Audio Library's default
  delay(3000); 
  
}


