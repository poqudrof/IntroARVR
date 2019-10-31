import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;
import processing.opengl.*;
import processing.net.*;

Client client = null;
String input;

// Screen resolution in pixels
static final int screenResolutionX = 1920;
static final int screenResolutionY = 1080;

// Screen size   -- mm
PVector screenSize = new PVector(530 , 330);


PShape rocket;
PVector trackedPos = new PVector();

// Position of the virtual camera  (the head) 
PVector camPos = new PVector(0, 0, 500);

// Extrinsic calibration (somehow) -> Center of screen to Camera. (no rotation)
// PVector trackingCameraPos = new PVector(0, screenSize.y / 2 + 80 , 0);
PVector trackingCameraPos = new PVector(0, -screenSize.y / 2 , 0);


// Application parameters

// Half of the distance between each eyes
float halfEyeDist = 9;  //  1.8 cm is acceptable for most of people. 
boolean useAnaglyph = true;

// Parameters of the OpenGL camera
float nearPlane = 100; 
float farPlane = 2000;


// Undecorated frame 
public void init() {
    frame.removeNotify(); 
    frame.setUndecorated(true); 
    frame.addNotify(); 
    //    super.init();
}

void settings(){
    size(screenResolutionX, screenResolutionY, OPENGL);
}

void setup() 
{
    // Connect to the server's IP address and port

    try{
	client = new Client(this, "127.0.0.1", 12345); // Replace with your server's IP and port
    }catch(Exception e){
	client = null;
	useHeadTracking = false;
    }    

    noCursor();
    rocket = loadShape("rocket.obj");
}



PGL pgl;

void draw() 
{

    background(0);

    updatePos();

    if(useHeadTracking)
	findCamPos();
    else {
	camPos = new PVector( 50 * (mouseX - width/2) / screenResolutionX, 
			      40 * (mouseY - height/2)/ screenResolutionY,
			     500);
    }
    
    println("Cam pos " + camPos);

    pgl = beginPGL();

    if(!useAnaglyph){
	drawLeft();
    }else {
    
	/////////////// Analglyph ////////////////////
	pgl.colorMask(true,false,false,true) ;
	drawLeft();

	// Clear the depth buffer, and set the other mask
	pgl.clear( GL.GL_DEPTH_BUFFER_BIT); 
	pgl.colorMask(false, true, true, true); 

	drawRight();

	// Put the color mask back to normal. 
	pgl.colorMask(true, true, true, true);
	/////////////// Analglyph -- END ////////////////////

    }
    
    endPGL();

    ry+= 0.01;

}



PVector lastTrackedPos = new PVector();
void findCamPos(){

    if(updated){
	camPos.set(trackedPos);
	updated = false;
    }
    else 
	camPos.set(lastTrackedPos);

    camPos.add(trackingCameraPos);

    camPos.x = camPos.x;
    camPos.y = camPos.y;

    lastTrackedPos = trackedPos.get();
}


// Left and right are inverted 

void drawLeft(){
    
    PVector camLeft = camPos.get();
    camLeft.add(halfEyeDist, 0, 0);

    setCamera(camLeft);
    drawScene();
}

void drawRight(){

    PVector camRight = camPos.get();
    camRight.add(-halfEyeDist, 0, 0);

    setCamera(camRight);  
    drawScene();
}


float ry = 0;

void drawScene(){

    lights();

    // Draw a grid: bottom of the screen

    stroke(255);
    strokeWeight(2);

    drawLines();


    // Rocket
    pushMatrix();
    // 10 cm rocket
    scale(100);
    rotateY(ry);
    scale(1f / 400f);
    //  rotateZ(PI);
    shape(rocket);
    popMatrix();


    // Moving object. 
    pushMatrix();
    translate(screenSize.x * (mouseX - width/2) / screenResolutionX, 
	      -screenSize.y * (mouseY - height/2)/ screenResolutionY,
	      10);
    scale(1f / 400f);
    scale(15f);
    shape(rocket);
    popMatrix();    


    // Camera Mirror
    pushMatrix();
    translate(camPos.x, camPos.y, -camPos.z);
    fill(0, 200, 0);
    noStroke();
    box(10);
    popMatrix();


}


void drawLines(){
    int numLines = 10;
    float lineDist = 60;
    int intensStep = 255 / numLines;

    // Horizontal lines
    float stepSize = screenSize.x / numLines;

    for(int i = 0; i <  numLines; i++) {
	stroke(255 - i * intensStep);

	// Bottom
	line(-screenSize.x/2f, -screenSize.y/2f, -i * lineDist, 
	     screenSize.x/2f, -screenSize.y/2f, -i * lineDist);

	// Top
	line(-screenSize.x/2f, screenSize.y/2f, -i * lineDist, 
	     screenSize.x/2f, screenSize.y/2f, -i * lineDist);

	// Line which goes to Z
	// Bottom
	for(float j = -screenSize.x/2f; j <  screenSize.x/2f ; j+= stepSize) {
	    line(j, -screenSize.y/2f, -i * lineDist,
		 j, -screenSize.y/2f, -i * lineDist - lineDist);
	}

	// Top
	for(float j = -screenSize.x/2f; j <  screenSize.x/2f ; j+= stepSize) {
	    line(j, screenSize.y/2f, -i * lineDist,
		 j, screenSize.y/2f, -i * lineDist - lineDist);
	}

    }
  
    stepSize = screenSize.y / numLines;
    // Vertical lines
    for(int i = 0; i <  numLines; i++) {
	stroke(255 - i * intensStep);

	// left
	line(-screenSize.x/2f, screenSize.y/2f, -i * lineDist, 
	     -screenSize.x/2f, -screenSize.y/2f, -i * lineDist);

	// right
	line(screenSize.x/2f, -screenSize.y/2f, -i * lineDist, 
	     screenSize.x/2f, screenSize.y/2f, -i * lineDist);

	// Line which goes to Z
	// left
	for(float j = -screenSize.y/2f; j <  screenSize.y/2f ; j+= stepSize) {
	    line(-screenSize.x/2f, j, -i * lineDist,
		 -screenSize.x/2f, j, -i * lineDist - lineDist);
	}

	// right
	for(float j = -screenSize.y/2f; j <  screenSize.y/2f ; j+= stepSize) {
	    line(screenSize.x/2f, j, -i * lineDist,
		 screenSize.x/2f, j, -i * lineDist - lineDist);
	}

    }

}



void drawRocket(PVector position, float size, boolean facing){

    pushMatrix();
    translate(position.x, position.y, position.z);
    
    // size cm rocket
    scale(size);

    if(facing)
	rotateX(HALF_PI);

    rotateY(ry * 5);
    scale(1f / 400f);

    shape(rocket);
    popMatrix();
}




boolean updated = false;
float data[];

// Receive data from server
boolean updatePos(){
    if(client != null){
	try{
	    if (client.available() > 0) {
		input = client.readString();
		input = input.substring(0, input.indexOf("\n")); // Only up to the newline
		data = float(split(input, ' ')); // Split values into an array
	    
		trackedPos.x = data[0];
		trackedPos.y = data[1];
		trackedPos.z = data[2];
		//    println("trackedPos " + trackedPos);
		updated= true;
		return true;
	    }
	    return false;
	}
	catch(Exception e){
	    println("Net error " + e );
	}
	return false;
    }  else 
	return false;
}


boolean test = false;
boolean useHeadTracking = false;
boolean useFilter = true;

void keyPressed(){

    if(key == 't')
	test = !test;

    if(key == 'h')
	useHeadTracking = !useHeadTracking;

    if(key == ' ')
	frame.setLocation(0, 0);
}



