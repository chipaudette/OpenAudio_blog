/*
 * TestHeadphoneOutputScaling.ino
 * 
 * Created: Chip Audette, Oct/Nov 2016
 * Purpose: Output a sine wave so that I can measure the magnitude of the
 *     headphone output of the Teensy Audio Board.  Use the pot to adjust
 *     the headphone volume command.
 *     
 * Hardware: Teensy Audio Board plus a Teensy (any Teensy 3.x will work
 *     but I happened to use a Teensy 3.2)
 *     
 * License: MIT License.  Use at your own risk.
 * 
 * http://openaudio.blogspot.com
*/

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

#define USE_USB 0

AudioControlSGTL5000     sgtl5000_1;     
AudioSynthWaveformSine   sine1;          
AudioOutputI2S           i2s1;          
AudioConnection          patchCord1(sine1, 0, i2s1, 0);
#if USE_USB == 1
AudioOutputUSB           usb1;           //xy=327,281
AudioConnection          patchCord2(sine1, 0, usb1, 0);
#endif


#define POT_PIN A1  //potentiometer is tied to this pin

void setup() {
  delay(200);
  Serial.begin(115200);
  delay(500);
  Serial.println("TestHeadphoneOutputScaling: beginning...");
  
  AudioMemory(10);  //give Audio Library some memory

  //configure the Teensy Audio Board
  sgtl5000_1.enable();
  //sgtl5000_1.inputSelect(myInput);
  sgtl5000_1.volume(0.8); //headphone volume
  sgtl5000_1.adcHighPassFilterDisable();  //reduce noise?  https://forum.pjrc.com/threads/27215-24-bit-audio-boards?p=78831&viewfull=1#post78831
  

  //configure the sine wave
  sine1.amplitude(0.95);
  sine1.frequency(1000);
}

void loop() {
 //read potentiometer
  float val = float(analogRead(POT_PIN)) / 1024.0; //0.0 to 1.0

  //set headphone volume
  val = ((int)(20.0*val + 0.5))/20.0; //round to nearest 0.05
  sgtl5000_1.volume(val); //headphone volume

  Serial.print("Headphone Volume = "); Serial.println(val);

  delay(200);
}
