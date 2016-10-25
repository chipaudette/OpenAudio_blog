/*
 * USB_Audio_Testing
 * 
 * Created: Chip Audette, October 2016, openaudio.blogspot.com
 *          
 * Purpose: Use the "USB Audio" source and sink from the Teensy Audio 
 *          Library.  Can we get audio into and out of the Teensy?
 *          
 * License: MIT License.  Use at your own risk.
 */
#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>

// GUItool: begin automatically generated code
AudioInputUSB            usb1;           //xy=70,155
AudioFilterBiquad        biquad1;        //xy=198,227
AudioOutputI2S           i2s1;           //xy=349,220
AudioOutputUSB           usb2;           //xy=349,156
AudioConnection          patchCord1(usb1, 0, usb2, 0);
AudioConnection          patchCord2(usb1, 0, i2s1, 0);
AudioConnection          patchCord3(usb1, 1, biquad1, 0);
AudioConnection          patchCord4(biquad1, 0, usb2, 1);
AudioConnection          patchCord5(biquad1, 0, i2s1, 1);
AudioControlSGTL5000     sgtl5000_1;     //xy=195,99
// GUItool: end automatically generated code

void setup() {
  delay(250);  AudioMemory(10);  delay(250);

  // Enable the audio shield and set the output volume.
  sgtl5000_1.enable();
  sgtl5000_1.inputSelect(AUDIO_INPUT_LINEIN);
  sgtl5000_1.volume(0.5); //headphone volume
  biquad1.setLowpass(0,500,0.707); //stage, freq, Q
}

void loop() {
   delay(20);
}

