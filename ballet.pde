import dmxP512.*;
import processing.serial.*;
import processing.sound.*;

DmxP512 dmxOutput;
int universeSize=128;


boolean DMXPRO=true;
String DMXPRO_PORT="COM11";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

Serial port;  // The serial port

int aPrevious = 0;
int threshold = 31;
int maxDistance = 150;

SoundFile soundfile;

void setup() {
  size(400, 400);
  background(0);
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  port = new Serial(this, Serial.list()[0], 9600);
  println(port);

  dmxOutput=new DmxP512(this, universeSize, false);

  if (DMXPRO) {
    dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  }

  // Load a soundfile
  soundfile = new SoundFile(this, "Cajita Musical.mp3");

  // These methods return useful infos about the file
  println("SFSampleRate= " + soundfile.sampleRate() + " Hz");
  println("SFSamples= " + soundfile.frames() + " samples");
  println("SFDuration= " + soundfile.duration() + " seconds");

  // Play the file in a loop
  soundfile.loop();
}

void draw() {


  // Expand array size to the number of bytes you expect
  byte[] inBuffer = new byte[7];
  while (port.available() > 0) {
    inBuffer = port.readBytes();
    port.readBytes(inBuffer);
    if (inBuffer != null) {
      String myString = new String(inBuffer);
      println(myString);
      if (myString != null) {
        int a = int(myString.trim());
        //println("a = " + a);
        int b = int(map(lerp(aPrevious, a, 0.5), 0, 80, 0, 255));
        println("b = " + b);
        background(b);
        if (b >= threshold) {
          dmxOutput.set(1, b);
        } else if (b < threshold) {
          dmxOutput.set(1, 0);
        }
        dmxOutput.set(1, b);
        //dmxOutput.set(1, 255);
        //dmxOutput.set(2, 255);
        //dmxOutput.set(3, 255);
        //dmxOutput.set(4, 255);


        float playbackSpeed = map(b, 0, maxDistance, 0.05, 1);
        soundfile.rate(playbackSpeed);
        // Map mouseY from 0.2 to 1.0 for amplitude
        float amplitude = map(b, 0, maxDistance, 0, 1.5);
        soundfile.amp(amplitude);
        
        aPrevious = a;
      }
    }
  }
}
