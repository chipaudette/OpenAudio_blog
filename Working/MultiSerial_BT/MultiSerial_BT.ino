/*
  Multple Serial test

 Receives from the main serial port, sends to the others.
 Receives from serial port 1, sends to the main serial (Serial 0).

 This example works only with boards with more than one serial like Arduino Mega, Due, Zero etc

 The circuit:
 * Any serial device attached to Serial port 1
 * Serial monitor open on Serial port 0:

 created 30 Dec. 2008
 modified 20 May 2012
 by Tom Igoe & Jed Roach
 modified 27 Nov 2015
 by Arturo Guadalupi

 This example code is in the public domain.

 */

void setup() {
  delay(250);
  
  // initialize both serial ports:
  Serial.begin(115200);
  Serial1.begin(115200);

  delay(500);
  Serial.println("MultiSerial_BT: USB Serial starting...");
  Serial1.println("MultiSerial_BT: BT Serial starting...");
  
}

long last_millis = millis();
int msg_count = 0;
void loop() {
  // read from port 1, send to port 0:
  if (Serial1.available()) {
    int inByte = Serial1.read();
    Serial.write(inByte);
  }

  // read from port 0, send to port 1:
  if (Serial.available()) {
    int inByte = Serial.read();
    Serial1.write(inByte);
  }

  if ((millis() - last_millis) > 5000) {
    Serial.print("USB Tick: ");Serial.println(msg_count);
    Serial1.print("BT Tick: ");Serial1.println(msg_count);
    msg_count++;
    last_millis = millis();
  }
}
