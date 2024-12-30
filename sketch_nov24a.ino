const int changeClothingPin = A0;
const int sparklesPin = A2;
const int filterPin = A1;
const int threshold = 500;  // Threshold to detect pressure
const int buttonPin = 2;
int buttonState = 0;
int clothingItem = -1;      // Start with clothing item 1
const int joyStickXPin  = A3;
const int joyStickYPin = A5;

int lastButtonState = 0;
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;  

void setup() {

  Serial.begin(9600); 
  pinMode(buttonPin,INPUT);
}

void loop() {

int reading = digitalRead(buttonPin);
if(reading != lastButtonState){
  lastDebounceTime = millis();
}
if ((millis() - lastDebounceTime) > debounceDelay) {
    buttonState = reading;
}
 lastButtonState = reading;
  int changeClothingValue = analogRead(changeClothingPin);
  int sparkleValue = analogRead(sparklesPin);
  int filterValue = analogRead(filterPin); 
  int joyStickX = analogRead(joyStickXPin);
  int joyStickY = analogRead(joyStickYPin);

  Serial.print(clothingItem);
  Serial.print(",");
 Serial.print(sparkleValue);
  Serial.print(",");
  Serial.print(filterValue);
  Serial.print(",");
  Serial.print(buttonState);2
  Serial.print(",");
  Serial.print(joyStickX);
  Serial.print(",");
  Serial.print(joyStickY);
  Serial.println(" ");
 


  // Check if the pressure sensor has been pressed
  if (changeClothingValue > threshold) {
    clothingItem = (clothingItem + 1) % 5;  // Loop clothing items (0-6)
    while (analogRead(changeClothingPin) > threshold) {
      delay(10);  // Wait until pressure is released
    }

    delay(200);
  }
}
