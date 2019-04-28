/*
 * Tympan_VaryInputGain_USB
 * 
 * Records from line-in and sends audio data out USB.
 * Increments the input gain every X seconds.
 * If you short the inputs, this is good for assessing
 * the self-noise of the system.
 * 
 * Uses Tympan Audio Board:  https://www.tympan.org
 * 
 * License: MIT License, Use At Your Own Risk
 * 
 */

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <Tympan_Library.h>  //AudioControlAIC3206 lives here

// define audio classes and connections
AudioControlAIC3206       tlv320aic3206_1;
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
  Serial.println("Tympan_AIC3206: starting...");
  
  // Setup the TLV320
  tlv320aic3206_1.enable(); // activate AIC

  // Choose the desired input
  //tlv320aic3206_1.inputSelect(TYMPAN_INPUT_ON_BOARD_MIC); // use the on board microphones // default
  //  tlv320aic3206_1.inputSelect(TYMPAN_INPUT_JACK_AS_MIC); // use the microphone jack - defaults to mic bias 2.5V
  tlv320aic3206_1.inputSelect(TYMPAN_INPUT_JACK_AS_LINEIN); // use the microphone jack - defaults to mic bias OFF
  //  tlv320aic3206_1.inputSelect(TYMPAN_INPUT_LINE_IN); // use the line in pads on the TYMPAN board - defaults to mic bias OFF

  //Adjust the MIC bias, if using TYMPAN_INPUT_JACK_AS_MIC
  //  tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_OFF); // Turn mic bias off
  //  tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_2_5); // set mic bias to 2.5 // default
  //  tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_1_7); // set mic bias to 1.7
  //  tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_1_25); // set mic bias to 1.25
  //  tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_VSUPPLY); // set mic bias to supply voltage

  // VOLUMES
  tlv320aic3206_1.volume_dB(0);  // -63.6 to +24 dB in 0.5dB steps.  uses float
  tlv320aic3206_1.setInputGain_dB(0); // set MICPGA volume, 0-47.5dB in 0.5dB steps

  Serial.println("Done");
}

void loop(void)
{

  Serial.println("Running...input gain 0");
  tlv320aic3206_1.setInputGain_dB(0); // set MICPGA volume, 0-47.5dB in 0.5dB setps
  delay(3000);
  
  Serial.println("Running...input gain 10");
  tlv320aic3206_1.setInputGain_dB(10); // set MICPGA volume, 0-47.5dB in 0.5dB setps
  delay(3000);
  
   Serial.println("Running...input gain 20");
  tlv320aic3206_1.setInputGain_dB(20); // set MICPGA volume, 0-47.5dB in 0.5dB setps
  delay(3000);

  Serial.println("Running...input gain 30");
  tlv320aic3206_1.setInputGain_dB(30); // set MICPGA volume, 0-47.5dB in 0.5dB setps
  delay(3000); 
  
  Serial.println("Running...input gain 40");
  tlv320aic3206_1.setInputGain_dB(40); // set MICPGA volume, 0-47.5dB in 0.5dB setps
  delay(3000); 
   
}


