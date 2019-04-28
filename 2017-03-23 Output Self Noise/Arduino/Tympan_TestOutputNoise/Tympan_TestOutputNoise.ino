/*
 * Tympan_TestOutputNoise
 * 
 * Sends silence out the headphone output using different
 * output gain values.  Then, repeats the process using
 * a known-amplitude sine wave so that the scale factor
 * can be assessed. Uses a different frequency sine to
 * each ear so that the independence of the two output
 * channels can be confirmed.
 * 
 * Increments the output gain every X seconds.
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
AudioSynthWaveformSine    sine1, sine2;
AudioOutputI2S            audioOutput;
AudioConnection           patchCord1(sine1, 0, audioOutput, 0);
AudioConnection           patchCord2(sine2, 0, audioOutput, 1);

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

  // VOLUMES
  tlv320aic3206_1.volume_dB(0);  // -63.6 to +24 dB in 0.5dB steps.  uses float

  // setup sine waves
  sine1.frequency(300.f);
  sine2.frequency(1000.f);

  //float amp = 0.05f;
  //sine1.amplitude(amp);
  //sine2.amplitude(amp);

  Serial.println("Done");
}

#define N_VOLUME 5
float vol_dB[N_VOLUME] = {-20.f, -10.f, 0.f, 10.f, 20.f};
void loop(void) {
  
  for (int i = 0; i < 2; i++) {
    //set amplitude of sine waves
    float amp = ((float)i)*0.01f;
    Serial.print("Setting sine amplitude to "); Serial.println(amp);
    sine1.amplitude(amp);
    sine2.amplitude(amp);

    //step through different output volumes
    for (int j = 0; j < N_VOLUME; j++) {
      Serial.print("Setting output volume to "); Serial.print(vol_dB[j]); Serial.println(" dB");
      tlv320aic3206_1.volume_dB(vol_dB[j]); // set MICPGA volume, 0-47.5dB in 0.5dB setps
      delay(3000);
    }
  }   
}


