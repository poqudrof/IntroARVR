import processing.video.*;

Capture video;
static final int VIDEO_WIDTH = 640;
static final int VIDEO_HEIGHT = 480;
static final int NB_PIXELS=VIDEO_HEIGHT * VIDEO_WIDTH;

static final String filePath="/home/ditrop/sketchbook/data/color.txt";


void settings(){
    size(VIDEO_WIDTH, VIDEO_HEIGHT);
}

public void setup() {

    // initialize the camera 
    video = new Capture(this, VIDEO_WIDTH , VIDEO_HEIGHT); // , "/dev/video1");
    
    // start the camera 
    video.start();
    
    frameRate(30);
}


int pickedColor = 0;

public void draw() {
    // background(0);


    if(video.available()){
	// When using video to manipulate the screen, use video.available() and
	// video.read() inside the draw() method so that it's safe to draw to the screen
	video.read(); // Read the new frame from the camera


	if(mousePressed == true){
	    // video.loadPixels();	    
	    
	    // int index = mouseY * VIDEO_WIDTH + mouseX;
	    
	    // int c = video.pixels[index];

	    // println("Color Picked " + c  + " " + red(c) + " " +green(c) + " " + blue(c));

	    // pickedColor = c;
	    
	}

	image(video, 0, 0, width, height);
  }
}

public void mousePressed(){
	    video.loadPixels();	    
	    
	    int index = mouseY * VIDEO_WIDTH + mouseX;
	    
	    int c = video.pixels[index];

	    println("Color Picked " + c  + " " + red(c) + " " +green(c) + " " + blue(c));

	    pickedColor = c;
	    

}


public void keyPressed(){

    if(key == 's'){
	saveColor();
    }

}


private void saveColor(){

    JSONObject json = new JSONObject();
    
    json.setInt("color", pickedColor);
    saveJSONObject(json, "data/color.json");

    
    // String[] list = new String[1];
    
    // list[0] = Integer.toString(pickedColor);
    
    // // Writes the strings to a file, each on a separate line
    // saveStrings(filePath, list);

    println("Color Saved on file " + filePath);
}
