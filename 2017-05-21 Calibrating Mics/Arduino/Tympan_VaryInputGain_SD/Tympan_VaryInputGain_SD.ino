/*
 * Tympan_VaryInputGain_SD
 * 
 * Records from line-in and saves data to the SD card
 * Increments the input gain every X seconds.
 * If you short the inputs, this is good for assessing
 * the self-noise of the system.
 * 
 * Assumes the use of Teensy 3.6.
 * Uses Tympan Audio Board:  https://www.tympan.org
 * 
 * License: MIT License, Use At Your Own Risk
 * 
 */

/*
  The circuit:
   SD card attached to SPI bus as follows:
 ** MOSI - pin 11, pin 7 on Teensy with audio board
 ** MISO - pin 12
 ** CLK - pin 13, pin 14 on Teensy with audio board
 ** CS - pin 4, pin 10 on Teensy with audio board
*/

#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <Tympan_Library.h>  //AudioControlAIC3206 lives here

// change this to match your SD shield or module;
const int chipSelect = BUILTIN_SDCARD;

// define audio classes and connections
AudioControlAIC3206       tlv320aic3206_1;

// GUItool: begin automatically generated code
AudioInputI2S            i2s2;           //xy=105,63
//AudioAnalyzePeak         peak1;          //xy=278,108
AudioRecordQueue         queue1;         //xy=281,63
//AudioPlaySdRaw           playRaw1;       //xy=302,157
AudioOutputI2S           i2s_out;           //xy=470,120
AudioConnection          patchCord1(i2s2, 0, queue1, 0);
AudioConnection          patchCord2(i2s2, 0, i2s_out, 0);
//AudioConnection          patchCord2(i2s2, 0, peak1, 0);
//AudioConnection          patchCord3(playRaw1, 0, i2s1, 0);
//AudioConnection          patchCord4(playRaw1, 0, i2s1, 1);
// GUItool: end automatically generated code

// The file where data is recorded
File frec;

// define the setup
unsigned long started_millis = 0;
int mode = 0;
void setup(void)
{
  //allocate the audio memory first
  AudioMemory(60);  //big number to accomodate the delay effect

  //begin the serial comms
  Serial.begin(115200);  delay(500);
  Serial.println("Tympan_AIC3206: starting...");

  // Setup the TLV320
  tlv320aic3206_1.enable(); // activate AIC

  // Choose the desired input
  switch (1) {
    case 1:
      tlv320aic3206_1.inputSelect(TYMPAN_INPUT_ON_BOARD_MIC); // use the on board microphones // default
      break;
    case 2:
      tlv320aic3206_1.inputSelect(TYMPAN_INPUT_JACK_AS_MIC); // use the microphone jack - defaults to mic bias 2.5V
      tlv320aic3206_1.setMicBias(TYMPAN_MIC_BIAS_2_5); // set mic bias to 2.5 // default
      break;
    case 3:
      tlv320aic3206_1.inputSelect(TYMPAN_INPUT_JACK_AS_LINEIN);
      break;
    case 4:
      tlv320aic3206_1.inputSelect(TYMPAN_INPUT_LINE_IN); // use the line in pads on the TYMPAN board - defaults to mic bias OFF
      break;
  }

  // VOLUMES
  tlv320aic3206_1.volume_dB(0);  // -63.6 to +24 dB in 0.5dB steps.  uses float
  //tlv320aic3206_1.setInputGain_dB(0); // set MICPGA volume, 0-47.5dB in 0.5dB steps

  // Initialize the SD card
  if (!(SD.begin(chipSelect))) {
    // stop here if no SD card, but print a message
    while (1) {
      Serial.println("Unable to access the SD card");
      delay(500);
    }
  }

  //set input gain
  Serial.println("Running...input gain 0");
  tlv320aic3206_1.setInputGain_dB(0); // set MICPGA volume, 0-47.5dB in 0.5dB setps

  //start recording
  Serial.println("Starting recording...");
  startRecording();
  started_millis = millis();
}


unsigned long millis_per_step = 3000;
int prev_step = 0;
int count=0;
void loop(void)
{
  if (mode) {
    unsigned long dur_millis = millis() - started_millis;
    int step = dur_millis / millis_per_step;
    if (step != prev_step) {
      prev_step = step;
      count++;
      if (count < 3) {
        switch (count % 5) {
          case 0:
            Serial.println("Running...input gain 0");
            tlv320aic3206_1.setInputGain_dB(0); // set MICPGA volume, 0-47.5dB in 0.5dB setps
            break;
          case 1:
            Serial.println("Running...input gain 10");
            tlv320aic3206_1.setInputGain_dB(10); // set MICPGA volume, 0-47.5dB in 0.5dB setps
            break;
          case 2:
            Serial.println("Running...input gain 20");
            tlv320aic3206_1.setInputGain_dB(20); // set MICPGA volume, 0-47.5dB in 0.5dB setps
            break;
          case 3:
            Serial.println("Running...input gain 30");
            tlv320aic3206_1.setInputGain_dB(30); // set MICPGA volume, 0-47.5dB in 0.5dB setps
            break;
          case 4:
            Serial.println("Running...input gain 40");
            tlv320aic3206_1.setInputGain_dB(40); // set MICPGA volume, 0-47.5dB in 0.5dB setps
            break;
        }
      } else {
        stopRecording();
      }
    }
    continueRecording();
  } else {
    stopRecording();
    Serial.println("Complete.");
    delay(3000);
  }
}


void startRecording() {
  Serial.println("startRecording");
  if (SD.exists("RECORD.RAW")) {
    // The SD library writes new data to the end of the
    // file, so to start a new recording, the old file
    // must be deleted before new data is written.
    SD.remove("RECORD.RAW");
  }
  frec = SD.open("RECORD.RAW", FILE_WRITE);
  if (frec) {
    queue1.begin();
    mode = 1;
  }
}

void continueRecording() {
  if (queue1.available() >= 2) {
    byte buffer[512];
    // Fetch 2 blocks from the audio library and copy
    // into a 512 byte buffer.  The Arduino SD library
    // is most efficient when full 512 byte sector size
    // writes are used.
    memcpy(buffer, queue1.readBuffer(), 256);
    queue1.freeBuffer();
    memcpy(buffer + 256, queue1.readBuffer(), 256);
    queue1.freeBuffer();
    // write all 512 bytes to the SD card
    elapsedMicros usec = 0;
    frec.write(buffer, 512);
    // Uncomment these lines to see how long SD writes
    // are taking.  A pair of audio blocks arrives every
    // 5802 microseconds, so hopefully most of the writes
    // take well under 5802 us.  Some will take more, as
    // the SD library also must write to the FAT tables
    // and the SD card controller manages media erase and
    // wear leveling.  The queue1 object can buffer
    // approximately 301700 us of audio, to allow time
    // for occasional high SD card latency, as long as
    // the average write time is under 5802 us.
    //Serial.print("SD write, us=");
    //Serial.println(usec);
  }
}

void stopRecording() {
  Serial.println("stopRecording");
  queue1.end();
  if (mode == 1) {
    while (queue1.available() > 0) {
      frec.write((byte*)queue1.readBuffer(), 256);
      queue1.freeBuffer();
    }
    frec.close();
  }
  mode = 0;
}
