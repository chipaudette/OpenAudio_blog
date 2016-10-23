/*
 * Basic Line-In Pass-Through
 *     Test the ability to pass audio through the device from the LineIn input.
 * 
 * Created: Chip Audette, Oct 2016
 * 
 * License: MIT License.  
 * 
 * Hardware: Uses Teensy Audio Board.  Tested with Teensy 3.2 and 3.6.  As of Teensyduino 1.30, Teensy 3.6
 *    only works when it is set to 120 MHz or slower.
 */
 
#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioInputI2S            i2s1;           //xy=140,161
AudioOutputI2S           i2s2;           //xy=369,161
AudioConnection          patchCord1(i2s1, 0, i2s2, 0);
AudioConnection          patchCord3(i2s1, 1, i2s2, 1);
AudioControlSGTL5000     sgtl5000_1;     //xy=250,81
//GUItool: end automatically generated code

void setup() {
  delay(250);
  AudioMemory(10);  //give the Audio Library some memory to work with
  delay(250);

  // Setup the SGTL5000 AIC
  sgtl5000_1.enable();    //activate the SGTL5000
  sgtl5000_1.inputSelect(AUDIO_INPUT_LINEIN); //which input to use (LINEIN or MIC)
  sgtl5000_1.volume(0.5); //set the headphone volume 
}

void loop() {
  delay(200); //do nothing
}

