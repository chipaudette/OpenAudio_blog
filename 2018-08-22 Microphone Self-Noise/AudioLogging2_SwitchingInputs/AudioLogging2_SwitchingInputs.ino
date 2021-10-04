/*
   AudioLogging_SwitchingInputs

   MIT License.  use at your own risk.
*/


// Include all the of the needed libraries
#include <Tympan_Library.h>

//local files
#include "SDAudioWriter_SdFat.h" 
#include "SerialManager.h"

//definitions for SD writing
#define PRINT_OVERRUN_WARNING 1   //set to 1 to print a warning that the there's been a hiccup in the writing to the SD.
#define PRINT_FULL_SD_TIMING 0    //set to 1 to print timing information of *every* write operation.  Great for logging to file.  Bad for real-time human reading.
#define MAX_F32_BLOCKS (256)      //Can't seem to use more than 192, so you could set it to 192.  Won't run at all if much above 400.  

//set the sample rate and block size
const float sample_rate_Hz = 44117.0f ; //24000 or 44117 (or other frequencies in the table in AudioOutputI2S_F32)
const int audio_block_samples = 128;     //do not make bigger than AUDIO_BLOCK_SAMPLES from AudioStream.h (which is 128)
AudioSettings_F32 audio_settings(sample_rate_Hz, audio_block_samples);

// Define the overall setup
String overall_name = String("Tympan: Audio Logging with Switching Inputs");
const float input_gain_dB = 15.0f; //gain on the microphone
//float vol_knob_gain_dB = 0.0; //will be overridden by volume knob
#define BOTH_SERIAL audioHardware


// /////////// Define audio objects...they are configured later

//create audio library objects for handling the audio
TympanPins                    tympPins(TYMPAN_REV_D);        //TYMPAN_REV_C or TYMPAN_REV_D
TympanBase                    audioHardware(tympPins);
AudioInputI2S_F32             i2s_in(audio_settings);   //Digital audio input from the ADC
AudioMixer4_F32               mixerIn(audio_settings);
AudioRecordQueue_F32          queueLeft(audio_settings);     //gives access to audio data (will use for SD card)
AudioRecordQueue_F32          queueRight(audio_settings);     //gives access to audio data (will use for SD card)
AudioOutputI2S_F32            i2s_out(audio_settings);  //Digital audio output to the DAC.  Should always be last.


//make the audio connections
AudioConnection_F32       patchcord1(i2s_in, 0, mixerIn, 0);  //connect Raw audio to queue (to enable SD writing)
AudioConnection_F32       patchcord2(i2s_in, 1, mixerIn, 1); //connect Raw audio to queue (to enable SD writing)    
AudioConnection_F32       patchcord3(i2s_in, 0, queueLeft, 0);  //connect Raw audio to queue (to enable SD writing)
AudioConnection_F32       patchcord4(mixerIn, 0, queueRight, 0); //connect Raw audio to queue (to enable SD writing)
AudioConnection_F32       patchcord5(i2s_in, 0, i2s_out, 0);    //echo audio to output
AudioConnection_F32       patchcord6(i2s_in, 1, i2s_out, 1);    //echo audio to output

// Create variables to decide how long to record to SD
SDAudioWriter_SdFat my_SD_writer;

//control display and serial interaction
bool enable_printCPUandMemory = false;
void togglePrintMemoryAndCPU(void) { enable_printCPUandMemory = !enable_printCPUandMemory; }; //"extern" let's be it accessible outside
bool enable_printAveSignalLevels = false, printAveSignalLevels_as_dBSPL = false;
void togglePrintAveSignalLevels(bool as_dBSPL) { enable_printAveSignalLevels = !enable_printAveSignalLevels; printAveSignalLevels_as_dBSPL = as_dBSPL;};
SerialManager serialManager(audioHardware,mixerIn);

//set the recording configuration
#define CONFIG_PCB_MICS 20
#define CONFIG_MIC_JACK 21
#define CONFIG_LINE_IN  22
int current_config = 0;
void setConfiguration(int config) {

  //reset the mixer to differential
 
  //set the inputs
  switch (config) {
    case CONFIG_PCB_MICS:
      audioHardware.inputSelect(TYMPAN_INPUT_ON_BOARD_MIC); // use the on-board microphones
      mixerIn.gain(0,0.0); mixerIn.gain(1,1.0);  //right channel only (left is already sent to SD)
      current_config = CONFIG_PCB_MICS;
      BOTH_SERIAL.println("setConfiguration: switched to PCB MICs");
      break;
    case CONFIG_MIC_JACK:
      audioHardware.inputSelect(TYMPAN_INPUT_JACK_AS_MIC); // use the mic jack
      mixerIn.gain(0,0.0); mixerIn.gain(1,1.0);  //right channel only (left is already sent to SD)
      current_config = CONFIG_MIC_JACK;
      BOTH_SERIAL.println("setConfiguration: switched to MIC JACK");
      break;
    case CONFIG_LINE_IN:
      audioHardware.inputSelect(TYMPAN_INPUT_LINE_IN); // use the line-input through holes
      mixerIn.gain(0,0.5); mixerIn.gain(1,-0.5);  //differential mix
      current_config = CONFIG_LINE_IN;
      BOTH_SERIAL.println("setConfiguration: switched to LINE INPUT");
      break;      
  }
}

// control the recording phases
#define STATE_STOPPED 0
#define STATE_BEGIN 1
#define STATE_RECORDING 2
#define STATE_CLOSE 3
int current_state = STATE_STOPPED;
uint32_t recording_start_time_msec = 0;
void beginRecordingProcess(void) {
  if (current_state == STATE_STOPPED) {
    current_state = STATE_BEGIN;  
    startRecording();
  } else {
    BOTH_SERIAL.println("beginRecordingProcess: already recording, or completed.");
  }
}

int recording_count = 0;
void startRecording(void) {
  if (current_state == STATE_BEGIN) {
    recording_count++; 
    if (recording_count > 9) recording_count = 0;
    char fname[] = "RECORDx.RAW";
    fname[6] = recording_count + '0';  //stupid way to convert the number to a character
    setConfiguration(CONFIG_PCB_MICS);
    
    if (my_SD_writer.open(fname)) {
      BOTH_SERIAL.print("startRecording: Opened "); BOTH_SERIAL.print(fname); BOTH_SERIAL.println(" on SD for writing.");
      queueLeft.begin(); queueRight.begin();
      audioHardware.setRedLED(LOW); audioHardware.setAmberLED(HIGH); //Turn ON the Amber LED
      recording_start_time_msec = millis();
    } else {
      BOTH_SERIAL.print("startRecording: Failed to open "); BOTH_SERIAL.print(fname); BOTH_SERIAL.println(" on SD for writing.");
    }
    current_state = STATE_RECORDING;
  } else {
    BOTH_SERIAL.println("startRecording: not in correct state to start recording.");
  }
}

void stopRecording(void) {
  if (current_state == STATE_RECORDING) {
      BOTH_SERIAL.println("stopRecording: Closing SD File...");
      my_SD_writer.close();
      queueLeft.end();  queueRight.end();
      audioHardware.setRedLED(HIGH); audioHardware.setAmberLED(LOW); //Turn OFF the Amber LED
      current_state = STATE_STOPPED;
  }
}
// ///////////////// Main setup() and loop() as required for all Arduino programs

// define the setup() function, the function that is called once when the device is booting
void setup() {
  audioHardware.beginBothSerial(); delay(1000);
  BOTH_SERIAL.print(overall_name);BOTH_SERIAL.println(": setup():...");
  BOTH_SERIAL.print("Sample Rate (Hz): "); BOTH_SERIAL.println(audio_settings.sample_rate_Hz);
  BOTH_SERIAL.print("Audio Block Size (samples): "); BOTH_SERIAL.println(audio_settings.audio_block_samples);

  //allocate the audio memory
  AudioMemory_F32(MAX_F32_BLOCKS,audio_settings); //I can only seem to allocate 400 blocks
  Serial.println("Setup: memory allocated.");
  
  //activate the Tympan audio hardware
  audioHardware.enable(); // activate AIC

  //choose analog audio input on the Tympan
  setConfiguration(CONFIG_PCB_MICS);
    
  //set volumes
  audioHardware.volume_dB(0.f);  // -63.6 to +24 dB in 0.5dB steps.  uses signed 8-bit
  audioHardware.setInputGain_dB(input_gain_dB); // set MICPGA volume, 0-47.5dB in 0.5dB setps

  //Set the state of the LEDs
  audioHardware.setRedLED(HIGH);
  audioHardware.setAmberLED(LOW);

  //update the potentiometer settings
	//servicePotentiometer(millis());

  //setup SD card and start recording
  my_SD_writer.init();
  if (PRINT_FULL_SD_TIMING) my_SD_writer.enablePrintElapsedWriteTime(); //for debugging.  make sure time is less than (audio_block_samples/sample_rate_Hz * 1e6) = 2900 usec for 128 samples at 44.1 kHz

  //End of setup
  BOTH_SERIAL.println("Setup: complete.");serialManager.printHelp();

} //end setup()


// define the loop() function, the function that is repeated over and over for the life of the device
uint32_t step_time_millis = 2000;
uint32_t cur_time_rel_start_millis=0;
void loop() {
 
  //respond to Serial commands
  while (Serial.available()) serialManager.respondToByte((char)Serial.read());   //USB Serial
  while (Serial1.available()) serialManager.respondToByte((char)Serial1.read()); //BT Serial

  //update the place in the recording protocol
  cur_time_rel_start_millis = millis() - recording_start_time_msec;
  switch (current_state) {
    case STATE_RECORDING:
      if (cur_time_rel_start_millis < 1*step_time_millis) {
        if (current_config != CONFIG_PCB_MICS) setConfiguration(CONFIG_PCB_MICS);
      } else if (cur_time_rel_start_millis < 2*step_time_millis) {
        if (current_config != CONFIG_MIC_JACK) setConfiguration(CONFIG_MIC_JACK);
      } else if (cur_time_rel_start_millis < 3*step_time_millis) {
        if (current_config != CONFIG_LINE_IN) setConfiguration(CONFIG_LINE_IN);
      } else {
        stopRecording();
      }
  }
  
  //service the SD recording
  serviceSD();


  //update the memory and CPU usage...if enough time has passed
  if (enable_printCPUandMemory) printCPUandMemory(millis());

  //print info about the signal processing
  //updateAveSignalLevels(millis());
  //if (enable_printAveSignalLevels) printAveSignalLevels(millis(),printAveSignalLevels_as_dBSPL);

} //end loop()



// ///////////////// Servicing routines

//servicePotentiometer: listens to the blue potentiometer and sends the new pot value
//  to the audio processing algorithm as a control parameter
//void servicePotentiometer(unsigned long curTime_millis) {
//  static unsigned long updatePeriod_millis = 100; //how many milliseconds between updating the potentiometer reading?
//  static unsigned long lastUpdate_millis = 0;
//  static float prev_val = -1.0;
//
//  //has enough time passed to update everything?
//  if (curTime_millis < lastUpdate_millis) lastUpdate_millis = 0; //handle wrap-around of the clock
//  if ((curTime_millis - lastUpdate_millis) > updatePeriod_millis) { //is it time to update the user interface?
//
//    //read potentiometer
//    float val = float(analogRead(POT_PIN)) / 1024.0; //0.0 to 1.0
//    val = (1.0/9.0) * (float)((int)(9.0 * val + 0.5)); //quantize so that it doesn't chatter...0 to 1.0
//
//    //send the potentiometer value to your algorithm as a control parameter
//    //float scaled_val = val / 3.0; scaled_val = scaled_val * scaled_val;
//    if (abs(val - prev_val) > 0.05) { //is it different than befor?
//      prev_val = val;  //save the value for comparison for the next time around
//
//      setVolKnobGain_dB(val*45.0f - 10.0f - input_gain_dB);
//    }
//    lastUpdate_millis = curTime_millis;
//  } // end if
//} //end servicePotentiometer();



void printCPUandMemory(unsigned long curTime_millis) {
  static unsigned long updatePeriod_millis = 3000; //how many milliseconds between updating gain reading?
  static unsigned long lastUpdate_millis = 0;

  //has enough time passed to update everything?
  if (curTime_millis < lastUpdate_millis) lastUpdate_millis = 0; //handle wrap-around of the clock
  if ((curTime_millis - lastUpdate_millis) > updatePeriod_millis) { //is it time to update the user interface?
    printCPUandMemoryMessage();  
    lastUpdate_millis = curTime_millis; //we will use this value the next time around.
  }
}
void printCPUandMemoryMessage(void) {
    audioHardware.print("CPU Cur/Peak: ");
    audioHardware.print(audio_settings.processorUsage());
    //audioHardware.print(AudioProcessorUsage());
    audioHardware.print("%/");
    audioHardware.print(audio_settings.processorUsageMax());
    //audioHardware.print(AudioProcessorUsageMax());
    audioHardware.print("%,   ");
    audioHardware.print("Dyn MEM Int16 Cur/Peak: ");
    audioHardware.print(AudioMemoryUsage());
    audioHardware.print("/");
    audioHardware.print(AudioMemoryUsageMax());
    audioHardware.print(",   ");
    audioHardware.print("Dyn MEM Float32 Cur/Peak: ");
    audioHardware.print(AudioMemoryUsage_F32());
    audioHardware.print("/");
    audioHardware.print(AudioMemoryUsageMax_F32());
    audioHardware.println();
}

//float aveSignalLevels_dBFS[N_CHAN];
//void updateAveSignalLevels(unsigned long curTime_millis) {
//  static unsigned long updatePeriod_millis = 100; //how often to perform the averaging
//  static unsigned long lastUpdate_millis = 0;
//  float update_coeff = 0.2;
//
//  //is it time to update the calculations
//  if (curTime_millis < lastUpdate_millis) lastUpdate_millis = 0; //handle wrap-around of the clock
//  if ((curTime_millis - lastUpdate_millis) > updatePeriod_millis) { //is it time to update the user interface?
//    for (int i=0; i<N_CHAN; i++) { //loop over each band
//      aveSignalLevels_dBFS[i] = (1.0-update_coeff)*aveSignalLevels_dBFS[i] + update_coeff*expCompLim[i].getCurrentLevel_dB(); //running average
//    }
//    lastUpdate_millis = curTime_millis; //we will use this value the next time around.
//  }
//}
//void printAveSignalLevels(unsigned long curTime_millis, bool as_dBSPL) {
//  static unsigned long updatePeriod_millis = 3000; //how often to print the levels to the screen
//  static unsigned long lastUpdate_millis = 0;
//
//  //is it time to print to the screen
//  if (curTime_millis < lastUpdate_millis) lastUpdate_millis = 0; //handle wrap-around of the clock
//  if ((curTime_millis - lastUpdate_millis) > updatePeriod_millis) { //is it time to update the user interface?
//    printAveSignalLevelsMessage(as_dBSPL);
//    lastUpdate_millis = curTime_millis; //we will use this value the next time around.
//  }
//}
//void printAveSignalLevelsMessage(bool as_dBSPL) {
//  float offset_dB = 0.0f;
//  String units_txt = String("dBFS");
////  if (as_dBSPL) {
////    offset_dB = overall_cal_dBSPL_at0dBFS;
////    units_txt = String("dBSPL, approx");
////  }
//  audioHardware.print("Ave Input Level (");audioHardware.print(units_txt); audioHardware.print("), Per-Band = ");
//  for (int i=0; i<N_CHAN; i++) { audioHardware.print(aveSignalLevels_dBFS[i]+offset_dB,1);  audioHardware.print(", ");  }
//  audioHardware.println();
//}


void serviceSD(void) {
  if (my_SD_writer.isFileOpen()) {
    //if audio data is ready, write it to SD
    if ((queueLeft.available()) && (queueRight.available())) {
      //my_SD_writer.writeF32AsInt16(queueLeft.readBuffer(),audio_block_samples);  //mono
      my_SD_writer.writeF32AsInt16(queueLeft.readBuffer(),queueRight.readBuffer(),audio_block_samples); //stereo
      queueLeft.freeBuffer(); queueRight.freeBuffer();

      //print a warning if there has been an SD writing hiccup
      if (PRINT_OVERRUN_WARNING) {
        if (queueLeft.getOverrun() || queueRight.getOverrun() || i2s_in.get_isOutOfMemory()) {
          float blocksPerSecond = sample_rate_Hz / ((float)audio_block_samples);
          Serial.print("SD Write Warning: there was a hiccup in the writing.  Approx Time (sec): ");
          Serial.println( ((float)my_SD_writer.getNBlocksWritten()) / blocksPerSecond );
        }
      }

      //print timing information to help debug hiccups in the audio.  Are the writes fast enough?  Are there overruns?
      if (PRINT_FULL_SD_TIMING) {
        Serial.print("SD Write Status: "); 
        Serial.print(queueLeft.getOverrun()); //zero means no overrun
        Serial.print(", ");
        Serial.print(queueRight.getOverrun()); //zero means no overrun
        Serial.print(", ");
        Serial.print(AudioMemoryUsageMax_F32());  //hopefully, is less than MAX_F32_BLOCKS
        Serial.print(", ");
        Serial.print(MAX_F32_BLOCKS);  // max possible memory allocation
        Serial.print(", ");
        Serial.println(i2s_in.get_isOutOfMemory());  //zero means i2s_input always had memory to work with.  Non-zero means it ran out at least once.
        
        //Now that we've read the flags, reset them.
        AudioMemoryUsageMaxReset_F32();
      }

      queueLeft.clearOverrun();
      queueRight.clearOverrun();
      i2s_in.clear_isOutOfMemory();
    }

//    //check to see if potentiometer is set to turn off recording
//    if (potentiometer_value < 0.45) {  //turn below half-way to stop the recording
//      //stop recording
//      Serial.println("Closing SD File...");
//      my_SD_writer.close();
//      queueLeft.end();  queueRight.end();
//      audioHardware.setRedLED(HIGH); audioHardware.setAmberLED(LOW); //Turn OFF the Amber LED
//    }
  } else {
    //no SD recording currently, so no SD action

//    //check to see if potentiometer has been set to start recording
//    if (potentiometer_value > 0.55) {   //turn above half-way to start the recording
//      //yes, start recording
//      char fname[] = "RECORD1.RAW";
//      if (my_SD_writer.open(fname)) {
//        Serial.print("Opened "); Serial.print(fname); Serial.println(" on SD for writing.");
//        queueLeft.begin(); queueRight.begin();
//        audioHardware.setRedLED(LOW); audioHardware.setAmberLED(HIGH); //Turn ON the Amber LED
//      } else {
//        Serial.print("Failed to open "); Serial.print(fname); Serial.println(" on SD for writing.");
//      }
//    }
  }
}
