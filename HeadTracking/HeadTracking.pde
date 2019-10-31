import processing.video.*;
import controlP5.*;
import processing.net.*;

static final int VIDEO_WIDTH = 640;
static final int VIDEO_HEIGHT = 480;
static final int NB_PIXELS=VIDEO_HEIGHT * VIDEO_WIDTH;

static final String filePath="/home/ditrop/sketchbook/data/color.txt";

// Kinect
// float cx = 3.1595668001146578e+02;
// float cy = 2.6157156483310280e+02;
// float fx = 5.2415936681053381e+02;
// float fy = 5.2486377913229842e+02;

// PSEye
float cx = 3.0180015750388236e+02;
float cy = 2.3701656480861439e+02;
float fx = 8.0086447125656719e+02;
float fy = 8.0052366008750869e+02;
float ifx = 1f / fx;
float ify = 1f / fy;

// Enseirb 
// 640x480:  fx fy = 664  cy 277, cy 254
// 720p:  fx fy = 1005  cy 612, cy 384

float markerSize = 70; // 76 mm post-it
float markerSizeY = 70; // 76 mm post-it

Capture video;
PShape rocket;

PImage colorTrackingImage;

// Send the data...
Server server;

// GUI
ControlP5 cp5;

int errorHue = 20;
int errorSat = 20;
int errorBright = 20;

public void settings(){
    size(640 + 200, 480, P3D);
}


public void setup() {

  // initialize the camera 
  video = new Capture(this, VIDEO_WIDTH , VIDEO_HEIGHT); //, "/dev/video2");

  // start the camera 
  video.start();

  colorTrackingImage = createImage(VIDEO_WIDTH, VIDEO_HEIGHT, RGB);


  // GUI
  cp5 = new ControlP5(this);

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("errorHue")
     .setPosition(660,50)
     .setRange(0,180);
  
  cp5.addSlider("errorSat")
     .setPosition(660,70)
     .setRange(0,100);

    cp5.addSlider("errorBright")
     .setPosition(660,90)
     .setRange(0,100);
  
    loadColor();

    try{
    server = new Server(this, 12345); // Start a simple server on a port
    }catch(Exception e){
	println("Serveur issue... " + e);
    }
}

public void draw() {
    
    if(video.available()){

	clear();
	
	rect(40, 40, 20, 20);
	
    	// When using video to manipulate the screen, use video.available() and
    	// video.read() inside the draw() method so that it's safe to draw to the screen
    	video.read(); // Read the new frame from the camera

    	analyzeImage(video);    
    
    	// hint(DISABLE_DEPTH_TEST);
    	image(video, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT);
    	image(colorTrackingImage, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT);
    	// hint(ENABLE_DEPTH_TEST);


    	// Disable depth information for rendering the video image 
    
    	// fill(120);
    	// rect(VIDEO_WIDTH, 0,  200, VIDEO_HEIGHT);
    }
  

}

public void keyPressed(){
    if(key == 'l')
    	loadColor();
}

int trackedColor = 0;

public void loadColor(){
    JSONObject json = loadJSONObject("data/color.json");
    trackedColor = json.getInt("color");
    println("Color Loaded " + trackedColor);
}



public void analyzeImage(PImage image){

    // Set color mode to HSB with  180 degrees for hue 
    // and 100 for saturation and brightness
    colorMode(HSB, 180, 100, 100);

    image.loadPixels();
    colorTrackingImage.loadPixels();

    float hueToFind = hue(trackedColor);
    float saturationToFind = saturation(trackedColor);
    float brightnessToFind = brightness(trackedColor);

    // Values to get the size -> and center.
    int minX = image.width;
    int minY = image.height;
    int maxX = 0;
    int maxY = 0;


    int index = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {

        // Get the color stored in the pixel
        int pixelValue = image.pixels[index];


	float h = hue(pixelValue);
	float s = saturation(pixelValue);
	float v = brightness(pixelValue);


	int outputValue = color(h * 0.2, s, v);

	if(isCloseTo(h, hueToFind, errorHue) &&
	   isCloseTo(s, saturationToFind, errorSat) &&
	   isCloseTo(v, brightnessToFind, errorBright)){

	    colorTrackingImage.pixels[index] = trackedColor;
	}
	else {
	    colorTrackingImage.pixels[index] = 0;
	}

        index++;
      }
    }

    colorTrackingImage.updatePixels();

    colorTrackingImage.filter(ERODE);
    colorTrackingImage.filter(ERODE);

    colorTrackingImage.filter(DILATE);
    colorTrackingImage.filter(DILATE);

    index = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {

        // Get the color stored in the pixel
	  if(colorTrackingImage.pixels[index] == trackedColor){
	      if(x < minX)
	      	  minX = x;
	      
	      if(x > maxX)
	      	  maxX = x;
	      
	      if(y < minY)
	      	  minY = y;
	      
	      if(y > maxY)
	      	  maxY = y;
	  }
	  index++;
      }
    }

    PVector p1 = new PVector(minX, minY);
    PVector p2 = new PVector(maxX, minY);
    PVector p3 = new PVector(minX, maxY);
    PVector p4 = new PVector(maxX, maxY);

    translate(0, 0, 1);
    // noFill();
    // stroke(200);
    // strokeWeight(2);
    rect(10, 10, 20, 20);
    rect(p1.x, p1.y, 5, 5);
    rect(p2.x, p2.y, 5, 5);
    rect(p3.x, p3.y, 5, 5);
    rect(p4.x, p4.y, 5, 5);

    println(p1.x + " " + p1.y);

    translate(0, 0, -1);
    
    find3DCoordinate(p1, p2, p3, p4);

    PVector middlePos = new PVector();
    for(int i = 0; i < projectedPoints.length; i++){
    	middlePos.add(projectedPoints[i]);
    }
    middlePos.mult(1f / projectedPoints.length);

    println("Detected location " + middlePos);

    try{
    	server.write(middlePos.x + " " + middlePos.y + " " + middlePos.z + "\n");
    }catch(Exception e){
    	println("Serveur issue " + e);
    }

}


boolean isCloseTo(float val, float toFind, float error){

    return (val < (toFind + error)) && (val > (toFind - error));

}




PVector[] projectedPoints = new PVector[4];

void find3DCoordinate(PVector p1, PVector p2, PVector p3, PVector p4){

    // First two bottom points

    // size in pixels 
    float sX = abs(p1.x - p2.x);

    // Pythagore ->   sqrt ( fx^2 +  dCenter^2) 
    float dCenterP1 = abs(p1.x - cx);
    float d1 = sqrt( fx * fx +  dCenterP1 * dCenterP1);

    float dCenterP2 = abs(p2.x - cx);
    float d2 = sqrt( fx * fx +  dCenterP2 * dCenterP2);
    
    float depth =  (markerSize * d1) / sX;
    float depth2 =  (markerSize * d2) / sX;
    
    //    println("Guessed Depth " + depth + " " + depth2 + " diff " + (depth - depth2));

    projectedPoints[0] = pixelToWorld( new PVector (p1.x, p1.y, depth));
    projectedPoints[1] = pixelToWorld( new PVector (p2.x, p2.y, depth2));


    //////////// Now two top points
    // size in piyels 
    float sY = abs(p1.y - p3.y);

    // Pythagore ->   sqrt ( fy^2 +  dCenter^2) 
    dCenterP1 = abs(p1.y - cy);
    d1 = sqrt( fy * fy +  dCenterP1 * dCenterP1);

    float dCenterP3 = abs(p3.y - cy);
    d2 = sqrt( fy * fy +  dCenterP3 * dCenterP3);
    

    // Use MarkerSize Y for  non square markers
    depth =  (markerSizeY * d1) / sY;
    depth2 =  (markerSizeY * d2) / sY;

    projectedPoints[2] = pixelToWorld( new PVector (p3.x, p3.y, depth));
    projectedPoints[3] = pixelToWorld( new PVector (p4.x, p4.y, depth2));

    //    println("Projected " + projectedP1);
}


PVector pixelToWorld(PVector p){

    PVector result = new PVector();

    result.x = (float) ((p.x - cx) * p.z * ifx);
    result.y = (float) ((p.y - cy) * p.z * ify);
    result.z = p.z;

    return result;
}




