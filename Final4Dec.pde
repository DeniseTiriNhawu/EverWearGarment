import processing.serial.*;
import processing.sound.*;
Serial serialPort;
SoundFile sound;
SoundFile sound1;
import processing.video.*;

Movie myMovie;
int NUM_OF_VALUES_FROM_ARDUINO = 6;
int arduino_values[] = new int[NUM_OF_VALUES_FROM_ARDUINO];

PImage[] clothingImages = new PImage[5];

PImage endImage;

int clothingItem = -1;
int clothingX = 100; // Initial X position
int clothingY = 100; // Initial Y position
int moveStep = 10; // Step size for movement
float deadZone = 50;

int state = 1; // Initial state
int threshold2 = 1000; //threshold for the animation sensor
int threshold1 = 200;// threshold for the filter sensor
int currentFilter = -1; // -1 means no filter applied
int previousSensorValue = 0;


boolean readyForInteraction = false; // Ensures instructions remain visible initially



void setup() {
  fullScreen(P2D); 
  background(0);


  printArray(Serial.list());

  serialPort = new Serial(this, "/dev/cu.usbmodem1101", 9600);

  for (int i = 0; i < 5; i++) {
    clothingImages[i] = loadImage("clothing" + (i+1) + ".png"); // File names like "clothing1.png", "clothing2.png", loads the images into the patterns array
  }
  endImage = loadImage("last.png"); //loads image for the end screen


  sound1 = new SoundFile(this, "long.aif");//gets sound file from datafile

  if (clothingImages[0] != null) {
    clothingX = (width - clothingImages[0].width) / 2; // Center horizontally
    clothingY = (height - clothingImages[0].height) / 2; // Center vertically
  }
}

void draw() {
  if (state == 1) {
    drawStartScreen(); // beginning screen
  } else if (state == 2) {

    drawImageScreen(); // design mode
  } else if (state == 3) {
    drawThankYouScreen(); // end screen
  }
  getSerialData();
}

void getSerialData() { // reads from arduino
  while (serialPort.available() > 0) {
    String in = serialPort.readStringUntil(10);  // 10 = '\n'  Linefeed in ASCII
    if (in != null) {
      print("From Arduino: " + in);
      String[] serialInArray = split(trim(in), ",");
      if (serialInArray.length == NUM_OF_VALUES_FROM_ARDUINO) {
        for (int i = 0; i < serialInArray.length; i++) {
          arduino_values[i] = int(serialInArray[i]);
        }
      }
    }
  }
}

void drawStartScreen() { //function starts the audio tutorial
  background(0);
  if (!sound1.isPlaying()) { // Check if the sound is not already playing
    sound1.play();           // Start looping the sound
  }




  if (arduino_values[0] >= 0 && arduino_values[0] < clothingImages.length) { // Only transition to state 2 if interaction has happened
    state = 2;
  }
}

void drawImageScreen() {

  background(0);
  clothingItem = arduino_values[0];
  float joystickX = map(arduino_values[4], 0, 1023, -512, 512); // Centered at 0 , remaps arduino values to processing ones
  float joystickY = map(arduino_values[5], 0, 1023, -512, 512); // Centered at 0 , remaps arduino values to processing ones

  if (clothingItem != -1) { //checks if its not -1, therefore pressure sensor has been pressed

    PImage clothing = clothingImages[clothingItem];
    // Apply deadzone - makes the movemnt more smoother
    if (abs(joystickX) < deadZone) joystickX = 0;
    if (abs(joystickY) < deadZone) joystickY = 0;

    // Adjust clothing position based on joystick input
    clothingX += joystickX / 512 * moveStep; // Scale movement
    clothingY += joystickY / 512 * moveStep;

    // Constrain clothing position to remain within the window
    clothingX = constrain(clothingX, 0, width - clothing.width/2); // Adjust for image width
    clothingY = constrain(clothingY, 0, height - clothing.height/2);
    float scaleFactor = min(
      (float) width / clothing.width,
      (float) height / clothing.height
      );

    int scaledWidth = int(clothing.width * scaleFactor);
    int scaledHeight = int(clothing.height * scaleFactor);

    image(clothing, clothingX, clothingY); //shows the pattern , and its postions based on joystick

    if (arduino_values[1] > threshold2) {
      for (int i = 0; i < 100; i++) {
        int x = int(random(clothing.width));
        int y = int(random(clothing.height));
        color c = clothing.get(x, y);
        int screenX = clothingX + int(x * scaleFactor);
        int screenY = clothingY + int(y * scaleFactor);
        fill(c);
        float size = random(1, 20);
        ellipse(screenX, screenY, size, size);
      }
    }
    if (arduino_values[2] > threshold1 && previousSensorValue <= threshold1
      ) {
      currentFilter = (currentFilter + 1) % 4; // Cycle through 4 filters
    }
    previousSensorValue = arduino_values[2];

    if (currentFilter != -1) { // Apply filter only if currentFilter is valid
      switch (currentFilter) {
      case 0:
        noTint();
        break;
      case 1:
        filter(THRESHOLD);
        //noTint();
        break;
      case 2:
        filter(BLUR, 6);
        noTint();
        //tint(255,192,203,200);
        break;
      case 3:
        //filter(INVERT);
        filter(POSTERIZE, 2);
        noTint();
        break;
      case 4:
        tint(255, 192, 203, 200);
        break;
      default:
        noTint();
        break;
      }
    }
  }

  if (arduino_values[3] == 1) { // Assuming button input is in arduino_values[3]
    state = 3;
  }
}

void drawThankYouScreen() { //shows the end screen, image pops up s


  float scaledWidth = endImage.width * 0.8;
  float scaledHeight = endImage.height * 0.8;

  // Calculate the position to center the scaled image
  float imageX = (width - scaledWidth) / 2;
  float imageY = (height - scaledHeight) / 2 + 20;

  // Draw the scaled image in the center
  image(endImage, width/2, height/1.5, 300, 300);
}
