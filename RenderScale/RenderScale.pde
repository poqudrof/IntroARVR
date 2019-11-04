import processing.net.*;

// Measure image width (in mm)
int imageWidth = 160; // mm
int imageHeight = 90; // mm 

Client client;

boolean useServer;
boolean updated = false;
PVector trackedPos = new PVector();

// Set image width (in pixels)
void settings(){
    size(1920, 1080);
}

void setup(){
    connect();
}

void connect(){
    try{
	client = new Client(this, "127.0.0.1", 12345); // Replace with your server's IP and port
	useServer = true;
    }catch(Exception e){
	client = null;
	useServer = false;
    }    
}

void draw(){
    // TODO: Scale the whole rendering to draw in mm

    //updatePos();
}

    
// Receive data from server
boolean updatePos(){
    if(!useServer){
	return false;
    }
    
    try{
	if (client.available() > 0) {
	    String input = client.readString();
	    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
	    float[] data = float(split(input, ' ')); // Split values into an array
	    
	    trackedPos.x = data[0];
	    trackedPos.y = data[1];
	    trackedPos.z = data[2];
	    
	    //    println("trackedPos " + trackedPos);

	    return true;
	}
    }
    catch(Exception e){
	println("Net error " + e );
    }
    return false;
}

