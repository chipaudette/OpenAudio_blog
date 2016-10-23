
2016-10-23
Chip Audette

Goal of Test: Demonstrate Line-In passthrough to headphone out.

Teensy Setup: Teensy 3.2 + Teensy Audio Board Rev B.  Software uses Teensy Audio Library with simple I2S input to I2S output.  Teensy USB is set to Serial mode.  Teensy 3.2 is running at 96 MHz.

Audio Setup: A Linear chirp was generated in Audacity.  Played out of Audacity via Laptop's headphone jack.  Headphone jack connected to Teensy Line-in via stereo 1/8" phono cable.  Teensy headphone jack connected to Roland R-05 audio recorder via its Line-In (ussing a second 1/8" stereo phono cable).  Roland R-05 had input gain set to ~40.

Test:  Played audio from laptop into Teensy.  Recorded audio from Teensy by Roland R-05.  No fanciness.


