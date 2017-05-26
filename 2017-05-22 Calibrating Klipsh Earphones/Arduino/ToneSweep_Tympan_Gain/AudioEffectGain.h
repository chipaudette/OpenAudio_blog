/*
 * AudioEffectGain_F32
 * 
 * Created: Chip Audette, November 2016
 * Purpose; Apply digital gain to the audio data.
 *          
 * This processes a single stream fo audio data (ie, it is mono)       
 *          
 * MIT License.  use at your own risk.
*/

#ifndef _AudioEffectGain_h
#define _AudioEffectGain_h

#include <arm_math.h> //ARM DSP extensions.  for speed!
#include <AudioStream.h>

class AudioEffectGain : public AudioStream
{
  //GUI: inputs:1, outputs:1  //this line used for automatic generation of GUI node  
  public:
    //constructor
    AudioEffectGain(void) : AudioStream(1, inputQueueArray) {};

    //here's the method that does all the work
    void update(void) {
  		//Serial.println("AudioEffectGain: updating.");  //for debugging.
  		audio_block_t *block = receiveWritable();
  		if (!block) return;
  
  		//apply the gain
  		for (int i = 0; i < AUDIO_BLOCK_SAMPLES; i++) block->data[i] = (int16_t)(gain * (float)(block->data[i])); //non DSP way to do it
  		//arm_scale_q15(block->data, gain, block->data, AUDIO_BLOCK_SAMPLES); //use ARM DSP for speed!
  
  		//transmit the block and be done
  		transmit(block);
  		release(block);
    }

    //methods to set parameters of this module
    void setGain(float g) { gain = g; }
    void setGain_dB(float gain_dB) {
      float gain = pow(10.0, gain_dB / 20.0);
      setGain(gain);
    }

    //methods to return information about this module
    float getGain(void) { return gain; }
    float getGain_dB(void) { return 20.0*log10(gain); }
    
  private:
    audio_block_t *inputQueueArray[1]; //memory pointer for the input to this module
    float gain = 1.0; //default value
};

#endif
