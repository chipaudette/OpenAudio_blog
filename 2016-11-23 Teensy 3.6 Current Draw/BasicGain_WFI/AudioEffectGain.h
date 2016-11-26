
class AudioEffectGain : public AudioStream
{
  public:
    AudioEffectGain(void) : AudioStream(1, inputQueueArray) {}
    void update(void) {
      audio_block_t *block;
      block = receiveWritable();
      if (!block) return;

      //apply the gain
      for (int i = 0; i < AUDIO_BLOCK_SAMPLES; i++) block->data[i] = gain * (block->data[i]);

      transmit(block);
      release(block);
    }
    void setGain(float g) {
      //gain = min(g, 1000.);  //limit the gain to 60 dB
      gain = g;
    }
    void setGain_dB(float gain_dB) {
      float gain = pow(10.0, gain_dB / 20.0);
      setGain(gain);
    }
  private:
    audio_block_t *inputQueueArray[1];
    float gain = 1.0; //default value
};
