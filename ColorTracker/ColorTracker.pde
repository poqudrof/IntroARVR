// Inspired by Learning Processing
// Daniel Shiffman

import processing.video.*;
import controlP5.*;

// Variable for capture device
Capture video;

// Variable for Graphical interface
ControlP5 cp5;

PImage colorTrackingImage;

// A variable for the color we are searching for.
color trackColor; 

int VIDEO_WIDTH=640;
int VIDEO_HEIGHT=480;

void settings(){
  size(VIDEO_WIDTH + 200, VIDEO_HEIGHT * 2);
}

void setup() {

  video = new Capture(this, VIDEO_WIDTH, VIDEO_HEIGHT);
  video.start();
  // Start off tracking for red
  trackColor = color(255, 0, 0);

  // Create an image buffer to store image data
  colorTrackingImage = createImage(VIDEO_WIDTH, VIDEO_HEIGHT, RGB);

  initGui();
}

// ControlP5 automatically fills the error field. 
float error;

// ControlP5 object is drawn automatically.
void initGui(){
  cp5 = new ControlP5(this);

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("error")
     .setPosition(VIDEO_WIDTH + 20,50)
      .setSize(150, 20)
      .setValue(30)
     .setRange(0,180);
  
}


void captureEvent(Capture video) {
  // Read image from the camera
  video.read();
}

void draw() {
  clear();
    
  video.loadPixels();
  colorTrackingImage.loadPixels();

  // Draw the original video
  image(video, 0, 0);

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      // What is current color
      color currentColor = video.pixels[loc];

      //  Image analysis here.

      // Example of setting pixels
      // Display the picked color
      colorTrackingImage.pixels[loc] = color(error, 200, 0);
    }
  }

  // Send the image to the video buffer.
  colorTrackingImage.updatePixels();

  // Draw the buffer
  image(colorTrackingImage, 0, VIDEO_HEIGHT);
}



void mousePressed() {

    // Pick inside the window
    if(mouseX < VIDEO_WIDTH){
	// Save color where the mouse is clicked in trackColor variable
	int px = constrain(mouseX, 0, VIDEO_WIDTH-1);
	int py = constrain(mouseY, 0, VIDEO_HEIGHT-1);
  
	int loc = px + py*video.width;
	trackColor = video.pixels[loc];

	println("Color picked: " + red(trackColor) + " " + green(trackColor) + " " + blue(trackColor));
    }
}
